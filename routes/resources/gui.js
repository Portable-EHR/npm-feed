/*
 * Copyright (c) Portable EHR inc, 2019
 */

// region utilities

const domParser = new DOMParser();

const genderOb = {
    F:0,
    M:1,
    N:2
};
const languageOb = {    //  Filled in installSinglePage() from /feed/languages (only those supported)

};

const removeChildren = node => {
    while (node.firstChild) {
        node.removeChild(node.firstChild);
    }
    return node;
};

const handleFeedApiResponse = far => {
    const { requestStatus } = far;
    if ('OK' === requestStatus.status) {
        return far.responseContent;
    }
    throw Error(`[${requestStatus.status}] : ${requestStatus.message}`);
};

const nth = i =>
    ['1st', '2nd', '3rd'][i]  ||  `${i+1}th`;

const niceJSON = ob =>
                        JSON.stringify(ob, null, 4);

//  generator:  Returns an iterator yielding an ob either a specific number of times, or ad lib if times is undefined.
const repeat = function* (ob, times) {      //  thanks python !
    if (undefined === times) {
        while (true) {
            yield ob;
        }
    }
    else {
        for (let i=0; i < times; i++) {
            yield ob;
        }
    }
};

//  generator:  Returns an iterator returning elements from the first iterable until it is exhausted,
//              then proceeds to the next iterable, until all of the iterables are exhausted.
const chain = function* (...iterables) {      //  thanks python !
    for (let iterable of iterables) {
        for (let item of iterable) {
            yield item;
        }
    }
};

//  generator:  Returns an iterator that aggregates elements from each of the iterables.
//              Stops when the shortest iterable is exhausted.
const zip = function* (...iterables) {      //  thanks python !
    const iterators = iterables.map( iterable =>
        iterable[Symbol.iterator]() );
    while (iterators.length) {  //  just skip if there's no iterator
        const result = [];
        for (let iterator of iterators) {
            const element = iterator.next();
            if (element.done) {
                return;
            }
            result.push(element.value);
        }
        yield result;
    }
};

const dateAdd = Object.freeze({      //  Write if flat so that IDE can follow. It can't when .reduce() is used.
    milli:  (quantity, origDate) => {                       const newDate = origDate ? new Date(origDate) : new Date();
            newDate.setTime(newDate.getTime() + quantity);                                          return  newDate; },

    second: (quantity, origDate) => {                       const newDate = origDate ? new Date(origDate) : new Date();
            newDate.setTime(newDate.getTime() + quantity * 1000);                                   return  newDate; },

    minute: (quantity, origDate) => {                       const newDate = origDate ? new Date(origDate) : new Date();
            newDate.setTime(newDate.getTime() + quantity * 60000);                                  return  newDate; },

    hour:   (quantity, origDate) => {                       const newDate = origDate ? new Date(origDate) : new Date();
            newDate.setTime(newDate.getTime() + quantity * 3600000);                                return  newDate; },

    day:    (quantity, origDate) => {                       const newDate = origDate ? new Date(origDate) : new Date();
            newDate.setDate(newDate.getDate() + quantity);                                          return  newDate; },

    week:   (quantity, origDate) => {                       const newDate = origDate ? new Date(origDate) : new Date();
            newDate.setDate(newDate.getDate() + 7 * quantity);                                      return  newDate; },

    month:  (quantity, origDate) => {                       const newDate = origDate ? new Date(origDate) : new Date();
            newDate.setMonth(newDate.getMonth() + quantity);                                 return newDate; },

    quarter:(quantity, origDate) => {                       const newDate = origDate ? new Date(origDate) : new Date();
            newDate.setMonth(newDate.getMonth() + 3 * quantity);                             return  newDate; },

    year:   (quantity, origDate) => {                       const newDate = origDate ? new Date(origDate) : new Date();
            newDate.setFullYear(newDate.getFullYear() + quantity);                             return  newDate; },
});

//endregion

window.addEventListener("load", ()=>{
    document.getElementById("loginForm").addEventListener("submit", handleLoginSubmitRes);
    document.getElementById("logoff").addEventListener('click', () => {
                                                                                                location.reload(); });
});

