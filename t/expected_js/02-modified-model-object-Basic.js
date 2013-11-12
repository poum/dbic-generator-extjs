{
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
    extend:"Ext.data.Model",
    comment:"COMMENT_1",    fields:
        [
            {
                name:"id",
                type:"int"
            },
            
            {
                defaultValue:"hello",
                name:"title",
                type:"string"
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
            {comment:"COMMENT_2"},            {
                name:"emptytagdef",
                type:"string",
                defaultValue: "I will survive !"
            },
            
            {
                defaultValue:2,
                name:"another_id",
                type:"int"
            },
            
            {
                name:"timest",
                type:"date"
            },
            
            {
                defaultValue:false,
                name:"boolfield",
                type:"boolean"
            }
        ],
    proxy:
        {
            api:
                {
                    create:"/basic/create",
                    destroy:"/basic/delete",
                    read:"/basic/read",
                    update:"/basic/update"
                },
            type:"ajax"
        },
    validations:
        [
            
            {
                field:"id",
                type:"presence"
            },
            
            {
                field:"title",
                type:"presence"
            },
            
            {
                field:"title",
                max:"100",
                type:"length"
            },
            
            {
                field:"email",
                max:"500",
                type:"length"
            },
            
            {
                field:"boolfield",
                type:"presence"
            }
        ],
    comment:"COMMENT_3",    html: "METHOD_1",

    comment:"COMMENT_4",
    add: "METHOD_2"
}
