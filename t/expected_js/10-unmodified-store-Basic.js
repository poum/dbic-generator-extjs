Ext.define('My.store.Basic', {
    extend:"Ext.data.Store",
    model:"My.model.Basic",
    proxy:
        {
            type:"ajax",
            url:"/basic/list.json"
        }
});