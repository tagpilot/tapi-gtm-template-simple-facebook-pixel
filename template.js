const createQueue = require('createQueue');
const callInWindow = require('callInWindow');
const aliasInWindow = require('aliasInWindow');
const copyFromWindow = require('copyFromWindow');
const setInWindow = require('setInWindow');
const injectScript = require('injectScript');
const makeTableMap = require('makeTableMap');
const makeNumber = require('makeNumber');
const getType = require('getType');
const copyFromDataLayer = require('copyFromDataLayer');
const math = require('Math');
const log = require('logToConsole');
const templateStorage = require('templateStorage');

const standardEventNames = {
    add_payment_info: 'AddPaymentInfo',
    add_to_cart: 'AddToCart',
    add_to_wishlist: 'AddToWishlist',
    signup: 'CompleteRegistration',
    generate_lead: 'Lead',
    begin_checkout: 'InitiateCheckout',
    'gtm.dom': 'PageView',
    'gtm.js': 'PageView',
    'gtm.init': 'PageView',
    'gtm.historyChange': 'PageView',
    purchase: 'Purchase',
    search: 'Search',
    view_item: 'ViewContent'
};
const ecommerce = copyFromDataLayer('ecommerce', 1);
const eventName = copyFromDataLayer('event', 1);
let eventId = copyFromDataLayer('event_id', 1);

if (!eventId && data.eventId) {
  eventId = data.eventId;
}

let mappedEventName = standardEventNames[eventName];

if (data.eventName) {
    mappedEventName = data.eventName;
}

// Utility function to use either fbq.queue[]
// (if the FB SDK hasn't loaded yet), or fbq.callMethod()
// if the SDK has loaded.
const getFbq = () => {
    // Return the existing 'fbq' global method if available
    let fbq = copyFromWindow('fbq');
    if (fbq) {
        return fbq;
    }

    // Initialize the 'fbq' global method to either use
    // fbq.callMethod or fbq.queue)
    setInWindow('fbq', function() {
        const callMethod = copyFromWindow('fbq.callMethod.apply');
        if (callMethod) {
            callInWindow('fbq.callMethod.apply', null, arguments);
        } else {
            callInWindow('fbq.queue.push', arguments);
        }
    });
    aliasInWindow('_fbq', 'fbq');

    // Create the fbq.queue
    createQueue('fbq.queue');

    // Return the global 'fbq' method, created above
    return copyFromWindow('fbq');
};

log('mappedEventName', mappedEventName);

const params = {};
const userData = {};

if (data.userData && data.userData.email && data.userData.phone_number) {
    userData.em = data.userData.email;
    userData.ph = data.userData.phone_number;
    userData.external_id = data.externalId;
}

if (mappedEventName === 'Purchase' && ecommerce.transaction_id) {
    eventId = ecommerce.transaction_id;
}

if (ecommerce) {
    params.content_type = 'product';
    params.value = (ecommerce.value || 0);
    params.currency = ecommerce.currency;
    params.contents = (ecommerce.items || []).map(function(item) {
        const contentIdKey = data.customContentIdKey || 'item_id';
        return {
            id: item[contentIdKey],
            quantity: item.quantity || 1,
        };
    });
}

log('params', params, userData, templateStorage.getItem(data.pixelId), eventId);
// Get reference to the global method
const fbq = getFbq();

if (templateStorage.getItem(data.pixelId) === null || (templateStorage.getItem(data.pixelId) === 1 && (userData.em || userData.ph))) {
    // Initialize pixel and store in global array
    log('FB INIT', userData);
    fbq('init', data.pixelId, userData);

    templateStorage.setItem(data.pixelId, (templateStorage.getItem(data.pixelId) || 0) + 1);
    // Call the fbq() method with the parameters defined earlier
}

if (typeof mappedEventName !== 'undefined') {
    if (eventId) {
        fbq('track', mappedEventName, params, {eventID: eventId});
    } else {
        fbq('track', mappedEventName, params);
    }
}

injectScript('https://connect.facebook.net/en_US/fbevents.js', data.gtmOnSuccess, data.gtmOnFailure, 'fbPixel');