const buildIdIssuersOb = (idIssuers) => {
    const issuerKinds = [],
          issuersByKind = {};

    for (let idIssuer of idIssuers) {
        const { issuerKind, issuerAlias, country, state, isTechnical } = idIssuer;
        if (isTechnical) {
            continue;
        }

        //region extra fields

        idIssuer.hasVersion = ('healthCare'===issuerKind && 'CA_QC_RAMQ'===issuerAlias) ? 'never' :
                              ('healthCare'===issuerKind && 'CA_QC_OHIP'===issuerAlias) ? 'optional' : 'always';
        idIssuer.hasExpiration = 'always';
        idIssuer.expirationScale =  ('healthCare'===issuerKind && 'CA_QC_RAMQ'===issuerAlias) ? 'month' :
                                    ('passport'===issuerKind)                                 ? 'day'   : 'day';
        //endregion

        let issuerByKind = issuersByKind[issuerKind];
        if ( ! issuerByKind ) {
            issuerByKind = issuersByKind[issuerKind] = {};
            Object.defineProperty(issuerByKind, '_index', {value: issuerKinds.length});
            Object.defineProperty(issuerByKind, '_byCountry', {value:{}});
            Object.defineProperty(issuerByKind, '_countries', {value:[]});
            issuerKinds.push(issuerKind);
        }
        issuerByKind[issuerAlias] = idIssuer;

        let issuerByCountry = issuerByKind._byCountry[country];
        if ( ! issuerByCountry ) {
            issuerByCountry = issuerByKind._byCountry[country] = {};
            Object.defineProperty(issuerByCountry, '_index', {value: issuerByKind._countries.length});
            Object.defineProperty(issuerByCountry, '_byState', {value:{}});
            Object.defineProperty(issuerByCountry, '_states', {value:[]});
            issuerByKind._countries.push(country);
        }
        issuerByCountry[issuerAlias] = idIssuer;

        let issuerByState = issuerByCountry._byState[state];
        if ( ! issuerByState ) {
            issuerByState = issuerByCountry._byState[state] = {};
            Object.defineProperty(issuerByState, '_index', {value: issuerByCountry._states.length});
            issuerByCountry._states.push(state);
        }
        issuerByState[issuerAlias] = idIssuer;
    }
    return { issuerKinds, issuersByKind };
};

const fetchCountries = async () => {
    return await fetch(document.baseURI+'/../feed/countries',  {
        method: 'POST',
    }).then(response =>
        response.json()                                 //  When the page is loaded convert it to json
    ).then(jsOb => {
        return document.countries = handleFeedApiResponse(jsOb);
    }).catch(e => {
        console.log(`Failed to fetch countries :  ${e.message}`); });
};

const fetchLanguages = async () => {
    return await fetch(document.baseURI+'/../feed/languages',  {
        method: 'POST',
    }).then(response =>
        response.json()                                 //  When the page is loaded convert it to json
    ).then(jsOb => {
        return document.languages = handleFeedApiResponse(jsOb);
    }).catch(e => {
        console.log(`Failed to fetch languages :  ${e.message}`); });
};


const fetchAliases = async jwt => {
    // the feedAliases list is loaded by calling POST(feed/aliases)
    return await fetch(document.baseURI+'/../feed/aliases', {
        method: 'POST',
        headers: {
            Authorization: "Bearer " + jwt,
            Accept: 'application/json'
        }
    }).then(response =>
        response.json()                                     //  When the page is loaded convert it to json
    ).then(jsOb => {
        /*return */document.feedAliases = handleFeedApiResponse(jsOb);
        return document.feedAliases;
    }).catch(e => {
        console.log('Failed to fetch aliases : ', e); });
};

