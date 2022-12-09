
import ee

def test_eeAuthenticate():

    thisFunctionName = "test_eeAuthenticate"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n# calling ee.Authenticate() ..." )
    ee.Authenticate(auth_mode = "appdefault")

    print( "\n# calling ee.Initialize() ..." )
    ee.Initialize()

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )

##### ##### ##### ##### #####
