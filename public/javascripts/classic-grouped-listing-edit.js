var ClassicGroupedListingEdit = {
  init: function() {
    this.newGroupCount = 0;
    $$('div.app-classic-grouped-listing').each(function(el) {
      el.getElementsBySelector('.listing a').each(function(listing) { listing.observe('click', function(ev) { ev.stop(); }) }); // Allow the links to be draggable by turning off their behavior
      
      var groupsBox = el.getElementsBySelector('.groups')[0];
      ClassicGroupedListingEdit._observeDrags(groupsBox);
      groupsBox.getElementsBySelector('div.group.draggable').each(function(g) { ClassicGroupedListingEdit._observeRemove(groupsBox, g); });
      
      var creationCodeEl = el.getElementsBySelector('.new-group-code')[0]
      var creationCode = creationCodeEl.innerHTML;
      creationCodeEl.remove();
      el.getElementsBySelector('a.new-group').each(function(newGroup) { newGroup.observe('click', function() { ClassicGroupedListingEdit._newGroup(groupsBox, creationCode); }) });
      el.getElementsBySelector('a.new-page').each(function(newPage) { newPage.observe('click', function(ev) { ev.stop(); if (confirm("Are you sure you would like to cancel editing this page and make a new " + newPage.href.substring(newPage.href.indexOf('representing=') + 'representing='.length) + "?")) { document.location = newPage.href; } }) });
      

      el.ancestors().detect(function(anc) { return anc.tagName == 'FORM' }).observe('submit', function(ev) { ClassicGroupedListingEdit._saveOrder(el); });
      
      el.getElementsBySelector('.datapath a').each(function(a) { a.observe('click', function() {
        el.getElementsBySelector('.datapath .readonly')[0].addClassName('hidden');
        el.getElementsBySelector('.datapath .editable')[0].removeClassName('hidden');
        el.getElementsBySelector('.datapath .editable input')[0].focus();
      }); });
    });
  },
  
  _newGroup: function(targetEl, html) {
    var newEl=$(document.createElement('div'));
    newEl.update(html.replace(/_INDEX_/, this.newGroupCount++));
    newEl = newEl.firstDescendant().remove();
    targetEl.appendChild(newEl);
    newEl.getElementsBySelector('input')[0].focus();
    newEl.scrollTo();
    
    this._unobserveDrags(targetEl);
    this._observeDrags(targetEl);
    this._observeRemove(targetEl, newEl);
  },
  
  _observeRemove: function(groups, group) {
    var remove = group.getElementsBySelector('.remove a')[0];
    remove.observe('click', function() {ClassicGroupedListingEdit._removeGroup(groups, group);})
  },
  
  _observeDrags: function(groups) {
    groups.getElementsBySelector('div.group').each(function(g) { 
      Sortable.create(g,
          { containment: groups.getElementsBySelector('div.group').collect(function(div) {return div.id}), 
            dropOnEmpty: true, scroll: window, scrollSensitivity: 40, scrollSpeed: 30, tag:'div'});
    });
    
    Sortable.create(groups, { only:'draggable', scroll: window, scrollSensitivity: 40, scrollSpeed: 30, tag:'div'});
  },
  
  _unobserveDrags: function(groups) {
    Sortable.destroy(groups);
    groups.getElementsBySelector('div.group').each(function(g) { Sortable.destroy(g); });
  },
  
  _saveOrder: function(el) {
    var currentPosition = 0;
    el.getElementsBySelector('.group.draggable').each(function(g) {
      g.getElementsBySelector('input.position-value')[0].value = currentPosition++; // Save position
      
      urns = g.getElementsBySelector('div.listing').collect(function(l) { 
        return l.classNames().detect(function(c) { return c.startsWith('urn-'); }).substring('urn-'.length);
      });
      g.getElementsBySelector('input.piped-listings-value')[0].value = urns.join('|');
    });
  },
  
  _removeGroup: function(groups, el) {
    var listings = el.getElementsBySelector('.listing');
    var untitled = groups.getElementsBySelector('div.group.untitled')[0];
    listings.each(function(l) {l.remove(); untitled.appendChild(l); });
    el.remove();
  }
}
ClassicGroupedListingEdit.init();