const fetchIdIssuers = async jwt => {
    return await fetch(document.baseURI+'/../feedhub/idissuers',  {
        method: 'POST',
        headers: {
            Authorization: "Bearer " + jwt,
            'content-type': 'application/json',
        },
        redirect: 'follow',
        body: JSON.stringify({
            feedAlias:document.feedAliases[0],      //  any allowed, for idIssuers, really.
            command: "pullBundle",
            parameters: {
                offset: 0,
                maxItem: 1000000000,
            }
        })
    }).then(response =>
        response.json()                             //  When the page is loaded convert it to json
    ).then(jsOb => {
        document.idIssuers = handleFeedApiResponse(jsOb).results;
        document.idIssuersOb = buildIdIssuersOb(document.idIssuers);
        console.log(document.idIssuersOb);
        return document.idIssuersOb;
    }).catch(e => {
        console.log(`Failed to fetch idIssuers :  ${e.message}`); });
};

async function handleLoginSubmitRes(e) {
    let username = document.getElementById("username").value;
    let password = document.getElementById("password").value;

    e.preventDefault();

    const jwt = await fetch(document.baseURI,  {
        method: 'POST',
        headers: {
            'content-type': 'application/json',
        },
        redirect: 'follow',
        body: JSON.stringify({username, password})
    }).then(response =>
        response.json()                                             //  When the page is loaded convert it to json
    ).then(jsOb => {
        const jwt = handleFeedApiResponse(jsOb).token;
        sessionStorage.setItem("jwt", jwt);
        return jwt;
    }).catch(e => {
                    console.log(`Login Failed attempting to aquire jwt :  ${e.message}`); });

    if (jwt) {
        try {
            if (await fetchCountries()   &&  await fetchLanguages()  &&
                await fetchAliases(jwt)  &&  await fetchIdIssuers(jwt)) {

                document.getElementById('userId').innerHTML = username;
                document.getElementById("pageCtrl").classList.remove('inactive');

                installSinglePage();
            }
            else {
                console.log(`Login failed`)
            }
        }
        catch (e) {
            console.log(`Login failed installSinglePage()`, e);
        }
    }
}

function installSinglePage() {
    document.title = "Dispensary Proxy";
    //  ../resources/singlePageTemplates.html is fetched, parsed and installed in main in replacement of login form,
    //  then its "full-single" web component is instantiated and added to body.

    fetch('../resources/singlePageTemplates.html'
    ).then(response =>
        response.text()                             //  When the page is loaded convert it to text
    ).then(html =>  {

        const main = document.body.querySelector('main');
        main.innerHTML = html;             //  parse singlePageTemplates.html and install it in body main

        const countryList = document.getElementById("countryList");
        countryList.appendChild(new Option('CA | Canada', 'CA'));
        countryList.appendChild(new Option('US | UnitedStates', 'US'));
        for (let country of document.countries) {
            const { iso2 } = country;
            if (iso2 !== 'CA' &&  iso2 !== 'US') {
                countryList.appendChild(new Option(iso2 +' | '+ country.name, iso2));
            }
        }

        const languageList = document.getElementById("languageList");
        let i = 0;
        for (let language of document.languages) {
            languageList.appendChild(new Option(language.name +' | '+ language.endonyms, language.iso2));
            languageOb[language.iso2] = i++;
        }
        // console.log(`in installSingePage() languageList`, languageList);

        const fullSingle = document.createElement('full-singlepage');
        main.appendChild(fullSingle);

    }).catch(e => {
                    console.log('Failed to fetch and install singlePageTemplates : ', e); })
}


