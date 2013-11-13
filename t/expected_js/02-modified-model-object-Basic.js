{
    __1__extend__:"Ext.data.Model",
    __2__comment__:"COMMENT_1",    __3__fields__:
        [
            {
                __4__name__:"id",
                __5__type__:"int"
            },
            
            {
                __6__defaultValue__:"hello",
                __7__name__:"title",
                __8__type__:"string"
            },
            
            {
                __9__name__:"description",
                __10__type__:"string"
            },
            
            {
                __11__name__:"email",
                __12__type__:"string"
            },
            
            {
                __13__name__:"explicitnulldef",
                __14__type__:"string"
            },
            
            {
                __15__name__:"explicitemptystring",
                __16__type__:"string"
            },
            {__17__comment__:"COMMENT_2"},            {
                __18__name__:"emptytagdef",
                __19__type__:"string",
                __20__defaultValue__: "I will survive !"
            },
            
            {
                __21__defaultValue__:2,
                __22__name__:"another_id",
                __23__type__:"int"
            },
            
            {
                __24__name__:"timest",
                __25__type__:"date"
            },
            
            {
                __26__defaultValue__:false,
                __27__name__:"boolfield",
                __28__type__:"boolean"
            }
        ],
    __29__proxy__:
        {
            __30__api__:
                {
                    __31__create__:"/basic/create",
                    __32__destroy__:"/basic/delete",
                    __33__read__:"/basic/read",
                    __34__update__:"/basic/update"
                },
            __35__type__:"ajax"
        },
    __36__validations__:
        [
            
            {
                __37__field__:"id",
                __38__type__:"presence"
            },
            
            {
                __39__field__:"title",
                __40__type__:"presence"
            },
            
            {
                __41__field__:"title",
                __42__max__:"100",
                __43__type__:"length"
            },
            
            {
                __44__field__:"email",
                __45__max__:"500",
                __46__type__:"length"
            },
            
            {
                __47__field__:"boolfield",
                __48__type__:"presence"
            }
        ],
    __49__associations__:
        [
            
            {
                __50__associationKey__:"another_id",
                __51__foreign__:"another_id",
                __52__model__:"Another",
                __53__primaryKey__:"id",
                __54__type__:"belongsTo"
            }
        ],
    __55__comment__:"COMMENT_3",    __56__html__: "METHOD_1",

    __57__comment__:"COMMENT_4",
    __58__add__: "METHOD_2"
}
