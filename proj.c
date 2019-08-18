#include <tcl.h>
#include <proj.h>

typedef struct ProjState {
    Tcl_HashTable hash;		/* List projections by name */
    int uid;			/* Used to generate names */
} ProjState;

int
ProjCmd(ClientData data, Tcl_Interp * interp, int objc,
	Tcl_Obj * CONST objv[])
{
    ProjState *statePtr = (ProjState *) data;
    int new, index;
    char name[20];
    char *subCmds[] = {
	"create", "destroy", "fwd", "inv", 
	"crs2crs", "norm", NULL
    };
    enum Proj {
	Create, Destroy, Fwd, Inv,
	Crs2Crs, Norm
    };

    if (objc < 2) {
	Tcl_WrongNumArgs(interp, 1, objv, "option ?arg ...?");
	return TCL_ERROR;
    }
    if (Tcl_GetIndexFromObj(interp, objv[1], subCmds,
			    "option", 0, &index) != TCL_OK) {
	return TCL_ERROR;
    }

    switch (index) {

    case Create:
	{
	    if (objc != 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "option ?arg ...?");
		return TCL_ERROR;
	    }
	    PJ *P = proj_create(PJ_DEFAULT_CTX, Tcl_GetString(objv[2]));
	    if (P == NULL) {
		Tcl_AppendResult(interp, "proj definition error: ",
				 proj_errno_string(proj_errno(0)), NULL);
		return TCL_ERROR;
	    }
	    statePtr->uid++;
	    sprintf(name, "proj%d", statePtr->uid);
	    Tcl_HashEntry *entryPtr = 
		Tcl_CreateHashEntry(&statePtr->hash, name, &new);
	    Tcl_SetHashValue(entryPtr, (ClientData) P);
	    Tcl_SetResult(interp, name, TCL_VOLATILE);
	    return TCL_OK;
	}

    case Destroy:
	{
	    if (objc != 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "option ?arg ...?");
		return TCL_ERROR;
	    }
	    Tcl_HashEntry *entryPtr =
		Tcl_FindHashEntry(&statePtr->hash, Tcl_GetString(objv[2]));
	    if (entryPtr == NULL) {
		Tcl_AppendResult(interp, "Unknown proj: ",
				 Tcl_GetString(objv[2]), NULL);
		return TCL_ERROR;
	    }
	    PJ *P = Tcl_GetHashValue(entryPtr);
	    Tcl_DeleteHashEntry(entryPtr);
	    proj_destroy(P);
	    return TCL_OK;
	}

    case Fwd:
    case Inv:
	{
	    if (objc != 4) {
		Tcl_WrongNumArgs(interp, 1, objv, "option ?arg ...?");
		return TCL_ERROR;
	    }
	    Tcl_HashEntry *entryPtr =
		Tcl_FindHashEntry(&statePtr->hash, Tcl_GetString(objv[2]));
	    if (entryPtr == NULL) {
		Tcl_AppendResult(interp, "Unknown proj: ",
				 Tcl_GetString(objv[2]), NULL);
		return TCL_ERROR;
	    }
	    PJ *P = Tcl_GetHashValue(entryPtr);

	    Tcl_Obj **d; int n;
	    if (Tcl_ListObjGetElements(interp, objv[3], &n, &d) != TCL_OK) {
                 return TCL_ERROR;
	    }
            if (n < 2) {
		Tcl_AppendResult(interp,"not a point: ", NULL);
	        return TCL_ERROR;
	    }
	    PJ_COORD a = proj_coord(0.0, 0.0, 0.0, 0.0);
	    for (int i=0; i<n; i++) {
		if (Tcl_GetDoubleFromObj(interp, d[i], &(a.v[i])) != TCL_OK) {
                     return TCL_ERROR;
		}
	    }

	    if (index == Fwd) {
		if (proj_angular_input(P, PJ_FWD)) {
		    a.lp.lam = proj_torad(a.lp.lam);
		    a.lp.phi = proj_torad(a.lp.phi);
		}

		a = proj_trans(P, PJ_FWD, a);

		if (proj_angular_output(P, PJ_FWD)) {
		    a.lp.lam = proj_todeg(a.lp.lam);
		    a.lp.phi = proj_todeg(a.lp.phi);
		}
	    } else {
		if (proj_angular_input(P, PJ_INV)) {
		    a.lp.lam = proj_torad(a.lp.lam);
		    a.lp.phi = proj_torad(a.lp.phi);
		}

		a = proj_trans(P, PJ_INV, a);

		if (proj_angular_output(P, PJ_INV)) {
		    a.lp.lam = proj_todeg(a.lp.lam);
		    a.lp.phi = proj_todeg(a.lp.phi);
		}
	    }

            Tcl_Obj *listPtr = Tcl_NewListObj(0, NULL);
	    for (int i=0; i<n; i++) {
		Tcl_ListObjAppendElement(interp, listPtr,
				     Tcl_NewDoubleObj(a.v[i]));
	    }
	    Tcl_SetObjResult(interp, listPtr);
	    return TCL_OK;
	}

    case Crs2Crs:
	{
	    if (objc != 4) {
		Tcl_WrongNumArgs(interp, 1, objv, "option ?arg ...?");
		return TCL_ERROR;
	    }
	    PJ *P = proj_create_crs_to_crs(PJ_DEFAULT_CTX, 
		    Tcl_GetString(objv[2]),
		    Tcl_GetString(objv[3]), 0);
	    if (P == NULL) {
		Tcl_AppendResult(interp, "proj definition error: ",
				 proj_errno_string(proj_errno(0)), NULL);
		return TCL_ERROR;
	    }
	    statePtr->uid++;
	    sprintf(name, "proj%d", statePtr->uid);
	    Tcl_HashEntry *entryPtr = 
		Tcl_CreateHashEntry(&statePtr->hash, name, &new);
	    Tcl_SetHashValue(entryPtr, (ClientData) P);
	    Tcl_SetResult(interp, name, TCL_VOLATILE);
	    return TCL_OK;
	}

    case Norm:
	{
	    if (objc != 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "option ?arg ...?");
		return TCL_ERROR;
	    }
	    Tcl_HashEntry *entryPtr =
		Tcl_FindHashEntry(&statePtr->hash, Tcl_GetString(objv[2]));
	    if (entryPtr == NULL) {
		Tcl_AppendResult(interp, "Unknown proj: ",
				 Tcl_GetString(objv[2]), NULL);
		return TCL_ERROR;
	    }
	    PJ *P = Tcl_GetHashValue(entryPtr);
	    PJ *Q = proj_normalize_for_visualization(PJ_DEFAULT_CTX, P);
	    statePtr->uid++;
	    sprintf(name, "proj%d", statePtr->uid);
	    entryPtr = Tcl_CreateHashEntry(&statePtr->hash, name, &new);
	    Tcl_SetHashValue(entryPtr, (ClientData) Q);
	    Tcl_SetResult(interp, name, TCL_VOLATILE);
	    return TCL_OK;
	}
    }
    return TCL_OK;
}