//  The full-single web component, based on full-single-template from singlePageTemplates.html
customElements.define('full-singlepage',
    class extends HTMLElement {
        constructor() {
            super();
            const fullSingle = document.getElementById('full-singlepage-template').content.cloneNode(true);

            this.attachShadow({mode: 'open'})
                .appendChild(fullSingle);
        }
        // noinspection JSUnusedGlobalSymbols
        connectedCallback() {
            const { shadowRoot } = this;

            // const showPatientList = this.showPatientList.bind(this);

            try {
                //  Fill the feedAliases selector with the list fetched.
                const   patientTabLink = shadowRoot.getElementById("patientTabLink"),
                        feedAliasesSelect = this.feedAliasesSelect = shadowRoot.getElementById("feedAliases");

                feedAliasesSelect.addEventListener("change", function() {
                    document.feedAlias = this.value;
                });

                for (let feedAlias of document.feedAliases) {
                    feedAliasesSelect.appendChild(new Option(feedAlias, feedAlias));
                }
                feedAliasesSelect.firstChild.selected = true;

                const tablinks = shadowRoot.getElementById("theTabLinkList").children; // <ul> elements' <li>s.
                for (let i=1; i < tablinks.length; i++) {   //  i=1; Skip the feedAlias selector

                    tablinks[i].children[0].addEventListener("click", function(e) {
                        // Get all elements with class="tab" and hide them
                        const tabs = Array.from(shadowRoot.getElementById("theTabs").children);
                        for (let tab of tabs) {
                            tab.classList.remove("active");
                        }
                        // Get all <li> children of <ul> element with id="theTabLinkList" and remove the class "active"
                        const tablinks = Array.from(shadowRoot.getElementById("theTabLinkList").children);
                        for (let tablink of tablinks) {
                            tablink.classList.remove("active");
                        }

                        // Show the current tab, and add an "active" class to the button that opened the tab
                        const tab_id = this.getAttribute("href").slice(1);
                        // console.log("tab_id", tab_id);
                        shadowRoot.getElementById(tab_id).classList.add("active");
                        this.parentNode.classList.add("active");

                        e.preventDefault();
                    });
                }

                //region patient

                const   patientSearchAndSelect = shadowRoot.getElementById("patientSearchAndSelect");


                patientTabLink.addEventListener('click', () => {
                    patientSearchAndSelect.searchStrInput.focus();
                });

                patientSearchAndSelect.feedAliasElement = feedAliasesSelect;
                patientSearchAndSelect.addEventListener('change', () => {
                    // console.log('in patientSearchAndSelect onchange', patientSearchAndSelect.selectedResult);
                    // editPatient(patientSearchAndSelect.selectedResult);
                });


               //endregion

                //region staff

                const   staffTabLink = shadowRoot.getElementById("staffTabLink"),
                        staffSearchAndSelect = shadowRoot.getElementById("staffSearchAndSelect");

                staffTabLink.addEventListener('click', () => {
                    staffSearchAndSelect.searchStrInput.focus();
                });

                staffSearchAndSelect.feedAliasElement = feedAliasesSelect;
                staffSearchAndSelect.addEventListener('change', () => {
                    try {

                    // console.log('in staffSearchAndSelect onchange', staffSearchAndSelect.selectedResult);
                    // editStaff(staffSearchAndSelect.selectedResult);

                    } catch (e) { console.log(`in staffSearchAndSelect onchange`, e); }
                });

                //endregion
            }
            catch (e) {
                        console.log('Failed adding event listeners to tablinks : ', e); }
        }

    });


class CollapsibleDiv extends HTMLElement {

    constructor() {
        super();
        const clonedTemplateContent = document.getElementById('collapsible-div-template').content.cloneNode(true);
        this.attachShadow({mode: 'open'})
            .appendChild(clonedTemplateContent);
    }

    // noinspection JSUnusedGlobalSymbols
    connectedCallback() {
        const {shadowRoot} = this;

        this.legendEl = shadowRoot.getElementById("legend").assignedNodes()[0];
        this.originalLegend = this.legendEl.innerHTML;
        this.collapsibleEl = shadowRoot.getElementById("collapsible").assignedNodes()[0];
        // console.log('Collapsible Legend', this.originalLegend);
        // console.log('Collapsible Element', this.collapsibleEl);

        const collapsbutton = shadowRoot.getElementById("collapsbutton");
        if ( ! collapsbutton.hasAttribute('tabindex')) {
            collapsbutton.tabIndex = 0;
        }
        collapsbutton.addEventListener('click', function () {
            this.classList.toggle("uncollapsed");

            const nextStyle = this.nextElementSibling.style;
            nextStyle.display =  nextStyle.display === "flex"  ?  "none"  :  "flex";
        });
        collapsbutton.addEventListener('keydown', e => {
            if (e.code==='Enter' || e.code ==='Space') {
                e.preventDefault();
                collapsbutton.click();
            }
        });

        this.collapsibleEl.addEventListener('change', () => {
            const digest = this.collapsibleEl.digestString;
            if  (undefined !== digest) {
                this.legendEl.innerHTML = `${this.originalLegend}${digest ? (' : ' + digest) : ''}`;
            }
        });
    }
}
//  The collapsible-div web component, based on collapsible-div-template from singlePageTemplates.html
customElements.define('collapsible-div', CollapsibleDiv);

