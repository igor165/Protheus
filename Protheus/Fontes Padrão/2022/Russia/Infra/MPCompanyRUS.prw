
#DEFINE SERVER		1
#DEFINE CONTYPE		2
#DEFINE PORT		3
#DEFINE DATABASE	4
#DEFINE NALIAS		5
#DEFINE MAPPER		6

#Include 'Protheus.ch'
#include "TOPCONN.CH"

/*{Protheus.doc}MPCompaRUS

Função de criação da tabela complementar de empresas para Rússia.

@author Sérgio Silveira 
@since  22/03/2017
@protected
*/

Function MPCompaRUS(cAlias)

Local aTopInfo    AS ARRAY

Local cTopBuild   AS CHAR 

Local lClob       AS LOGICAL  

Local oTblCRUS    AS OBJECT
Local oTblCDDL    AS OBJECT


// -------------------------------------
// Tabela de empresas da Rússia 
// ------------------------------------- 
aTopInfo := {}

lClob    := .F. 

oTblCRUS := MPStruCRUS(cAlias)

oTblCDDL := FWTableDDL():New()
#IFDEF TOP
	aTopInfo := FWGetTopInfo()
	oTblCDDL:AddDbAcess( aTopInfo[SERVER], aTopInfo[CONTYPE], aTopInfo[PORT], ;
						aTopInfo[DATABASE], aTopInfo[NALIAS], aTopInfo[MAPPER], AdvConnect() )
#ENDIF
oTblCDDL:SetTableStruct(oTblCRUS)
oTblCDDL:Activate()
If !oTblCDDL:TblExists()

	//------------------------------------------------------------------------------
	// Implanta o modo de campo RECNO auto-incremental
	// O recno vai ser incrementado usando apenas comandos SQL nativos para inserção
	//------------------------------------------------------------------------------
	
	// Verifica a build do DBAccess
	cTopBuild := FWTopBuild()
	 
	#IFDEF TOP	
		If cTopBuild >= "20131202" 
			TcInternal(30,"AUTORECNO") 
		EndIf
	#ENDIF 		
	
	// -------------------------------------
	// Creating the table
	// ------------------------------------- 
	oTblCDDL:CreateTable(NIL,lClob)
	
	#IFDEF TOP	
		If cTopBuild >= "20131202" 
			TcInternal(30,"OFF")
		EndIf
	#ENDIF			
	
	oTblCDDL:OpenTable()
	 	
Else
	oTblCDDL:AlterTable()
	oTblCDDL:OpenTable()
EndIf

// -------------------------------------
// Limpeza de memória  
// ------------------------------------- 

ASize( aTopInfo, 0 ) 

oTblCRUS := nil 
oTblCDDL := nil 

Return


/*{Protheus.doc}MPBrancRUS

Função de criação da tabela complementar de filiais para Rússia 

@author Sérgio Silveira 
@since  23/03/2017

@protected

*/

Function MPBrancRUS(cAlias)

Local aTopInfo    AS ARRAY

Local cTopBuild   AS CHAR

Local lClob       AS LOGICAL  

Local oTblBRUS    AS OBJECT
Local oTblBDDL    AS OBJECT

// -------------------------------------
// Tabela de filiais da Rússia 
// ------------------------------------- 

lClob    := .F. 

oTblBRUS := MPStruBRUS(cAlias)

oTblBDDL := FWTableDDL():New()
#IFDEF TOP
	aTopInfo := FWGetTopInfo()
	oTblBDDL:AddDbAcess( aTopInfo[SERVER], aTopInfo[CONTYPE], aTopInfo[PORT], ;
						aTopInfo[DATABASE], aTopInfo[NALIAS], aTopInfo[MAPPER], AdvConnect() )
