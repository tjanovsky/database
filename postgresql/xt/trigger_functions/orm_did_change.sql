create or replace function xt.orm_did_change() returns trigger as $$
/* Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple. 
   See www.xm.ple.com/CPAL for the full text of the software license. */

  /* initialize plv8 if needed */
  if(!this.isInitialized) executeSql('select xt.js_init()');

  var view, views = [], i = 1, res, n;

  /* Validate */
  if(TG_OP === 'INSERT' || TG_OP === 'UPDATE') {
    view = NEW.orm_namespace.decamelize() + '.' + NEW.orm_type.decamelize();
  } else {
    view = OLD.orm_namespace.decamelize() + '.' + OLD.orm_type.decamelize();
  }

  /* determine view dependencies */
  views = executeSql('select xt.view_dependencies($1)  as result', [view])[0].result;

  /* drop the views */
  n = views.length;
  while (n--) {
    nsp = views[n].beforeDot();
    rel = views[n].afterDot();
    executeSql("select dropIfExists('VIEW', $1, $2)", [rel, nsp]);
  }

  /* Determine whether to rebuild */ 
  if(TG_OP === 'UPDATE' || TG_OP === 'DELETE') {
    if(!OLD.orm_ext) { /* is base map */ 
      if(TG_OP === 'DELETE') {
        if(views.length) {
          throw new Error('Can not delete map for view {view} because it has the following dependencies: {views}'
                          .replace(/{view}/, view)
                          .replace(/{views}/, views.join(',')));
        } else {
          return OLD;
        }
      } else if(TG_OP === 'UPDATE' && !NEW.orm_active) {
        if(views.length) {
          throw new Error('Can not deactivate map {type} because it has the following dependencies: {views}'
                          .replace(/{type}/, NEW.orm_type)
                          .replace(/{views}/, views.join(',')));
        } else {
          return OLD;
        }
      }
    }
  }

  /* Loop through model names and create */ 
  if(TG_OP === 'INSERT' || TG_OP === 'UPDATE') {
    for(var i = 0; i < views.length; i++) {
      executeSql('select xt.create_orm_view($1);',[views[i]]);
    }
  }

  /* Finish up */
  if(TG_OP === 'DELETE') return OLD;
  
  return NEW;

$$ language plv8;