class SearchAndSelect extends HTMLElement {
     constructor() {
        super();
        const clonedTemplateContent = document.getElementById('search-and-select-template').content.cloneNode(true);

        this.attachShadow({mode: 'open'})
            .appendChild(clonedTemplateContent);

    }

    // noinspection JSUnusedGlobalSymbols
    connectedCallback() {
        const   self = this,
              { shadowRoot } = this,
                searchStrInput = this.searchStrInput = shadowRoot.getElementById('searchStrInput'),
                searchedList = this.searchedList = shadowRoot.getElementById('searchedList');

        this.sentSeq = 0;
        this.receivedSeq = 0;

        //  Save apart the unique base item unit, with the slot assignedNodes, in-lined in.
        //  It will be used as this add-remove-list base item subtree to clone, each time .addItem() is called.
        this.baseListItem = searchedList.firstElementChild;

        //  Empty the list to start clean.
        removeChildren(searchedList);
        searchedList.activeItem = null;


        const searchAndSelect = shadowRoot.getElementById('searchAndSelect');
        const hasGainedAttention = () => {
            searchAndSelect.classList.add('under_attention');
        };
        const hasLostAttention   = () => {
            searchAndSelect.classList.remove('under_attention');
        };

        searchAndSelect.addEventListener('pointerenter',    () => {
            this.hasPointerOn = true;
            hasGainedAttention();
        });
        searchAndSelect.addEventListener('focusin',         () => {
            this.hasFocusIn = true;
            hasGainedAttention();
        });
        searchAndSelect.addEventListener('pointerleave',    () => {
            this.hasPointerOn = false;
            if ( ! this.hasFocusIn) {
                hasLostAttention();
            }
        });
        searchAndSelect.addEventListener('focusout',        () => {
            this.hasFocusIn = false;
            if ( ! this.hasPointerOn) {
                hasLostAttention();
            }
        });

        shadowRoot.getElementById("searchForm").addEventListener("submit", async function(e) {
            e.preventDefault();                             //  without this line, default POST is sent to /login.
            await self.processSearchStr(true);
        });

        shadowRoot.getElementById('searchSubmit').tabIndex = -1;
        searchedList.tabIndex = -1;

        searchStrInput.addEventListener('input', async () => {
            if (searchStrInput.value.length > 1) {
                await self.processSearchStr();
            }
        });
        searchStrInput.focus();
    }
    get stuffKindSearched() {
         return '';
    }
    get searchStr() {
        return this.searchStrInput.value;
    }
    get fetchURI()  {                                                                       //  Must be overridden
                        return '';  }
    get fetchInit() {                                                                       //  Must be overridden
                        return {};  }

    async processSearchStr() {
        const { seq, searchResults } = await this.fetchSearchResults();
        //  Some SQL searches are longer to perform than others, and searchResults may arrived out of order.
        //  Make sure to buildList only with searchResults from searchStr more recent than those already displayed.
        if (seq > this.receivedSeq) {
            this.receivedSeq = seq;
            this.buildList(searchResults);
        }
    }

    async fetchSearchResults() {
        return await fetch(this.fetchURI, this.fetchInit
        ).then(response =>
            response.json()                                 //  When the page is loaded convert it to json
        ).then(jsOb =>  {
            return handleFeedApiResponse(jsOb);
        }).catch(() => {
            return [];
        });
    }

    innerHTMLfrom(result) {                                                                 //  Must be overridden
         return !result || '';      //  return '', really.
    }
    get selectedResult() {
                            return this.searchedList.activeItem.searchResult; }
    updateSelectedResult(result) {
        const { activeItem } = this.searchedList;
        activeItem.searchResult = result;
        activeItem.innerHTML = this.innerHTMLfrom(result);
    }

