/*  
    Copyright 2008, 2009, 2010 Boris ARZUR

    This file is part of Kemuri.

    Kemuri is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Kemuri is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public
    License along with Kemuri. If not, see http://www.gnu.org/licenses.
*/

/* Code taken from http://www.nsftools.com/misc/SearchAndHighlight.htm */

/*
    This is the function that actually highlights a text string by
    adding HTML tags before and after all occurrences of the search
    term. You can pass your own tags if you'd like, or if the
    highlightStartTag or highlightEndTag parameters are omitted or
    are empty strings then the default <font> tags will be used.
*/

function doHighlight(bodyText, searchTerm) {
  highlightStartTag = "<font style='color:blue; background-color:yellow;'>";
  highlightEndTag = "</font>";
  
  /* find all occurences of the search term in the given text,
     and add some "highlight" tags to them (we're not using a
     regular expression search, because we want to filter out
     matches that occur within HTML tags and script blocks, so
     we have to do a little extra validation) */
  var newText = "";
  var i = -1;
  var lcSearchTerm = searchTerm.toLowerCase();
  var lcBodyText = bodyText.toLowerCase();
    
  while (bodyText.length > 0) {
    i = lcBodyText.indexOf(lcSearchTerm, i+1);
    if (i < 0) {
      newText += bodyText;
      bodyText = "";
    } else {
      /* skip anything inside an HTML tag */
      if (bodyText.lastIndexOf(">", i) >= bodyText.lastIndexOf("<", i)) {
        /* skip anything inside a <script> block */
        if (lcBodyText.lastIndexOf("/script>", i) >= lcBodyText.lastIndexOf("<script", i)) {
          newText += bodyText.substring(0, i) + highlightStartTag + bodyText.substr(i, searchTerm.length) + highlightEndTag;
          bodyText = bodyText.substr(i + searchTerm.length);
          lcBodyText = bodyText.toLowerCase();
          i = -1;
        }
      }
    }
  }
  
  return newText;
};

/*
    This displays a dialog box that allows a user to enter their own
    search terms to highlight on the page, and then passes the search
    text or phrase to the highlightSearchTerms function.
*/

function searchPrompt() {
  searchText = prompt("Please enter the phrase you'd like to search for:", "");

  if (!searchText)  {
    alert("No search terms were entered. Exiting function.");
    return false;
  }
  
  if (!document.body || typeof(document.body.innerHTML) == "undefined") {
    if (warnOnFailure) {
      alert("Sorry, for some reason the text of this page is unavailable. Searching will not work.");
    }
    return false;
  }
  
  document.body.innerHTML = doHighlight(document.body.innerHTML, searchText);
  
  return true;
};

function search_bar_scroll_hdl(event) {
  search_bar_placeholder.style.top = window.innerHeight - search_bar_scroll_offset + window.scrollY;
}

var search_bar_scroll_offset = 65;
var search_bar_placeholder = document.getElementById( "search_bar" );
document.addEventListener( "scroll", search_bar_scroll_hdl, false );
search_bar_placeholder.style.left = 220;
search_bar_scroll_hdl(null);