void 
ProjCleanup(ClientData data)
{
    ProjState *statePtr = (ProjState *) data;
    PJ *P;
    Tcl_HashSearch search;

    Tcl_HashEntry *entryPtr = Tcl_FirstHashEntry(&statePtr->hash, &search);
    while (entryPtr != NULL) {
	P = Tcl_GetHashValue(entryPtr);
	Tcl_DeleteHashEntry(entryPtr);
	proj_destroy(P);
	entryPtr = Tcl_FirstHashEntry(&statePtr->hash, &search);
    }
    ckfree((char *) statePtr);
}

int 
Proj_Init(Tcl_Interp * interp)
{
    if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
	return TCL_ERROR;
    }
    if (Tcl_PkgRequire(interp, "Tcl", "8.1", 0) == NULL) {
	return TCL_ERROR;
    }

    ProjState *statePtr = (ProjState *) ckalloc(sizeof(ProjState));
    Tcl_InitHashTable(&statePtr->hash, TCL_STRING_KEYS);
    statePtr->uid = 0;
    Tcl_CreateObjCommand(interp, "proj", ProjCmd, (ClientData) statePtr,
			 ProjCleanup);
    Tcl_PkgProvide(interp, "proj", "0.1");

    return TCL_OK;
}

//  vim: cin:sw=4:tw=75  