    scaleListToSibling() {
         this.searchedList.classList.add('list_scaled_to_sibling');
    }
    buildList(searchResults, onSubmit) {
        const { searchedList, baseListItem } = this,
                self = this,
                itemOfLi =      el  =>
                                        el.parentElement,
                liOfItem =      el  =>
                                        el.lastElementChild,
                tooltipOfItem = el  =>
                                        el.firstElementChild,
                onClick = function() {
                    let { activeItem } = searchedList;
                    if (activeItem) {
                        activeItem.classList.remove('selected');
                    }

                    searchedList.activeItem = this;                     //  'this' is the clicked <li>
                    this.classList.add("selected");

                    if (searchedList.prevFocus) {
                        searchedList.prevFocus.tabIndex = -1;
                    }
                    this.tabIndex = 0;
                    this.focus();
                    searchedList.prevFocus = this;

                    self.dispatchEvent(new Event('change', ));
                },
                onKeyDown = function(e) {
                    if (e.code==='Enter' || e.code ==='Space') {
                        e.preventDefault();
                        this.click();
                    }
                    else if (e.code==='ArrowDown') {
                        e.preventDefault();
                        if (liOfItem(itemOfLi(this).parentNode.lastElementChild) !== this) {
                            this.tabIndex = -1;
                            const nextLi = liOfItem(itemOfLi(this).nextElementSibling);
                            nextLi.tabIndex = 0;
                            nextLi.focus();
                            searchedList.prevFocus = nextLi;
                        }
                    }
                    else if (e.code==='ArrowUp') {
                        e.preventDefault();
                        if (liOfItem(itemOfLi(this).parentNode.firstElementChild) !== this) {
                            this.tabIndex = -1;
                            const previousLi = liOfItem(itemOfLi(this).previousElementSibling);
                            previousLi.tabIndex = 0;
                            previousLi.focus();
                            searchedList.prevFocus = previousLi;
                        }
                    }
                },
                onPointerEnter = function() {
                    //  li.<div class="tooltiped">.<pre class="tooltip">
                    tooltipOfItem(itemOfLi(this)).innerHTML = niceJSON(this.searchResult);
                   // console.log(`In SearchAndSelect buildList() on pointerenter : \n`, this.parentElement.firstElementChild, this.parentElement.firstElementChild.innerHTML);
                };

        // remove all element of the list ahead of refilling it
        removeChildren(searchedList);
        searchedList.activeItem = null;

        for (let result of searchResults) {
            const clonedNode = baseListItem.cloneNode(true),
                  item = clonedNode.querySelector("li");
            item.searchResult = result;
            item.innerHTML = this.innerHTMLfrom(result);
            item.addEventListener('click', onClick);
            item.addEventListener('keydown', onKeyDown);
            item.addEventListener('pointerenter', onPointerEnter);
            searchedList.appendChild(clonedNode);
        }

        if (searchResults.length) {
            const firstLi = liOfItem(searchedList.firstElementChild);

            firstLi.tabIndex = 0;
            searchedList.prevFocus = firstLi;

            if (onSubmit) {
                firstLi.focus();
            }
        }
    }
}

