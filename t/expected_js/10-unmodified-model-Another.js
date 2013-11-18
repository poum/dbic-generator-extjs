Ext.define('My.model.Another', {
    extend:"Ext.data.Model",
    fields:
        [
            
            {
                name:"id",
                type:"int"
            },
            
            {
                name:"num",
                type:"float"
            }
        ],
    validations:
        [
            
            {
                type:"presence",
                field:"id"
            }
        ],
    associations:
        [
            
            {
                associationKey:"get_Basic",
                foreign:"id",
                model:"Basic",
                primaryKey:"another_id",
                type:"hasMany"
            }
        ],
    proxy:
        {
            type:"ajax",
            api:
                {
                    read:"/another/read",
                    create:"/another/create",
                    update:"/another/update",
                    destroy:"/another/delete"
                }
        }
});
