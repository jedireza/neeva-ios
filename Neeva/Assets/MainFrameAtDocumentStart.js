!function(e){var t={};function i(n){if(t[n])return t[n].exports;var a=t[n]={i:n,l:!1,exports:{}};return e[n].call(a.exports,a,a.exports,i),a.l=!0,a.exports}i.m=e,i.c=t,i.d=function(e,t,n){i.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:n})},i.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},i.t=function(e,t){if(1&t&&(e=i(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var n=Object.create(null);if(i.r(n),Object.defineProperty(n,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var a in e)i.d(n,a,function(t){return e[t]}.bind(null,a));return n},i.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return i.d(t,"a",t),t},i.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},i.p="",i(i.s=12)}({12:function(e,t,i){e.exports=i(13)},13:function(e,t,i){"use strict";var n=null,a=null;const r=/^http:\/\/localhost:\d+\/reader-mode\/page/;function s(e){a&&a.theme&&document.body.classList.remove(a.theme),e&&e.theme&&document.body.classList.add(e.theme),a&&a.fontSize&&document.body.classList.remove("font-size"+a.fontSize),e&&e.fontSize&&document.body.classList.add("font-size"+e.fontSize),a&&a.fontType&&document.body.classList.remove(a.fontType),e&&e.fontType&&document.body.classList.add(e.fontType),a=e}function o(){s(JSON.parse(document.body.getAttribute("data-readerStyle"))),function(){var e=document.getElementById("reader-message");e&&(e.style.display="none");var t=document.getElementById("reader-header");t&&(t.style.display="block");var i=document.getElementById("reader-content");i&&(i.style.display="block")}(),function(){var e=document.getElementById("reader-content");if(e)for(var t=window.innerWidth,i=e.offsetWidth,n=t+"px !important",a=function(e){e._originalWidth||(e._originalWidth=e.offsetWidth);var a=e._originalWidth;a<i&&a>.55*t&&(a=t);var r=Math.max((i-t)/2,(i-a)/2)+"px !important",s="max-width: "+n+";width: "+(a+"px !important")+";margin-left: "+r+";margin-right: "+r+";";e.style.cssText=s},r=document.querySelectorAll(".content p > img:only-child, .content p > a:only-child > img:only-child, .content .wp-caption img, .content figure img"),s=r.length;--s>=0;){var o=r[s];o.width>0?a(o):o.onload=function(){a(o)}}}()}Object.defineProperty(window.__firefox__,"reader",{enumerable:!1,configurable:!1,writable:!1,value:Object.freeze({checkReadability:function(){setTimeout((function(){if(document.location.href.match(r))webkit.messageHandlers.readerModeMessageHandler.postMessage({Type:"ReaderModeStateChange",Value:"Active"});else{if(("http:"===document.location.protocol||"https:"===document.location.protocol)&&"/"!==document.location.pathname){if(n&&n.content)return webkit.messageHandlers.readerModeMessageHandler.postMessage({Type:"ReaderModeStateChange",Value:"Available"}),void webkit.messageHandlers.readerModeMessageHandler.postMessage({Type:"ReaderContentParsed",Value:n});var e=i(14),t={spec:document.location.href,host:document.location.host,prePath:document.location.protocol+"//"+document.location.host,scheme:document.location.protocol.substr(0,document.location.protocol.indexOf(":")),pathBase:document.location.protocol+"//"+document.location.host+location.pathname.substr(0,location.pathname.lastIndexOf("/")+1)},a=(new XMLSerializer).serializeToString(document);if(a.indexOf("<frameset ")>-1)return void webkit.messageHandlers.readerModeMessageHandler.postMessage({Type:"ReaderModeStateChange",Value:"Unavailable"});var s=new e(t,(new DOMParser).parseFromString(a,"text/html"),{debug:!1});return(n=s.parse()).title=n.title.replace(/\&/g,"&amp;").replace(/\</g,"&lt;").replace(/\>/g,"&gt;").replace(/\"/g,"&quot;").replace(/\'/g,"&#039;"),webkit.messageHandlers.readerModeMessageHandler.postMessage({Type:"ReaderModeStateChange",Value:null!==n?"Available":"Unavailable"}),void webkit.messageHandlers.readerModeMessageHandler.postMessage({Type:"ReaderContentParsed",Value:n})}webkit.messageHandlers.readerModeMessageHandler.postMessage({Type:"ReaderModeStateChange",Value:"Unavailable"})}}),100)},readerize:function(){return n},setStyle:s})}),window.addEventListener("load",(function(e){document.location.href.match(r)&&o()})),window.addEventListener("pageshow",(function(e){document.location.href.match(r)&&webkit.messageHandlers.readerModeMessageHandler.postMessage({Type:"ReaderPageEvent",Value:"PageShow"})}))},14:function(e,t,i){function n(e,t){if(t&&t.documentElement)e=t,t=arguments[2];else if(!e||!e.documentElement)throw new Error("First argument to Readability constructor should be a document object.");var i;t=t||{},this._doc=e,this._articleTitle=null,this._articleByline=null,this._articleDir=null,this._articleSiteName=null,this._attempts=[],this._debug=!!t.debug,this._maxElemsToParse=t.maxElemsToParse||this.DEFAULT_MAX_ELEMS_TO_PARSE,this._nbTopCandidates=t.nbTopCandidates||this.DEFAULT_N_TOP_CANDIDATES,this._charThreshold=t.charThreshold||this.DEFAULT_CHAR_THRESHOLD,this._classesToPreserve=this.CLASSES_TO_PRESERVE.concat(t.classesToPreserve||[]),this._flags=this.FLAG_STRIP_UNLIKELYS|this.FLAG_WEIGHT_CLASSES|this.FLAG_CLEAN_CONDITIONALLY,this._debug?(i=function(e){var t=e.nodeName+" ";if(e.nodeType==e.TEXT_NODE)return t+'("'+e.textContent+'")';var i=e.className&&"."+e.className.replace(/ /g,"."),n="";return e.id?n="(#"+e.id+i+")":i&&(n="("+i+")"),t+n},this.log=function(){if("undefined"!=typeof dump){var e=Array.prototype.map.call(arguments,(function(e){return e&&e.nodeName?i(e):e})).join(" ");dump("Reader: (Readability) "+e+"\n")}else if("undefined"!=typeof console){var t=["Reader: (Readability) "].concat(arguments);console.log.apply(console,t)}}):this.log=function(){}}n.prototype={FLAG_STRIP_UNLIKELYS:1,FLAG_WEIGHT_CLASSES:2,FLAG_CLEAN_CONDITIONALLY:4,ELEMENT_NODE:1,TEXT_NODE:3,DEFAULT_MAX_ELEMS_TO_PARSE:0,DEFAULT_N_TOP_CANDIDATES:5,DEFAULT_TAGS_TO_SCORE:"section,h2,h3,h4,h5,h6,p,td,pre".toUpperCase().split(","),DEFAULT_CHAR_THRESHOLD:500,REGEXPS:{unlikelyCandidates:/-ad-|banner|breadcrumbs|combx|comment|community|cover-wrap|disqus|extra|foot|gdpr|header|legends|menu|related|remark|replies|rss|shoutbox|sidebar|skyscraper|social|sponsor|supplemental|ad-break|agegate|pagination|pager|popup|yom-remote/i,okMaybeItsACandidate:/and|article|body|column|main|shadow/i,positive:/article|body|content|entry|hentry|h-entry|main|page|pagination|post|text|blog|story/i,negative:/hidden|^hid$| hid$| hid |^hid |banner|combx|comment|com-|contact|foot|footer|footnote|gdpr|masthead|media|meta|outbrain|promo|related|scroll|share|shoutbox|sidebar|skyscraper|sponsor|shopping|tags|tool|widget/i,extraneous:/print|archive|comment|discuss|e[\-]?mail|share|reply|all|login|sign|single|utility/i,byline:/byline|author|dateline|writtenby|p-author/i,replaceFonts:/<(\/?)font[^>]*>/gi,normalize:/\s{2,}/g,videos:/\/\/(www\.)?((dailymotion|youtube|youtube-nocookie|player\.vimeo|v\.qq)\.com|(archive|upload\.wikimedia)\.org|player\.twitch\.tv)/i,nextLink:/(next|weiter|continue|>([^\|]|$)|»([^\|]|$))/i,prevLink:/(prev|earl|old|new|<|«)/i,whitespace:/^\s*$/,hasContent:/\S$/},DIV_TO_P_ELEMS:["A","BLOCKQUOTE","DL","DIV","IMG","OL","P","PRE","TABLE","UL","SELECT"],ALTER_TO_DIV_EXCEPTIONS:["DIV","ARTICLE","SECTION","P"],PRESENTATIONAL_ATTRIBUTES:["align","background","bgcolor","border","cellpadding","cellspacing","frame","hspace","rules","style","valign","vspace"],DEPRECATED_SIZE_ATTRIBUTE_ELEMS:["TABLE","TH","TD","HR","PRE"],PHRASING_ELEMS:["ABBR","AUDIO","B","BDO","BR","BUTTON","CITE","CODE","DATA","DATALIST","DFN","EM","EMBED","I","IMG","INPUT","KBD","LABEL","MARK","MATH","METER","NOSCRIPT","OBJECT","OUTPUT","PROGRESS","Q","RUBY","SAMP","SCRIPT","SELECT","SMALL","SPAN","STRONG","SUB","SUP","TEXTAREA","TIME","VAR","WBR"],CLASSES_TO_PRESERVE:["page"],_postProcessContent:function(e){this._fixRelativeUris(e),this._cleanClasses(e)},_removeNodes:function(e,t){for(var i=e.length-1;i>=0;i--){var n=e[i],a=n.parentNode;a&&(t&&!t.call(this,n,i,e)||a.removeChild(n))}},_replaceNodeTags:function(e,t){for(var i=e.length-1;i>=0;i--){var n=e[i];this._setNodeTag(n,t)}},_forEachNode:function(e,t){Array.prototype.forEach.call(e,t,this)},_someNode:function(e,t){return Array.prototype.some.call(e,t,this)},_everyNode:function(e,t){return Array.prototype.every.call(e,t,this)},_concatNodeLists:function(){var e=Array.prototype.slice,t=e.call(arguments),i=t.map((function(t){return e.call(t)}));return Array.prototype.concat.apply([],i)},_getAllNodesWithTag:function(e,t){return e.querySelectorAll?e.querySelectorAll(t.join(",")):[].concat.apply([],t.map((function(t){var i=e.getElementsByTagName(t);return Array.isArray(i)?i:Array.from(i)})))},_cleanClasses:function(e){var t=this._classesToPreserve,i=(e.getAttribute("class")||"").split(/\s+/).filter((function(e){return-1!=t.indexOf(e)})).join(" ");for(i?e.setAttribute("class",i):e.removeAttribute("class"),e=e.firstElementChild;e;e=e.nextElementSibling)this._cleanClasses(e)},_fixRelativeUris:function(e){var t=this._doc.baseURI,i=this._doc.documentURI;function n(e){if(t==i&&"#"==e.charAt(0))return e;try{return new URL(e,t).href}catch(e){}return e}var a=this._getAllNodesWithTag(e,["a"]);this._forEachNode(a,(function(e){var t=e.getAttribute("href");if(t)if(0===t.indexOf("javascript:")){var i=this._doc.createTextNode(e.textContent);e.parentNode.replaceChild(i,e)}else e.setAttribute("href",n(t))}));var r=this._getAllNodesWithTag(e,["img"]);this._forEachNode(r,(function(e){var t=e.getAttribute("src");t&&e.setAttribute("src",n(t))}))},_getArticleTitle:function(){var e=this._doc,t="",i="";try{"string"!=typeof(t=i=e.title.trim())&&(t=i=this._getInnerText(e.getElementsByTagName("title")[0]))}catch(e){}var n=!1;function a(e){return e.split(/\s+/).length}if(/ [\|\-\\\/>»] /.test(t))n=/ [\\\/>»] /.test(t),a(t=i.replace(/(.*)[\|\-\\\/>»] .*/gi,"$1"))<3&&(t=i.replace(/[^\|\-\\\/>»]*[\|\-\\\/>»](.*)/gi,"$1"));else if(-1!==t.indexOf(": ")){var r=this._concatNodeLists(e.getElementsByTagName("h1"),e.getElementsByTagName("h2")),s=t.trim();this._someNode(r,(function(e){return e.textContent.trim()===s}))||(a(t=i.substring(i.lastIndexOf(":")+1))<3?t=i.substring(i.indexOf(":")+1):a(i.substr(0,i.indexOf(":")))>5&&(t=i))}else if(t.length>150||t.length<15){var o=e.getElementsByTagName("h1");1===o.length&&(t=this._getInnerText(o[0]))}var l=a(t=t.trim().replace(this.REGEXPS.normalize," "));return l<=4&&(!n||l!=a(i.replace(/[\|\-\\\/>»]+/g,""))-1)&&(t=i),t},_prepDocument:function(){var e=this._doc;this._removeNodes(e.getElementsByTagName("style")),e.body&&this._replaceBrs(e.body),this._replaceNodeTags(e.getElementsByTagName("font"),"SPAN")},_nextElement:function(e){for(var t=e;t&&t.nodeType!=this.ELEMENT_NODE&&this.REGEXPS.whitespace.test(t.textContent);)t=t.nextSibling;return t},_replaceBrs:function(e){this._forEachNode(this._getAllNodesWithTag(e,["br"]),(function(e){for(var t=e.nextSibling,i=!1;(t=this._nextElement(t))&&"BR"==t.tagName;){i=!0;var n=t.nextSibling;t.parentNode.removeChild(t),t=n}if(i){var a=this._doc.createElement("p");for(e.parentNode.replaceChild(a,e),t=a.nextSibling;t;){if("BR"==t.tagName){var r=this._nextElement(t.nextSibling);if(r&&"BR"==r.tagName)break}if(!this._isPhrasingContent(t))break;var s=t.nextSibling;a.appendChild(t),t=s}for(;a.lastChild&&this._isWhitespace(a.lastChild);)a.removeChild(a.lastChild);"P"===a.parentNode.tagName&&this._setNodeTag(a.parentNode,"DIV")}}))},_setNodeTag:function(e,t){if(this.log("_setNodeTag",e,t),e.__JSDOMParser__)return e.localName=t.toLowerCase(),e.tagName=t.toUpperCase(),e;for(var i=e.ownerDocument.createElement(t);e.firstChild;)i.appendChild(e.firstChild);e.parentNode.replaceChild(i,e),e.readability&&(i.readability=e.readability);for(var n=0;n<e.attributes.length;n++)try{i.setAttribute(e.attributes[n].name,e.attributes[n].value)}catch(e){}return i},_prepArticle:function(e){this._cleanStyles(e),this._markDataTables(e),this._cleanConditionally(e,"form"),this._cleanConditionally(e,"fieldset"),this._clean(e,"object"),this._clean(e,"embed"),this._clean(e,"h1"),this._clean(e,"footer"),this._clean(e,"link"),this._clean(e,"aside"),this._forEachNode(e.children,(function(e){this._cleanMatchedNodes(e,/share/)}));var t=e.getElementsByTagName("h2");if(1===t.length){var i=(t[0].textContent.length-this._articleTitle.length)/this._articleTitle.length;if(Math.abs(i)<.5){(i>0?t[0].textContent.includes(this._articleTitle):this._articleTitle.includes(t[0].textContent))&&this._clean(e,"h2")}}this._clean(e,"iframe"),this._clean(e,"input"),this._clean(e,"textarea"),this._clean(e,"select"),this._clean(e,"button"),this._cleanHeaders(e),this._cleanConditionally(e,"table"),this._cleanConditionally(e,"ul"),this._cleanConditionally(e,"div"),this._removeNodes(e.getElementsByTagName("p"),(function(e){return 0===e.getElementsByTagName("img").length+e.getElementsByTagName("embed").length+e.getElementsByTagName("object").length+e.getElementsByTagName("iframe").length&&!this._getInnerText(e,!1)})),this._forEachNode(this._getAllNodesWithTag(e,["br"]),(function(e){var t=this._nextElement(e.nextSibling);t&&"P"==t.tagName&&e.parentNode.removeChild(e)})),this._forEachNode(this._getAllNodesWithTag(e,["table"]),(function(e){var t=this._hasSingleTagInsideElement(e,"TBODY")?e.firstElementChild:e;if(this._hasSingleTagInsideElement(t,"TR")){var i=t.firstElementChild;if(this._hasSingleTagInsideElement(i,"TD")){var n=i.firstElementChild;n=this._setNodeTag(n,this._everyNode(n.childNodes,this._isPhrasingContent)?"P":"DIV"),e.parentNode.replaceChild(n,e)}}}))},_initializeNode:function(e){switch(e.readability={contentScore:0},e.tagName){case"DIV":e.readability.contentScore+=5;break;case"PRE":case"TD":case"BLOCKQUOTE":e.readability.contentScore+=3;break;case"ADDRESS":case"OL":case"UL":case"DL":case"DD":case"DT":case"LI":case"FORM":e.readability.contentScore-=3;break;case"H1":case"H2":case"H3":case"H4":case"H5":case"H6":case"TH":e.readability.contentScore-=5}e.readability.contentScore+=this._getClassWeight(e)},_removeAndGetNext:function(e){var t=this._getNextNode(e,!0);return e.parentNode.removeChild(e),t},_getNextNode:function(e,t){if(!t&&e.firstElementChild)return e.firstElementChild;if(e.nextElementSibling)return e.nextElementSibling;do{e=e.parentNode}while(e&&!e.nextElementSibling);return e&&e.nextElementSibling},_checkByline:function(e,t){if(this._articleByline)return!1;if(void 0!==e.getAttribute)var i=e.getAttribute("rel");return!("author"!==i&&!this.REGEXPS.byline.test(t)||!this._isValidByline(e.textContent))&&(this._articleByline=e.textContent.trim(),!0)},_getNodeAncestors:function(e,t){t=t||0;for(var i=0,n=[];e.parentNode&&(n.push(e.parentNode),!t||++i!==t);)e=e.parentNode;return n},_grabArticle:function(e){this.log("**** grabArticle ****");var t=this._doc,i=null!==e;if(!(e=e||this._doc.body))return this.log("No body found in document. Abort."),null;for(var n=e.innerHTML;;){for(var a=this._flagIsActive(this.FLAG_STRIP_UNLIKELYS),r=[],s=this._doc.documentElement;s;){var o=s.className+" "+s.id;if(this._isProbablyVisible(s))if(this._checkByline(s,o))s=this._removeAndGetNext(s);else if(a&&this.REGEXPS.unlikelyCandidates.test(o)&&!this.REGEXPS.okMaybeItsACandidate.test(o)&&"BODY"!==s.tagName&&"A"!==s.tagName)this.log("Removing unlikely candidate - "+o),s=this._removeAndGetNext(s);else if("DIV"!==s.tagName&&"SECTION"!==s.tagName&&"HEADER"!==s.tagName&&"H1"!==s.tagName&&"H2"!==s.tagName&&"H3"!==s.tagName&&"H4"!==s.tagName&&"H5"!==s.tagName&&"H6"!==s.tagName||!this._isElementWithoutContent(s)){if(-1!==this.DEFAULT_TAGS_TO_SCORE.indexOf(s.tagName)&&r.push(s),"DIV"===s.tagName){for(var l=null,c=s.firstChild;c;){var d=c.nextSibling;if(this._isPhrasingContent(c))null!==l?l.appendChild(c):this._isWhitespace(c)||(l=t.createElement("p"),s.replaceChild(l,c),l.appendChild(c));else if(null!==l){for(;l.lastChild&&this._isWhitespace(l.lastChild);)l.removeChild(l.lastChild);l=null}c=d}if(this._hasSingleTagInsideElement(s,"P")&&this._getLinkDensity(s)<.25){var h=s.children[0];s.parentNode.replaceChild(h,s),s=h,r.push(s)}else this._hasChildBlockElement(s)||(s=this._setNodeTag(s,"P"),r.push(s))}s=this._getNextNode(s)}else s=this._removeAndGetNext(s);else this.log("Removing hidden node - "+o),s=this._removeAndGetNext(s)}var g=[];this._forEachNode(r,(function(e){if(e.parentNode&&void 0!==e.parentNode.tagName){var t=this._getInnerText(e);if(!(t.length<25)){var i=this._getNodeAncestors(e,3);if(0!==i.length){var n=0;n+=1,n+=t.split(",").length,n+=Math.min(Math.floor(t.length/100),3),this._forEachNode(i,(function(e,t){if(e.tagName&&e.parentNode&&void 0!==e.parentNode.tagName){if(void 0===e.readability&&(this._initializeNode(e),g.push(e)),0===t)var i=1;else i=1===t?2:3*t;e.readability.contentScore+=n/i}}))}}}}));for(var m=[],u=0,_=g.length;u<_;u+=1){var f=g[u],p=f.readability.contentScore*(1-this._getLinkDensity(f));f.readability.contentScore=p,this.log("Candidate:",f,"with score "+p);for(var E=0;E<this._nbTopCandidates;E++){var N=m[E];if(!N||p>N.readability.contentScore){m.splice(E,0,f),m.length>this._nbTopCandidates&&m.pop();break}}}var T,b=m[0]||null,y=!1;if(null===b||"BODY"===b.tagName){b=t.createElement("DIV"),y=!0;for(var v=e.childNodes;v.length;)this.log("Moving child out:",v[0]),b.appendChild(v[0]);e.appendChild(b),this._initializeNode(b)}else if(b){for(var A=[],S=1;S<m.length;S++)m[S].readability.contentScore/b.readability.contentScore>=.75&&A.push(this._getNodeAncestors(m[S]));if(A.length>=3)for(T=b.parentNode;"BODY"!==T.tagName;){for(var C=0,L=0;L<A.length&&C<3;L++)C+=Number(A[L].includes(T));if(C>=3){b=T;break}T=T.parentNode}b.readability||this._initializeNode(b),T=b.parentNode;for(var x=b.readability.contentScore,I=x/3;"BODY"!==T.tagName;)if(T.readability){var D=T.readability.contentScore;if(D<I)break;if(D>x){b=T;break}x=T.readability.contentScore,T=T.parentNode}else T=T.parentNode;for(T=b.parentNode;"BODY"!=T.tagName&&1==T.children.length;)T=(b=T).parentNode;b.readability||this._initializeNode(b)}var R=t.createElement("DIV");i&&(R.id="readability-content");for(var O=Math.max(10,.2*b.readability.contentScore),P=(T=b.parentNode).children,B=0,M=P.length;B<M;B++){var w=P[B],H=!1;if(this.log("Looking at sibling node:",w,w.readability?"with score "+w.readability.contentScore:""),this.log("Sibling has score",w.readability?w.readability.contentScore:"Unknown"),w===b)H=!0;else{var G=0;if(w.className===b.className&&""!==b.className&&(G+=.2*b.readability.contentScore),w.readability&&w.readability.contentScore+G>=O)H=!0;else if("P"===w.nodeName){var k=this._getLinkDensity(w),U=this._getInnerText(w),F=U.length;(F>80&&k<.25||F<80&&F>0&&0===k&&-1!==U.search(/\.( |$)/))&&(H=!0)}}H&&(this.log("Appending node:",w),-1===this.ALTER_TO_DIV_EXCEPTIONS.indexOf(w.nodeName)&&(this.log("Altering sibling:",w,"to div."),w=this._setNodeTag(w,"DIV")),R.appendChild(w),B-=1,M-=1)}if(this._debug&&this.log("Article content pre-prep: "+R.innerHTML),this._prepArticle(R),this._debug&&this.log("Article content post-prep: "+R.innerHTML),y)b.id="readability-page-1",b.className="page";else{var V=t.createElement("DIV");V.id="readability-page-1",V.className="page";for(var W=R.childNodes;W.length;)V.appendChild(W[0]);R.appendChild(V)}this._debug&&this.log("Article content after paging: "+R.innerHTML);var X=!0,j=this._getInnerText(R,!0).length;if(j<this._charThreshold)if(X=!1,e.innerHTML=n,this._flagIsActive(this.FLAG_STRIP_UNLIKELYS))this._removeFlag(this.FLAG_STRIP_UNLIKELYS),this._attempts.push({articleContent:R,textLength:j});else if(this._flagIsActive(this.FLAG_WEIGHT_CLASSES))this._removeFlag(this.FLAG_WEIGHT_CLASSES),this._attempts.push({articleContent:R,textLength:j});else if(this._flagIsActive(this.FLAG_CLEAN_CONDITIONALLY))this._removeFlag(this.FLAG_CLEAN_CONDITIONALLY),this._attempts.push({articleContent:R,textLength:j});else{if(this._attempts.push({articleContent:R,textLength:j}),this._attempts.sort((function(e,t){return t.textLength-e.textLength})),!this._attempts[0].textLength)return null;R=this._attempts[0].articleContent,X=!0}if(X){var z=[T,b].concat(this._getNodeAncestors(T));return this._someNode(z,(function(e){if(!e.tagName)return!1;var t=e.getAttribute("dir");return!!t&&(this._articleDir=t,!0)})),R}}},_isValidByline:function(e){return("string"==typeof e||e instanceof String)&&((e=e.trim()).length>0&&e.length<100)},_getArticleMetadata:function(){var e={},t={},i=this._doc.getElementsByTagName("meta"),n=/\s*(dc|dcterm|og|twitter)\s*:\s*(author|creator|description|title|site_name)\s*/gi,a=/^\s*(?:(dc|dcterm|og|twitter|weibo:(article|webpage))\s*[\.:]\s*)?(author|creator|description|title|site_name)\s*$/i;return this._forEachNode(i,(function(e){var i=e.getAttribute("name"),r=e.getAttribute("property"),s=e.getAttribute("content");if(s){var o=null,l=null;if(r&&(o=r.match(n)))for(var c=o.length-1;c>=0;c--)l=o[c].toLowerCase().replace(/\s/g,""),t[l]=s.trim();!o&&i&&a.test(i)&&(l=i,s&&(l=l.toLowerCase().replace(/\s/g,"").replace(/\./g,":"),t[l]=s.trim()))}})),e.title=t["dc:title"]||t["dcterm:title"]||t["og:title"]||t["weibo:article:title"]||t["weibo:webpage:title"]||t.title||t["twitter:title"],e.title||(e.title=this._getArticleTitle()),e.byline=t["dc:creator"]||t["dcterm:creator"]||t.author,e.excerpt=t["dc:description"]||t["dcterm:description"]||t["og:description"]||t["weibo:article:description"]||t["weibo:webpage:description"]||t.description||t["twitter:description"],e.siteName=t["og:site_name"],e},_removeScripts:function(e){this._removeNodes(e.getElementsByTagName("script"),(function(e){return e.nodeValue="",e.removeAttribute("src"),!0})),this._removeNodes(e.getElementsByTagName("noscript"))},_hasSingleTagInsideElement:function(e,t){return 1==e.children.length&&e.children[0].tagName===t&&!this._someNode(e.childNodes,(function(e){return e.nodeType===this.TEXT_NODE&&this.REGEXPS.hasContent.test(e.textContent)}))},_isElementWithoutContent:function(e){return e.nodeType===this.ELEMENT_NODE&&0==e.textContent.trim().length&&(0==e.children.length||e.children.length==e.getElementsByTagName("br").length+e.getElementsByTagName("hr").length)},_hasChildBlockElement:function(e){return this._someNode(e.childNodes,(function(e){return-1!==this.DIV_TO_P_ELEMS.indexOf(e.tagName)||this._hasChildBlockElement(e)}))},_isPhrasingContent:function(e){return e.nodeType===this.TEXT_NODE||-1!==this.PHRASING_ELEMS.indexOf(e.tagName)||("A"===e.tagName||"DEL"===e.tagName||"INS"===e.tagName)&&this._everyNode(e.childNodes,this._isPhrasingContent)},_isWhitespace:function(e){return e.nodeType===this.TEXT_NODE&&0===e.textContent.trim().length||e.nodeType===this.ELEMENT_NODE&&"BR"===e.tagName},_getInnerText:function(e,t){t=void 0===t||t;var i=e.textContent.trim();return t?i.replace(this.REGEXPS.normalize," "):i},_getCharCount:function(e,t){return t=t||",",this._getInnerText(e).split(t).length-1},_cleanStyles:function(e){if(e&&"svg"!==e.tagName.toLowerCase()){for(var t=0;t<this.PRESENTATIONAL_ATTRIBUTES.length;t++)e.removeAttribute(this.PRESENTATIONAL_ATTRIBUTES[t]);-1!==this.DEPRECATED_SIZE_ATTRIBUTE_ELEMS.indexOf(e.tagName)&&(e.removeAttribute("width"),e.removeAttribute("height"));for(var i=e.firstElementChild;null!==i;)this._cleanStyles(i),i=i.nextElementSibling}},_getLinkDensity:function(e){var t=this._getInnerText(e).length;if(0===t)return 0;var i=0;return this._forEachNode(e.getElementsByTagName("a"),(function(e){i+=this._getInnerText(e).length})),i/t},_getClassWeight:function(e){if(!this._flagIsActive(this.FLAG_WEIGHT_CLASSES))return 0;var t=0;return"string"==typeof e.className&&""!==e.className&&(this.REGEXPS.negative.test(e.className)&&(t-=25),this.REGEXPS.positive.test(e.className)&&(t+=25)),"string"==typeof e.id&&""!==e.id&&(this.REGEXPS.negative.test(e.id)&&(t-=25),this.REGEXPS.positive.test(e.id)&&(t+=25)),t},_clean:function(e,t){var i=-1!==["object","embed","iframe"].indexOf(t);this._removeNodes(e.getElementsByTagName(t),(function(e){if(i){var t=[].map.call(e.attributes,(function(e){return e.value})).join("|");if(this.REGEXPS.videos.test(t))return!1;if(this.REGEXPS.videos.test(e.innerHTML))return!1}return!0}))},_hasAncestorTag:function(e,t,i,n){i=i||3,t=t.toUpperCase();for(var a=0;e.parentNode;){if(i>0&&a>i)return!1;if(e.parentNode.tagName===t&&(!n||n(e.parentNode)))return!0;e=e.parentNode,a++}return!1},_getRowAndColumnCount:function(e){for(var t=0,i=0,n=e.getElementsByTagName("tr"),a=0;a<n.length;a++){var r=n[a].getAttribute("rowspan")||0;r&&(r=parseInt(r,10)),t+=r||1;for(var s=0,o=n[a].getElementsByTagName("td"),l=0;l<o.length;l++){var c=o[l].getAttribute("colspan")||0;c&&(c=parseInt(c,10)),s+=c||1}i=Math.max(i,s)}return{rows:t,columns:i}},_markDataTables:function(e){for(var t=e.getElementsByTagName("table"),i=0;i<t.length;i++){var n=t[i];if("presentation"!=n.getAttribute("role"))if("0"!=n.getAttribute("datatable"))if(n.getAttribute("summary"))n._readabilityDataTable=!0;else{var a=n.getElementsByTagName("caption")[0];if(a&&a.childNodes.length>0)n._readabilityDataTable=!0;else{if(["col","colgroup","tfoot","thead","th"].some((function(e){return!!n.getElementsByTagName(e)[0]})))this.log("Data table because found data-y descendant"),n._readabilityDataTable=!0;else if(n.getElementsByTagName("table")[0])n._readabilityDataTable=!1;else{var r=this._getRowAndColumnCount(n);r.rows>=10||r.columns>4?n._readabilityDataTable=!0:n._readabilityDataTable=r.rows*r.columns>10}}}else n._readabilityDataTable=!1;else n._readabilityDataTable=!1}},_cleanConditionally:function(e,t){if(this._flagIsActive(this.FLAG_CLEAN_CONDITIONALLY)){var i="ul"===t||"ol"===t;this._removeNodes(e.getElementsByTagName(t),(function(e){if(this._hasAncestorTag(e,"table",-1,(function(e){return e._readabilityDataTable})))return!1;var t=this._getClassWeight(e);if(this.log("Cleaning Conditionally",e),t+0<0)return!0;if(this._getCharCount(e,",")<10){for(var n=e.getElementsByTagName("p").length,a=e.getElementsByTagName("img").length,r=e.getElementsByTagName("li").length-100,s=e.getElementsByTagName("input").length,o=0,l=e.getElementsByTagName("embed"),c=0,d=l.length;c<d;c+=1)this.REGEXPS.videos.test(l[c].src)||(o+=1);var h=this._getLinkDensity(e),g=this._getInnerText(e).length;return a>1&&n/a<.5&&!this._hasAncestorTag(e,"figure")||!i&&r>n||s>Math.floor(n/3)||!i&&g<25&&(0===a||a>2)&&!this._hasAncestorTag(e,"figure")||!i&&t<25&&h>.2||t>=25&&h>.5||1===o&&g<75||o>1}return!1}))}},_cleanMatchedNodes:function(e,t){for(var i=this._getNextNode(e,!0),n=this._getNextNode(e);n&&n!=i;)n=t.test(n.className+" "+n.id)?this._removeAndGetNext(n):this._getNextNode(n)},_cleanHeaders:function(e){for(var t=1;t<3;t+=1)this._removeNodes(e.getElementsByTagName("h"+t),(function(e){return this._getClassWeight(e)<0}))},_flagIsActive:function(e){return(this._flags&e)>0},_removeFlag:function(e){this._flags=this._flags&~e},_isProbablyVisible:function(e){return!(e.style&&"none"==e.style.display||e.hasAttribute("hidden"))},parse:function(){if(this._maxElemsToParse>0){var e=this._doc.getElementsByTagName("*").length;if(e>this._maxElemsToParse)throw new Error("Aborting parsing document; "+e+" elements found")}this._removeScripts(this._doc),this._prepDocument();var t=this._getArticleMetadata();this._articleTitle=t.title;var i=this._grabArticle();if(!i)return null;if(this.log("Grabbed: "+i.innerHTML),this._postProcessContent(i),!t.excerpt){var n=i.getElementsByTagName("p");n.length>0&&(t.excerpt=n[0].textContent.trim())}var a=i.textContent;return{title:this._articleTitle,byline:t.byline||this._articleByline,dir:this._articleDir,content:i.innerHTML,textContent:a,length:a.length,excerpt:t.excerpt,siteName:t.siteName||this._articleSiteName}}},e.exports=n}});