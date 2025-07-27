___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "displayName": "Simple Facebook Pixel",
  "__wm": "VGVtcGxhdGUtQXV0aG9yX0ZhY2Vib29rLVNpbW8tQWhhdmE\u003d",
  "description": "Simple Facebook Pixel implementation that supports Advanced Matching, eCommerce works with server-side GTM Conversions API and Single Page Applications.",
  "securityGroups": [],
  "categories": [
    "ADVERTISING",
    "ANALYTICS"
  ],
  "id": "cvt_temp_public_id",
  "type": "TAG",
  "version": 1,
  "brand": {
    "displayName": "",
    "id": "github.com_facebookarchive"
  },
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "alwaysInSummary": true,
    "valueValidators": [
      {
        "errorMessage": "You must provide a Pixel ID",
        "type": "NON_EMPTY"
      },
      {
        "args": [
          "^[0-9,]+$"
        ],
        "errorMessage": "Invalid Pixel ID format",
        "type": "REGEX"
      }
    ],
    "displayName": "Facebook Pixel ID(s)",
    "simpleValueType": true,
    "name": "pixelId",
    "type": "TEXT",
    "valueHint": "e.g. 12345678910"
  },
  {
    "type": "TEXT",
    "name": "userData",
    "displayName": "User-Data",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "eventId",
    "displayName": "Event ID",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

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
  'gtm.historyChange': 'PageView',
  purchase: 'Purchase',
  search: 'Search',
  view_item: 'ViewContent'
};
const ecommerce = copyFromDataLayer('ecommerce', 1);
const eventName = copyFromDataLayer('event', 1);
let eventId = copyFromDataLayer('event_id', 1);

const mappedEventName = standardEventNames[eventName];

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
}

if (!eventId && mappedEventName === 'Purchase') {
  eventId = ecommerce.transaction_id;
}

