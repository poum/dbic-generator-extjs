{
    __000001__extend__:"Ext.data.Model",
    __000002__fields__:
        [
            
            {
                __000003__name__:"id",
                __000004__type__:"int"
            },
            
            {
                __000005__defaultValue__:"hello",
                __000006__name__:"title",
                __000007__type__:"string"
            },
            
            {
                __000008__name__:"description",
                __000009__type__:"string"
            },
            
            {
                __000010__name__:"email",
                __000011__type__:"string"
            },
            
            {
                __000012__name__:"explicitnulldef",
                __000013__type__:"string"
            },
            
            {
                __000014__name__:"explicitemptystring",
                __000015__type__:"string"
            },
            
            {
                __000016__name__:"emptytagdef",
                __000017__type__:"string"
            },
            
            {
                __000018__defaultValue__:2,
                __000019__name__:"another_id",
                __000020__type__:"int"
            },
            
            {
                __000021__name__:"timest",
                __000022__type__:"date"
            },
            
            {
                __000023__defaultValue__:false,
                __000024__name__:"boolfield",
                __000025__type__:"boolean"
            }
        ],
    __000026__proxy__:
        {
            __000027__api__:
                {
                    __000028__create__:"/basic/create",
                    __000029__destroy__:"/basic/delete",
                    __000030__read__:"/basic/read",
                    __000031__update__:"/basic/update"
                },
            __000032__type__:"ajax"
        },
    __000033__validations__:
        [
            
            {
                __000034__field__:"id",
                __000035__type__:"presence"
            },
            
            {
                __000036__field__:"title",
                __000037__type__:"presence"
            },
            
            {
                __000038__field__:"title",
                __000039__max__:"100",
                __000040__type__:"length"
            },
            
            {
                __000041__field__:"email",
                __000042__max__:"500",
                __000043__type__:"length"
            },
            
            {
                __000044__field__:"boolfield",
                __000045__type__:"presence"
            }
        ],
    __000046__associations__:
        [
            
            {
                __000047__associationKey__:"another_id",
                __000048__foreign__:"another_id",
                __000049__model__:"Another",
                __000050__primaryKey__:"id",
                __000051__type__:"belongsTo"
            }
        ]
}