#ENDIF
oTblBDDL:SetTableStruct(oTblBRUS)
oTblBDDL:Activate()
If !oTblBDDL:TblExists()

	//------------------------------------------------------------------------------
	// Implanta o modo de campo RECNO auto-incremental
	// O recno vai ser incrementado usando apenas comandos SQL nativos para inserção
	//------------------------------------------------------------------------------
	
	// Verifica a build do DBAccess
	cTopBuild := FWTopBuild() 
	
	#IFDEF TOP	
		If cTopBuild >= "20131202" 
			TcInternal(30,"AUTORECNO") 
		EndIf
	#ENDIF 		
	
	// -------------------------------------
	// Cria a tabela
	// ------------------------------------- 
	oTblBDDL:CreateTable(NIL,lClob)
	
	#IFDEF TOP	
		If cTopBuild >= "20131202" 
			TcInternal(30,"OFF")
		EndIf
	#ENDIF			
	
	oTblBDDL:OpenTable()
	 	
Else
	oTblBDDL:AlterTable()
	oTblBDDL:OpenTable()
EndIf

// -------------------------------------
// Limpeza de memória  
// ------------------------------------- 

ASize( aTopInfo, 0 ) 

oTblBRUS := nil 
oTblBDDL := nil 


Return

/*{Protheus.doc} GetCoBrRUS

Complex getter of company branch data 

@author Salov Alexander
@since  28.10.17

@return array of company branch data



*/
Function GetCoBrRUS(cBranch, cComp)
Local aRet AS ARRAY
Local aAddrs AS ARRAY

Local aAddrLegal AS ARRAY
Local aAddrPhys AS ARRAY
Local aAddrPost AS ARRAY

Local cLastBranch AS CHAR
Local cLastCo as CHAR
Local cQuery as CHAR
Local cTab as CHAR
Local cAddrKey as CHAR

default cBranch := cfilant//xFilial()//Cfilant
default cComp := cEmpAnt

aRet := {}
aAddrs := {}

cLastBranch := cfilant
cLastCo := cEmpAnt

cFilAnt := cBranch
cEmpAnt := cComp
	
aadd(aRet,FwComAltInf({"CO_COMPGRP","CO_COMPEMP","CO_COMPUNI","CO_TIPO","CO_FULLNAM","CO_SHORTNM","CO_PHONENU","CO_FAX","CO_EMAIL","CO_OGRN","CO_REGDATE","CO_OKPO","CO_INN","CO_KPP","CO_LOCLTAX","CO_LTAXNAM","CO_PFRREG","CO_FOMS","CO_FSS","CO_SUBORD","CO_STATIST","CO_OKTMO","CO_OKATO","CO_OKOGU","CO_OKOPF","CO_OKFS","CO_OKVED","CO_TYPE"}))
aadd(aRet,FwBranAltInf({"BR_COMPGRP","BR_COMPEMP","BR_COMPUNI","BR_BRANCH","BR_KPP","BR_FULLNAM","BR_SUBDIVI","BR_LOCLTAX","BR_PHONENU","BR_EMAIL","BR_DIGIVAT","BR_OKPO","BR_TIPO","BR_SHORTNM","BR_FAX","BR_LTAXNAM","BR_PFRREG","BR_FOMS","BR_FSS","BR_SUBORD","BR_STATIST","BR_OKTMO","BR_OKATO","BR_OKOGU","BR_OKOPF","BR_OKFS","BR_OKVED"}))


//Magic from Andrews Egas
cAddrKey := xFilial("SM0") + padr(aRet[2][1][2],Len(FwComAltInf({"XX8_GRPEMP"})[1][2]));
	 + padr(aRet[2][2][2],Len(FwComAltInf({"XX8_EMPR"})[1][2]));
	 	 + padr(aRet[2][3][2],Len(FwComAltInf({"XX8_UNID"})[1][2]));
	 	  + padr(aRet[2][4][2],Len(FwComAltInf({"XX8_CODIGO"})[1][2]))
//End of magic



cQuery := "SELECT "
cQuery += "AGA_FILIAL," 
cQuery += "AGA_CODIGO,"
cQuery += "AGA_ENTIDA,"
cQuery += "AGA_CODENT,"
cQuery += "AGA_TIPO,"
cQuery += "AGA_NAMENT,"
cQuery += "AGA_PADRAO,"
cQuery += "AGA_MUN,"
cQuery += "AGA_PAIS,"
cQuery += "AGA_CEP,"
cQuery += "AGA_EST,"
cQuery += "AGA_BAIRRO,"
cQuery += "AGA_MUNDES,"
cQuery += "AGA_COMP,"
cQuery += "AGA_END,"
cQuery += "AGA_HOUSE,"
cQuery += "AGA_BLDNG,"
cQuery += "AGA_APARTM,"
cQuery += "AGA_FORWHO,"
cQuery += "AGA_FROM,"
cQuery += "AGA_TO"

