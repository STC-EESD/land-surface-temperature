
import ee

def test_eeTaskStatus(google_drive_folder):

    thisFunctionName = "test_eeTaskStatus"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print("\nee.data.listOperations()");
    print(   ee.data.listOperations() );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )

##### ##### ##### ##### #####
