/*
 * preliminary comment
 */

Ext.define('Some.object', {
    console.log('Nothing to do with our model File.model.Basic');
});

Ext.define('File.model.Basic', {
    extend:"Ext.data.Model",
    // W.C ... (tribute to Tex Avery)
    fields:
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
            // trying to add a defaut value ... 
            {
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
    // An useful method to display My.model.Basic in some HTML page
    html: function() {
        // this comment in function will go with the wind
        return '<span title="' . this.description . '">' . this.name . '</span>';
    },

    /*
     * comment: {  a method under Oracle patent }
     * 
     */
    add: function(a, b) {
        /*
         * inner comment copyrighted { [ ( yep ) ] }
         *
         */
        var result = 0;
        var price = 100000;

        for(var i = 1; i < a; i++) {
            result += 1;
            price *= 42;
        }

        for(var j = 1; j < b; j++) {
            result = result + 1;
        }

        return price;
    }
});

console.log('Additionnal Javascript code');

// This is the end
// my friend
