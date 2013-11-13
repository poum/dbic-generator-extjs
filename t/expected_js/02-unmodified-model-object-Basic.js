{
    __1__extend__:"Ext.data.Model",
    __2__fields__:
        [
            
            {
                __3__name__:"id",
                __4__type__:"int"
            },
            
            {
                __5__defaultValue__:"hello",
                __6__name__:"title",
                __7__type__:"string"
            },
            
            {
                __8__name__:"description",
                __9__type__:"string"
            },
            
            {
                __10__name__:"email",
                __11__type__:"string"
            },
            
            {
                __12__name__:"explicitnulldef",
                __13__type__:"string"
            },
            
            {
                __14__name__:"explicitemptystring",
                __15__type__:"string"
            },
            
            {
                __16__name__:"emptytagdef",
                __17__type__:"string"
            },
            
            {
                __18__defaultValue__:2,
                __19__name__:"another_id",
                __20__type__:"int"
            },
            
            {
                __21__name__:"timest",
                __22__type__:"date"
            },
            
            {
                __23__defaultValue__:false,
                __24__name__:"boolfield",
                __25__type__:"boolean"
            }
        ],
    __26__proxy__:
        {
            __27__api__:
                {
                    __28__create__:"/basic/create",
                    __29__destroy__:"/basic/delete",
                    __30__read__:"/basic/read",
                    __31__update__:"/basic/update"
                },
            __32__type__:"ajax"
        },
    __33__validations__:
        [
            
            {
                __34__field__:"id",
                __35__type__:"presence"
            },
            
            {
                __36__field__:"title",
                __37__type__:"presence"
            },
            
            {
                __38__field__:"title",
                __39__max__:"100",
                __40__type__:"length"
            },
            
            {
                __41__field__:"email",
                __42__max__:"500",
                __43__type__:"length"
            },
            
            {
                __44__field__:"boolfield",
                __45__type__:"presence"
            }
        ],
    __46__associations__:
        [
            
            {
                __47__associationKey__:"another_id",
                __48__foreign__:"another_id",
                __49__model__:"Another",
                __50__primaryKey__:"id",
                __51__type__:"belongsTo"
            }
        ]
}
