/*
 * a initial comment
 *
 */
Ext.define('My.model.Another', {
    // before associations
    associations:
        [
            
            {
                associationKey:"get_Basic",
                foreign:"id", // inside
                model:"Basic",
                primaryKey:"another_id",
                type:"hasMany"
            }
        ],
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
        },
    validations:
        [
            
            {
                field:"id",
                type:"presence"
            }
        ],

    message: function(msg) {
        //  comment in the method
        console.log(msg);
    },

    /*
     * an extra method
     *
     */
    add: function(a, b) {
        return a + b;
    }
});