if (ecommerce) {
  params.content_type = 'product';
  params.value = (ecommerce.value || 0);
  params.currency = ecommerce.currency;
  params.contents = (ecommerce.items || []).map(function(item) {
    return {
      id: item.item_id,
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


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "fbq"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_fbq_gtm"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_fbq"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_fbq_gtm_ids"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "fbq.callMethod.apply"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "fbq.queue.push"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "fbq.queue"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "fbq.disablePushState"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://connect.facebook.net/en_US/fbevents.js"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedKeys",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "ecommerce"
              },
              {
                "type": 1,
                "string": "event"
              },
              {
                "type": 1,
                "string": "event_id"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_template_storage",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Library is injected
  code: |-
    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('injectScript').wasCalledWith(scriptUrl, success, failure, 'fbPixel');
    assertApi('gtmOnSuccess').wasCalled();
- name: fbq does not exist - method created
  code: |-
    let fbq;

    mock('copyFromWindow', key => {
      if (key === 'fbq') return fbq;
    });

    mock('createQueue', key => {});

    mock('setInWindow', (key, val) => {
      if (key === 'fbq') fbq = val;
    });

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('aliasInWindow').wasCalledWith('_fbq', 'fbq');
    assertApi('setInWindow').wasCalled();
    assertApi('gtmOnSuccess').wasCalled();
- name: fbq exists - method copied
  code: |-
    mock('setInWindow', key => {
      if (key === 'fbq') fail('setInWindow called with fbq even though variable exists');
    });

    mock('createQueue', key => {});

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
- name: makeTableMap called
  code: |-
    mockData.advancedMatching = true;

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('makeTableMap').wasCalledWith(mockData.advancedMatchingList, 'name', 'value');
    assertApi('makeTableMap').wasCalledWith(mockData.objectPropertyList, 'name', 'value');
    assertApi('gtmOnSuccess').wasCalled();
- name: Consent set
  code: |-
    mock('copyFromWindow', key => {
      if (key === 'fbq') return function() {
        if (arguments[0] === 'consent') {
          assertThat(arguments[1], 'Consent set incorrectly').isEqualTo('grant');
        }
      };
    });

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
- name: DPO LDU set
  code: |-
    mockData.dpoLDU = true;
    mockData.dpoCountry = '0';
    mockData.dpoState = '0';

    mock('copyFromWindow', key => {
      if (key === 'fbq') return function() {
        if (arguments[0] === 'consent') {
          assertThat(arguments[1], 'Consent set incorrectly').isEqualTo('grant');
        }
        if (arguments[0] === 'dataProcessingOptions') {
          assertThat(arguments[1], 'LDU array value not set').isEqualTo(['LDU']);
          assertThat(arguments[2], 'LDU country not set').isEqualTo(0);
          assertThat(arguments[3], 'LDU state not set').isEqualTo(0);
        }
      };
    });

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
- name: DPO LDU not set
  code: |-
    mock('copyFromWindow', key => {
      if (key === 'fbq') return function() {
        if (arguments[0] === 'consent') {
          assertThat(arguments[1], 'Consent set incorrectly').isEqualTo('grant');
        }
        if (arguments[0] === 'dataProcessingOptions') {
          fail('dataProcessingOptions called even though DPO was not set');
        }
      };
    });

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
- name: Pixel IDs set - do not initialize
  code: |-
    mock('copyFromWindow', key => {
      if (key === '_fbq_gtm_ids') return ['12345', '23456'];
      if (key === 'fbq') return function() {
        if (arguments[0] === 'init') fail('init called even though pixel IDs already initialized');
      };
    });

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
- name: Pixel IDs not set - run init process
  code: "let index = 0;\nlet count = 0;\nlet _fbq_gtm_ids;\n\nmockData.advancedMatching\
    \ = true;\nmockData.disableAutoConfig = true;\nmockData.disablePushState = true;\n\
    \nmock('setInWindow', (key, val) => {\n  if (key === 'fbq.disablePushState') count\
    \ += 1;\n  if (key === '_fbq_gtm_ids') _fbq_gtm_ids = val;\n});\n\nconst initObj\
    \ = {\n  ct: 'Helsinki',\n  cn: 'Finland',\n  external_id: 'UserId'\n};\n\nmock('copyFromWindow',\
    \ key => {\n  if (key === 'fbq') return function() {\n    if (arguments[0] ===\
    \ 'set' && arguments[1] === 'autoConfig' && arguments[2] === false) {\n      assertThat(arguments[3],\
    \ 'autoConfig called with incorrect pixelId').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \    }\n    if (arguments[0] === 'set' && arguments[1] === 'agent') {\n      assertThat(arguments[2],\
    \ 'agent set with invalid value').isEqualTo('tmSimo-GTM-WebTemplate');\n     \
    \ assertThat(arguments[3], 'agent set with invalid pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      index += 1;\n    }\n    if (arguments[0] === 'init') {\n      assertThat(arguments[1],\
    \ 'init called with incorrect pixelId').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'init called with incorrect initObj').isEqualTo(initObj);\n\
    \    } \n  };\n});\n\n// Call runCode to run the template's code.\nrunCode(mockData);\n\
    \nassertThat(_fbq_gtm_ids, '_fbq_gtm_ids has incorrect contents').isEqualTo(mockData.pixelId.split(','));\n\
    assertThat(index, 'init called incorrect number of times: ' + index).isEqualTo(2);\n\
    assertThat(count, 'fbq.disablePushState called incorrect number of times: ' +\
    \ count).isEqualTo(2);\n\n// Verify that the tag finished successfully.\nassertApi('gtmOnSuccess').wasCalled();"
- name: Send standard event
  code: "const eventParams = {\n  prop1: 'val1',\n  prop2: 'val2'\n};\n\nlet index\
    \ = 0;\nmock('copyFromWindow', key => {\n  if (key === 'fbq') return function()\
    \ {\n    if (arguments[0] === 'trackSingle') {\n      assertThat(arguments[1],\
    \ 'trackSingle called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingle called with incorrect event name').isEqualTo(mockData.standardEventName);\n\
    \      assertThat(arguments[3], 'trackSingle called with incorrect event parameters').isEqualTo(eventParams);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingle called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Send custom event
  code: "mockData.eventName = 'custom';\n\nconst eventParams = {\n  prop1: 'val1',\n\
    \  prop2: 'val2'\n};\n\nlet index = 0;\nmock('copyFromWindow', key => {\n  if\
    \ (key === 'fbq') return function() {\n    if (arguments[0] === 'trackSingleCustom')\
    \ {\n      assertThat(arguments[1], 'trackSingleCustom called with incorrect pixel\
    \ ID').isEqualTo(mockData.pixelId.split(',')[index]);\n      assertThat(arguments[2],\
    \ 'trackSingleCustom called with incorrect event name').isEqualTo(mockData.customEventName);\n\
    \      assertThat(arguments[3], 'trackSingleCustom called with incorrect event\
    \ parameters').isEqualTo(eventParams);\n      index += 1;\n    }\n  };\n});\n\
    \     \n// Call runCode to run the template's code.\nrunCode(mockData);\n\n//\
    \ Verify that the tag finished successfully.\nassertThat(index, 'trackSingleCustom\
    \ called incorrect number of times').isEqualTo(2);\nassertApi('gtmOnSuccess').wasCalled();"
- name: Send variable event with standard name
  code: "mockData.eventName = 'variable';\nmockData.variableEventName = 'PageView';\n\
    \nconst eventParams = {\n  prop1: 'val1',\n  prop2: 'val2'\n};\n\nlet index =\
    \ 0;\nmock('copyFromWindow', key => {\n  if (key === 'fbq') return function()\
    \ {\n    if (arguments[0] === 'trackSingle') {\n      assertThat(arguments[1],\
    \ 'trackSingle called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingle called with incorrect event name').isEqualTo(mockData.variableEventName);\n\
    \      assertThat(arguments[3], 'trackSingle called with incorrect event parameters').isEqualTo(eventParams);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingle called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Send variable event with custom name
  code: "mockData.eventName = 'variable';\nmockData.variableEventName = 'custom';\n\
    \nconst eventParams = {\n  prop1: 'val1',\n  prop2: 'val2'\n};\n\nlet index =\
    \ 0;\nmock('copyFromWindow', key => {\n  if (key === 'fbq') return function()\
    \ {\n    if (arguments[0] === 'trackSingleCustom') {\n      assertThat(arguments[1],\
    \ 'trackSingleCustom called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingleCustom called with incorrect event\
    \ name').isEqualTo(mockData.variableEventName);\n      assertThat(arguments[3],\
    \ 'trackSingleCustom called with incorrect event parameters').isEqualTo(eventParams);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingleCustom called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Send event parameters from a variable
  code: "mockData.objectPropertiesFromVariable = {\n  prop1: 'val1',\n  prop2: 'val2'\n\
    };\n\nlet index = 0;\nmock('copyFromWindow', key => {\n  if (key === 'fbq') return\
    \ function() {\n    if (arguments[0] === 'trackSingle') {\n      assertThat(arguments[1],\
    \ 'trackSingle called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingle called with incorrect event name').isEqualTo(mockData.standardEventName);\n\
    \      assertThat(arguments[3], 'trackSingle called with incorrect event parameters').isEqualTo(mockData.objectPropertiesFromVariable);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingle called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Enhanced Ecommerce integration fails with invalid object
  code: |-
    mockData.enhancedEcommerce = true;

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('logToConsole').wasCalledWith('Facebook Pixel: No valid "ecommerce" object found in dataLayer');
    assertApi('gtmOnFailure').wasCalled();
    assertApi('gtmOnSuccess').wasNotCalled();
- name: Enhanced Ecommerce integration fails with invalid action
  code: |-
    mockData.enhancedEcommerce = true;

    mock('copyFromDataLayer', key => {
      if (key === 'ecommerce') return {
        invalid: true
      };
    });

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('logToConsole').wasCalledWith('Facebook Pixel: Most recently pushed "ecommerce" object must be one of types "detail", "add", "checkout" or "purchase".');
    assertApi('gtmOnFailure').wasCalled();
    assertApi('gtmOnSuccess').wasNotCalled();
- name: Enhanced Ecommerce ViewContent works
  code: "mockData.enhancedEcommerce = true;\nmockData.objectPropertyList = {};\n\n\
    mock('copyFromDataLayer', key => {\n  if (key === 'ecommerce') return {\n    currencyCode:\
    \ 'EUR',\n    detail: {\n      products: mockEec.gtm.products\n    }\n  };\n});\n\
    \nlet index = 0;\nmock('copyFromWindow', key => {\n  if (key === 'fbq') return\
    \ function() {\n    if (arguments[0] === 'trackSingle') {\n      assertThat(arguments[1],\
    \ 'trackSingle called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingle called with incorrect event name').isEqualTo('ViewContent');\n\
    \      assertThat(arguments[3], 'trackSingle called with incorrect event parameters').isEqualTo(mockEec.fb);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingle called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Enhanced Ecommerce AddToCart works
  code: "mockData.enhancedEcommerce = true;\nmockData.objectPropertyList = {};\n\n\
    mock('copyFromDataLayer', key => {\n  if (key === 'ecommerce') return {\n    currencyCode:\
    \ 'EUR',\n    add: {\n      products: mockEec.gtm.products\n    }\n  };\n});\n\
    \nlet index = 0;\nmock('copyFromWindow', key => {\n  if (key === 'fbq') return\
    \ function() {\n    if (arguments[0] === 'trackSingle') {\n      assertThat(arguments[1],\
    \ 'trackSingle called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingle called with incorrect event name').isEqualTo('AddToCart');\n\
    \      assertThat(arguments[3], 'trackSingle called with incorrect event parameters').isEqualTo(mockEec.fb);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingle called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Enhanced Ecommerce InitiateCheckout works
  code: "mockData.enhancedEcommerce = true;\nmockEec.fb.num_items = 3;\nmockData.objectPropertyList\
    \ = {};\n\nmock('copyFromDataLayer', key => {\n  if (key === 'ecommerce') return\
    \ {\n    currencyCode: 'EUR',\n    checkout: {\n      products: mockEec.gtm.products\n\
    \    }\n  };\n});\n\nlet index = 0;\nmock('copyFromWindow', key => {\n  if (key\
    \ === 'fbq') return function() {\n    if (arguments[0] === 'trackSingle') {\n\
    \      assertThat(arguments[1], 'trackSingle called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingle called with incorrect event name').isEqualTo('InitiateCheckout');\n\
    \      assertThat(arguments[3], 'trackSingle called with incorrect event parameters').isEqualTo(mockEec.fb);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingle called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Enhanced Ecommerce Purchase works
  code: "mockData.enhancedEcommerce = true;\nmockEec.fb.num_items = 3;\nmockData.objectPropertyList\
    \ = {};\n\nmock('copyFromDataLayer', key => {\n  if (key === 'ecommerce') return\
    \ {\n    currencyCode: 'EUR',\n    purchase: {\n      products: mockEec.gtm.products\n\
    \    }\n  };\n});\n\nlet index = 0;\nmock('copyFromWindow', key => {\n  if (key\
    \ === 'fbq') return function() {\n    if (arguments[0] === 'trackSingle') {\n\
    \      assertThat(arguments[1], 'trackSingle called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingle called with incorrect event name').isEqualTo('Purchase');\n\
    \      assertThat(arguments[3], 'trackSingle called with incorrect event parameters').isEqualTo(mockEec.fb);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingle called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Object merge with variable and list works
  code: "mockData.objectPropertiesFromVariable = {\n  prop1: 'var1',\n  prop2: 'var2',\n\
    \  prop3: 'var3'\n};\n\nconst expected = {\n  prop1: 'val1',\n  prop2: 'val2',\n\
    \  prop3: 'var3'\n};\n\nlet index = 0;\nmock('copyFromWindow', key => {\n  if\
    \ (key === 'fbq') return function() {\n    if (arguments[0] === 'trackSingle')\
    \ {\n      assertThat(arguments[1], 'trackSingle called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingle called with incorrect event name').isEqualTo('PageView');\n\
    \      assertThat(arguments[3], 'trackSingle called with incorrect event parameters').isEqualTo(expected);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingle called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Object merge with variable, list and eec works
  code: "mockData.enhancedEcommerce = true;\nmockData.objectPropertiesFromVariable\
    \ = {\n  content_type: 'product_group'\n};\nmockData.objectPropertyList = [{\n\
    \  name: 'currency',\n  value: 'USD'\n}];\nmockEec.fb.num_items = 3;\nmockEec.fb.content_type\
    \ = 'product_group';\nmockEec.fb.currency = 'USD';\n\nmock('copyFromDataLayer',\
    \ key => {\n  if (key === 'ecommerce') return {\n    currencyCode: 'EUR',\n  \
    \  purchase: {\n      products: mockEec.gtm.products\n    }\n  };\n});\n\nlet\
    \ index = 0;\nmock('copyFromWindow', key => {\n  if (key === 'fbq') return function()\
    \ {\n    if (arguments[0] === 'trackSingle') {\n      assertThat(arguments[1],\
    \ 'trackSingle called with incorrect pixel ID').isEqualTo(mockData.pixelId.split(',')[index]);\n\
    \      assertThat(arguments[2], 'trackSingle called with incorrect event name').isEqualTo('Purchase');\n\
    \      assertThat(arguments[3], 'trackSingle called with incorrect event parameters').isEqualTo(mockEec.fb);\n\
    \      index += 1;\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertThat(index, 'trackSingle called incorrect number of times').isEqualTo(2);\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Send event ID
  code: "mockData.eventId = 'eventId';\n\nmock('copyFromWindow', key => {\n  if (key\
    \ === 'fbq') return function() {\n    if (arguments[0] === 'trackSingle') {\n\
    \      assertThat(arguments[4], 'eventID not included in hit').isEqualTo({eventID:\
    \ mockData.eventId});\n    }\n  };\n});\n     \n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\n\n// Verify that the tag finished successfully.\n\
    assertApi('gtmOnSuccess').wasCalled();"
setup: "const mockData = {\n  pixelId: '12345,23456',\n  eventName: 'standard',\n\
  \  standardEventName: 'PageView',\n  customEventName: 'custom',\n  variableEventName:\
  \ 'standard',\n  consent: true,\n  advancedMatching: false,\n  advancedMatchingList:\
  \ [{name: 'ct', value: 'Helsinki'},{name: 'cn', value: 'Finland'},{name: 'external_id',\
  \ value: 'UserId'}],\n  objectPropertiesFromVariable: false,\n  objectPropertyList:\
  \ [{name: 'prop1', value: 'val1'},{name: 'prop2', value: 'val2'}],\n  disableAutoConfig:\
  \ false,\n  disablePushState: false,\n  enhancedEcommerce: false,\n  eventId: ''\n\
  };\n\nconst mockEec = {\n  gtm: {  \n    products: [{\n      id: 'i1',\n      name:\
  \ 'n1',\n      category: 'c1',\n      price: '1.00',\n      quantity: 1\n    },{\n\
  \      id: 'i2',\n      name: 'n2',\n      category: 'c2',\n      price: '2.00',\n\
  \      quantity: 2\n    }]\n  },\n  fb: {\n    content_type: 'product',\n    contents:\
  \ [{\n      id: 'i1',\n      quantity: 1\n    },{\n      id: 'i2',\n      quantity:\
  \ 2\n    }],\n    currency: 'EUR',\n    value: 5.00\n  }\n};\n\nconst scriptUrl\
  \ = 'https://connect.facebook.net/en_US/fbevents.js';\n\n// Create injectScript\
  \ mock\nlet success, failure;\nmock('injectScript', (url, onsuccess, onfailure)\
  \ => {\n  success = onsuccess;\n  failure = onfailure;\n  onsuccess();\n});\n\n\
  mock('copyFromWindow', key => {\n  if (key === 'fbq') return () => {};\n});"


___NOTES___

Created on 18/05/2019, 21:57:16


