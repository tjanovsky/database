﻿select xt.install_js('XM','SalesJournal','xtuple', $$
  /* Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple. 
     See www.xm.ple.com/CPAL for the full text of the software license. */

  XM.SalesJournal = {};
  
  XM.SalesJournal.isDispatchable = true;
  
  /** 
   Post Sales Journals journal type.

   *** By Type NOT currently implemented ***

   @param {Date, Date, Date} startDate, endDate, distributionDate
   @returns {Number}
  */
  XM.SalesJournal.post = function(startDate, endDate, distributionDate) {
    var data = Object.create(XT.Data),
        ret, err;

    if(!data.checkPrivilege('PostJournals')) err = "Access Denied.";
    else if(startDate === undefined || endDate === undefined || distributionDate === undefined)
      err = "Start date, End date, and Distribution date required.";

    if(!err) {
      ret = XM.Journal.post('S',startDate, endDate, distributionDate);
      switch (ret)
      {
        case -4:
          err = "Cannot post to closed period.";
          break;
        default:
          return ret;
      }
    }

    throw new Error(err);
  }

$$ );