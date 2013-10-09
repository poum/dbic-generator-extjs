Ext.define('My.store.Basics', {
    extend:"Ext.data.Store",
    model:"My.model.Basic",
    proxy:
        {
            type:"ajax",
            url:"/basic/list.json"
        }
});