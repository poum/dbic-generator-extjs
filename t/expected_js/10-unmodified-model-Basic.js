Ext.define('My.model.Basic', {
    extend:"Ext.data.Model",
    fields:
        [
            
            {
                name:"id",
                type:"int"
            },
            
            {
                name:"title",
                type:"string",
                defaultValue:"hello"
            },
            
            {
                name:"description",
                type:"string"
            },
            
            {
                name:"email",
                type:"string"
            },
            
            {
                name:"explicitnulldef",
                type:"string"
            },
            
            {
                name:"explicitemptystring",
                type:"string"
            },
            
            {
                name:"emptytagdef",
                type:"string"
            },
            
            {
                name:"another_id",
                type:"int",
                defaultValue:"2"
            },
            
            {
                name:"timest",
                type:"date"
            },
            
            {
                name:"boolfield",
                type:"boolean",
                defaultValue:false
            }
        ],
    validations:
        [
            
            {
                type:"presence",
                field:"id"
            },
            
            {
                type:"presence",
                field:"title"
            },
            
            {
                type:"length",
                field:"title",
                max:"100"
            },
            
            {
                type:"length",
                field:"email",
                max:"500"
            },
            
            {
                type:"presence",
                field:"boolfield"
            }
        ],
    associations:
        [
            
            {
                associationKey:"another_id",
                foreign:"another_id",
                model:"Another",
                primaryKey:"id",
                type:"belongsTo"
            }
        ],
    proxy:
        {
            type:"ajax",
            api:
                {
                    read:"/basic/read",
                    create:"/basic/create",
                    update:"/basic/update",
                    destroy:"/basic/delete"
                }
        }
});