cQuery +=  " FROM " 
cQuery +=  RetSQLName("AGA")
cQuery +=  " WHERE AGA_ENTIDA = 'SM0' AND AGA_CODENT LIKE '%"
cQuery += cAddrKey
cQuery += "%'"
		
cTab := CriaTrab( , .F.)

TcQuery cQuery NEW ALIAS ((cTab))  

    
DbSelectArea((cTab))


While ((cTab)->(!Eof()))	
	if  (cTab)->AGA_TIPO == '0'
		aAddrLegal := GatherAdressData (cTab)
	endif  

	if  (cTab)->AGA_TIPO == '1'
		aAddrPhys := GatherAdressData (cTab) 
	endif 

	if  (cTab)->AGA_TIPO == '2'
		aAddrPost := GatherAdressData (cTab)
	endif 
	
	(cTab)->(DbSkip())
Enddo

aadd(aAddrs,aAddrLegal)
aadd(aAddrs,aAddrPhys)
aadd(aAddrs,aAddrPost)

aadd(aRet,aAddrs)

DbCloseArea((cTab))

cFilAnt := cLastBranch
cEmpAnt := cLastCo

return aRet


static function GatherAdressData(cTab)

Local aCurAddrs AS ARRAY
Local cAgaFull as char
Local aAreaTMPTAB AS ARRAY
aAreaTMPTAB := {}
aCurAddrs := {}

aAreaTMPTAB := (cTab)->(GetArea())

aadd(aCurAddrs,(cTab)->AGA_FILIAL)//1
aadd(aCurAddrs,(cTab)->AGA_CODIGO)
aadd(aCurAddrs,(cTab)->AGA_ENTIDA)
aadd(aCurAddrs,(cTab)->AGA_CODENT)
aadd(aCurAddrs,(cTab)->AGA_TIPO)//5
aadd(aCurAddrs,(cTab)->AGA_NAMENT)
aadd(aCurAddrs,(cTab)->AGA_PADRAO)
aadd(aCurAddrs,(cTab)->AGA_MUN)
aadd(aCurAddrs,(cTab)->AGA_PAIS)
aadd(aCurAddrs,(cTab)->AGA_CEP)//10
aadd(aCurAddrs,(cTab)->AGA_EST)
aadd(aCurAddrs,(cTab)->AGA_BAIRRO)
aadd(aCurAddrs,(cTab)->AGA_MUNDES)
aadd(aCurAddrs,(cTab)->AGA_COMP)
aadd(aCurAddrs,(cTab)->AGA_END)//15
aadd(aCurAddrs,(cTab)->AGA_HOUSE)
aadd(aCurAddrs,(cTab)->AGA_BLDNG)
aadd(aCurAddrs,(cTab)->AGA_APARTM)//18
aadd(aCurAddrs,(cTab)->AGA_FORWHO)
aadd(aCurAddrs,(cTab)->AGA_FROM)//20
aadd(aCurAddrs,(cTab)->AGA_TO)

cAgaFull := alltrim((cTab)->AGA_CEP)
cAgaFull += ", " + alltrim((cTab)->AGA_BAIRRO) + alltrim((cTab)->AGA_MUNDES)
cAgaFull += ", " + alltrim((cTab)->AGA_END)
cAgaFull += ", " + alltrim((cTab)->AGA_HOUSE)
cAgaFull += ", " + alltrim((cTab)->AGA_BLDNG)
cAgaFull += ", " + alltrim((cTab)->AGA_APARTM) 
cAgaFull += "."

aadd(aCurAddrs,cAgaFull)
RestArea(aAreaTMPTAB)
return aCurAddrs

/*{Protheus.doc}MPStruCRUS

Função de definição de estrutura da tabela complementar de empresas para Rússia 

@author Sérgio Silveira 
@since  22/03/2017

@return oTblRus Objeto TableStruct

@protected

*/
Function MPStruCRUS(cAlias)

Local aFieldsRUS   AS ARRAY

