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
                field:"id",
                type:"presence"
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
            api:
                {
                    create:"/another/create",
                    destroy:"/another/delete",
                    read:"/another/read",
                    update:"/another/update"
                },
            type:"ajax"
        }
});