//  The patient-search-and_select web component, based on search-and-select-template from singlePageTemplates.html
customElements.define('patient-search-and-select', class extends SearchAndSelect {

    connectedCallback() {
        super.connectedCallback();
        this.searchStrInput.placeholder = 'Search Patient';
    }

    get stuffKindSearched() {
        return 'Patient ';
    }
    get fetchURI() {
        return document.baseURI+'/../feed/patient';
    }
    get fetchInit() {

        return {
            method: 'POST',
            headers: {
                Authorization: "Bearer " + sessionStorage.getItem('jwt'),
                'content-type': 'application/json',
            },
            redirect: 'follow',
            body: JSON.stringify({
                feedAlias: this.feedAliasElement.value,
                command: "search",
                parameters: { seq: ++this.sentSeq, searchStr: this.searchStr },
            })
        };
    }
    innerHTMLfrom(result) {                                                                 //  Overriding base class'
        const { demographics={}, identifiedBy=[], locatedWith:{ contact={} }={} } = result,
              { name={} } = demographics,
                hcin = identifiedBy.filter(({issuerKind}) =>
                                                            ('healthCare' === issuerKind))[0],
                pprt = identifiedBy.filter(({issuerKind}) =>
                                                            ('passport' === issuerKind))[0];
        const phone = num =>
                            10 === num.length ?  `${num.slice(0,3)}-${num.slice(3,6)}-${num.slice(6)}` :
                             7 === num.length ?  `${num.slice(0,3)}-${num.slice(3)}`                   : num;

        // console.log(result);
        return (name.firstName + ' ' +
            (name.middleName ? name.middleName + ' ' : '') +
            name.familyName +
            (demographics.dateOfBirth   ?  `,  <span title="Birth date">${ demographics.dateOfBirth.slice(0,10) }</span>`
                                        :  '') +
            (hcin && hcin.number
                                    ?  `, <span title="Healthcare insurance number">&#x1fa79;&NonBreakingSpace;${ hcin.number }</span>`
                                    :  '') +                                    //  &#x1fa79; : adhesive bandage
            (pprt && pprt.number  &&  ( ! (hcin && hcin.number)  ||  false)           //  pprt.number matches searchStr
                                    ?  `, <span title="Passport">&#x1f310;&NonBreakingSpace;${ pprt.number }</span>`
                                    :  '') +                 //  &#x1f310; : globe with meridians
            // (pprt && pprt.number  ?  `, <span title="Passport">&#x1f6c2;&NonBreakingSpace;${ pprt.number }</span>`
            //                       :  '') +                 //  &#x1f6c2; : passport control
            (contact.mobilePhone    ?  `, <span title="Mobile phone">&#x1f4f1;&NonBreakingSpace;${ phone(contact.mobilePhone) }</span>`
                                    :  '') +                     //  &#x1f4f1; : mobile phone
            (contact.landPhone  &&  ( ! contact.mobilePhone  ||  false)      //  landPhone matches searchStr
                                    ?  `, <span title="Land phone">&#x1f4de;&NonBreakingSpace;${ phone(contact.landPhone) }</span>`
                                    :  '') +                   //  &#x1f4de; :  telephone receiver
            // (contact.email        ?  `, <span title="E-mail">${ contact.email }</span>`
            //                       :  '') +               //  &#x1f4e7; :  email
            '');                                                                    //  &#x1f37c : baby bottle
    }
});

//  The patient-search-and_select web component, based on search-and-select-template from singlePageTemplates.html
customElements.define('staff-search-and-select', class extends SearchAndSelect {

    connectedCallback() {
        super.connectedCallback();
        this.searchStrInput.placeholder = 'Search Staff';
    }

    get stuffKindSearched() {
        return 'Staff ';
    }
    get fetchURI() {
        return document.baseURI+'/../feed/practitioner';
    }
    get fetchInit() {
        return {
            method: 'POST',
            headers: {
                Authorization: "Bearer " + sessionStorage.getItem('jwt'),
                'content-type': 'application/json',
            },
            redirect: 'follow',
            body: JSON.stringify({
                feedAlias: this.feedAliasElement.value,
                command: "search",
                parameters: { seq: ++this.sentSeq,  searchStr: this.searchStr }
            })
        };
    }
    innerHTMLfrom(result) {                                                                 //  Overriding base class'
        const { firstName, lastName, middleName, dateOfBirth, practices=[] } = result,
                prac = practices.filter(({issuerKind})  =>
                                                            ('practiceLicense' === issuerKind))[0];
        // console.log(result);
        return (firstName + ' ' +
            (middleName ? middleName + ' ' : '') +
            lastName +
            (dateOfBirth    ?  `,  <span title="Birth date">${ dateOfBirth.slice(0,10) }</span>`
                            :  '') +
            (prac && prac.number
                            ?  `, <span title="Licence practice number">&#x1FA7A;&NonBreakingSpace;${ prac.number }</span>`
                            :  '') +                                //  &#x1FA7A; : stethoscope
            '');
    }
});