Local cDriver      AS CHAR 
Local cTableName   AS CHAR

Local nX           AS NUMERIC 

Local oTblRus      AS OBJECT


aFieldsRUS := {}
//cDriver    := __cRDD
nX         := 0
 

DEFAULT cAlias := "COMP_RUS"

#IFDEF WAXS
	cDriver := "DBFCDXAX"
#ENDIF

If MPDicInDB()
	cDriver := "TOPCONN"
EndIf

cTableName := MPSysTblPrefix() + "SYS_COMPANY_L_RUS"

oTblRus	:= FWTableStruct():New(cTableName,cAlias,cDriver)

//Campos para chave igual a da XX8


AADD(aFieldsRUS,{"CO_COMPGRP",	"C",	012,	0})
AADD(aFieldsRUS,{"CO_COMPEMP",	"C",	012,	0})
AADD(aFieldsRUS,{"CO_COMPUNI",	"C",	012,	0})
AADD(aFieldsRUS,{"CO_TIPO",		"C",	001,	0})
AADD(aFieldsRUS,{"CO_TYPE",		"C",	001,	0})
AADD(aFieldsRUS,{"CO_FULLNAM",	"C",	250,	0})
AADD(aFieldsRUS,{"CO_SHORTNM",	"C",	250,	0})
AADD(aFieldsRUS,{"CO_PHONENU",	"C",	050,	0})
AADD(aFieldsRUS,{"CO_FAX",		"C",	050,	0})
AADD(aFieldsRUS,{"CO_EMAIL",	"C",	050,	0})
AADD(aFieldsRUS,{"CO_OGRN",		"C",	015,	0})
AADD(aFieldsRUS,{"CO_REGDATE",	"D",	008,	0})
AADD(aFieldsRUS,{"CO_OKPO",		"C",	010,	0})
AADD(aFieldsRUS,{"CO_INN",		"C",	012,	0})
AADD(aFieldsRUS,{"CO_KPP",		"C",	009,	0})
AADD(aFieldsRUS,{"CO_LOCLTAX",	"C",	004,	0})
AADD(aFieldsRUS,{"CO_LTAXNAM",	"C",	254,	0})
AADD(aFieldsRUS,{"CO_PFRREG",	"C",	014,	0})
AADD(aFieldsRUS,{"CO_FOMS",		"C",	015,	0})
AADD(aFieldsRUS,{"CO_FSS",		"C",	010,	0})
AADD(aFieldsRUS,{"CO_SUBORD",	"C",	005,	0})
AADD(aFieldsRUS,{"CO_STATIST",	"C",	005,	0})
AADD(aFieldsRUS,{"CO_OKTMO",	"C",	011,	0})
AADD(aFieldsRUS,{"CO_OKATO",	"C",	011,	0})
AADD(aFieldsRUS,{"CO_OKOGU",	"C",	007,	0})
AADD(aFieldsRUS,{"CO_OKOPF",	"C",	005,	0})
AADD(aFieldsRUS,{"CO_OKFS",		"C",	002,	0})
AADD(aFieldsRUS,{"CO_OKVED",	"C",	008,	0})


For nX := 1 To Len( aFieldsRUS )
	oTblRus:AddField( aFieldsRUS[nX,1], aFieldsRUS[nX,2], aFieldsRUS[nX,3], aFieldsRUS[nX,4] )
Next nX

oTblRus:AddIndex( '01' , { 'CO_COMPGRP' , 'CO_TIPO'    } )
oTblRus:AddIndex( '02' , { 'CO_COMPGRP' , 'CO_COMPEMP' , 'CO_TIPO'    } )
oTblRus:AddIndex( '03' , { 'CO_COMPGRP' , 'CO_COMPEMP' , 'CO_COMPUNI' , 'CO_TIPO' } )

oTblRus:AddIndex( '04' , { 'CO_INN'     } )
oTblRus:AddIndex( '05' , { 'CO_KPP'     } )

oTblRus:SetPrimaryKey( { 'CO_COMPGRP' , 'CO_COMPEMP' , 'CO_COMPUNI' , 'CO_TIPO' } )

oTblRus:Activate()

ASize( aFieldsRUS, 0 )

