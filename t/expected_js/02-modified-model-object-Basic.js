{
    __000001__extend__:"Ext.data.Model",
    __000002__comment__:"COMMENT_1",    __000003__fields__:
        [
            {
                __000004__name__:"id",
                __000005__type__:"int"
            },
            
            {
                __000006__defaultValue__:"hello",
                __000007__name__:"title",
                __000008__type__:"string"
            },
            
            {
                __000009__name__:"description",
                __000010__type__:"string"
            },
            
            {
                __000011__name__:"email",
                __000012__type__:"string"
            },
            
            {
                __000013__name__:"explicitnulldef",
                __000014__type__:"string"
            },
            
            {
                __000015__name__:"explicitemptystring",
                __000016__type__:"string"
            },
            {__000017__comment__:"COMMENT_2"},            {
                __000018__name__:"emptytagdef",
                __000019__type__:"string",
                __000020__defaultValue__: "I will survive !"
            },
            
            {
                __000021__defaultValue__:2,
                __000022__name__:"another_id",
                __000023__type__:"int"
            },
            
            {
                __000024__name__:"timest",
                __000025__type__:"date"
            },
            
            {
                __000026__defaultValue__:false,
                __000027__name__:"boolfield",
                __000028__type__:"boolean"
            }
        ],
    __000029__proxy__:
        {
            __000030__api__:
                {
                    __000031__create__:"/basic/create",
                    __000032__destroy__:"/basic/delete",
                    __000033__read__:"/basic/read",
                    __000034__update__:"/basic/update"
                },
            __000035__type__:"ajax"
        },
    __000036__validations__:
        [
            
            {
                __000037__field__:"id",
                __000038__type__:"presence"
            },
            
            {
                __000039__field__:"title",
                __000040__type__:"presence"
            },
            
            {
                __000041__field__:"title",
                __000042__max__:"100",
                __000043__type__:"length"
            },
            
            {
                __000044__field__:"email",
                __000045__max__:"500",
                __000046__type__:"length"
            },
            
            {
                __000047__field__:"boolfield",
                __000048__type__:"presence"
            }
        ],
    __000049__associations__:
        [
            
            {
                __000050__associationKey__:"another_id",
                __000051__foreign__:"another_id",
                __000052__model__:"Another",
                __000053__primaryKey__:"id",
                __000054__type__:"belongsTo"
            }
        ],
    __000055__comment__:"COMMENT_3",    __000056__html__: "METHOD_1",

    __000057__comment__:"COMMENT_4",
    __000058__add__: "METHOD_2"
}