Return oTblRus


/*{Protheus.doc}MPStruBRUS

Função de definição de estrutura da tabela complementar de filiais para Rússia 

@author Sérgio Silveira 
@since  22/03/2017

@return oTblRus Objeto TableStruct

@protected

*/
Function MPStruBRUS(cAlias)

Local aFieldsRUS   AS ARRAY
¸
Local cDriver      AS CHAR 
Local cTableName   AS CHAR

Local nX           AS NUMERIC 

Local oTblRus      AS OBJECT

aFieldsRUS := {}
//cDriver    := __cRDD
nX         := 0

DEFAULT cAlias := "BRAN_RUS"

#IFDEF WAXS
	cDriver := "DBFCDXAX"
#ENDIF

If MPDicInDB()
	cDriver := "TOPCONN"
EndIf

cTableName := MPSysTblPrefix() + "SYS_BRANCH_L_RUS"

oTblRus	:= FWTableStruct():New(cTableName,cAlias,cDriver)



AADD(aFieldsRUS,{"BR_COMPGRP",	"C",	012,	0})
AADD(aFieldsRUS,{"BR_COMPEMP",	"C",	012,	0})
AADD(aFieldsRUS,{"BR_COMPUNI",	"C",	012,	0})
AADD(aFieldsRUS,{"BR_BRANCH",	"C",	012,	0})
AADD(aFieldsRUS,{"BR_TIPO",		"C",	001,	0})
AADD(aFieldsRUS,{"BR_TYPE",		"C",	001,	0})
AADD(aFieldsRUS,{"BR_FULLNAM",	"C",	250,	0})
AADD(aFieldsRUS,{"BR_SHORTNM",	"C",	250,	0})
AADD(aFieldsRUS,{"BR_PHONENU",	"C",	050,	0})
AADD(aFieldsRUS,{"BR_FAX",		"C",	050,	0})
AADD(aFieldsRUS,{"BR_EMAIL",	"C",	050,	0})
AADD(aFieldsRUS,{"BR_OKPO",		"C",	010,	0})
AADD(aFieldsRUS,{"BR_KPP",		"C",	009,	0})
AADD(aFieldsRUS,{"BR_SUBDIVI",	"C",	001,	0})
AADD(aFieldsRUS,{"BR_DIGIVAT",	"C",	005,	0})
AADD(aFieldsRUS,{"BR_LOCLTAX",	"C",	004,	0})
AADD(aFieldsRUS,{"BR_LTAXNAM",	"C",	254,	0})
AADD(aFieldsRUS,{"BR_PFRREG",	"C",	014,	0})
AADD(aFieldsRUS,{"BR_FOMS",		"C",	015,	0})
AADD(aFieldsRUS,{"BR_FSS",		"C",	010,	0})
AADD(aFieldsRUS,{"BR_SUBORD",	"C",	005,	0})
AADD(aFieldsRUS,{"BR_STATIST",	"C",	005,	0})
AADD(aFieldsRUS,{"BR_OKTMO",	"C",	011,	0})
AADD(aFieldsRUS,{"BR_OKATO",	"C",	011,	0})
AADD(aFieldsRUS,{"BR_OKOGU",	"C",	007,	0})
AADD(aFieldsRUS,{"BR_OKOPF",	"C",	005,	0})
AADD(aFieldsRUS,{"BR_OKFS",		"C",	002,	0})
AADD(aFieldsRUS,{"BR_OKVED",	"C",	008,	0})


For nX := 1 To Len( aFieldsRUS )
	oTblRus:AddField( aFieldsRUS[nX,1], aFieldsRUS[nX,2], aFieldsRUS[nX,3], aFieldsRUS[nX,4] )
Next nX

oTblRus:AddIndex( "01", {"BR_COMPGRP", "BR_COMPEMP", "BR_COMPUNI", "BR_BRANCH"} )
oTblRus:AddIndex( "02", {"BR_KPP"} )

oTblRus:SetPrimaryKey( {"BR_COMPGRP", "BR_COMPEMP", "BR_COMPUNI", "BR_BRANCH"} )

oTblRus:Activate()

ASize( aFieldsRUS, 0 ) 

Return oTblRus


//updated for automatically patch.