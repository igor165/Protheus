#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINJD14.ch"
#include "MSGRAPHI.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINJD14   | Autor | Luis Delorme          | Data | 19/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Consulta de Nível de Atendimento John Deere                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD14()
//

Local aObjects 	:= {}
Local aSizeAut	:= MsAdvSize(.t.)

Private oFnt3 := TFont():New( "Arial", , 14,.t. )
Private oVerm    := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Pedido
Private oVerd    := LoadBitmap( GetResources() , "BR_VERDE" ) 	// Reservados
Private lNewGrpDPM := (SBM->(FieldPos('BM_VAIDPM')) > 0)
Private cMarcas := ""
Private oSqlHlp := DMS_SqlHelper():New()
cAl1 := GetNextAlias()
cQuery := "SELECT B1_COD FROM " + RetSqlName("SB1")
cQuery += " WHERE B1_FILIAL ='" + xFilial("SB1")+ "' AND "
cQuery += oSqlHlp:CompatFunc('SUBSTR') + "(B1_COD,1,4) = 'TS00' AND  D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl1, .F., .T. )

aVet := {}

while !((cAl1)->(eof()))
	aAdd( aVet, (cAl1)->(B1_COD) )
	(cAl1)->(DBSkip())
enddo

AAdd( aObjects, { 0,	75, .T., .F. } )
AAdd( aObjects, { 0,	80, .T., .F. } )
AAdd( aObjects, { 0,	00, .T., .T. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }	// Tamanho total da tela
aPosObj := MsObjSize( aInfo, aObjects ) 										// Monta objetos conforme especificacoes

oDlgXX001 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],STR0001,,,,128,,,,,.t.)
// oDlgXX001:bInit := {|| EnchoiceBar(oDlgXX001, { || FS_APLICA() } , { || oDlgXX001:End()  },,{} )}
oDlgXX001:lCentered := .F.

oPanel1 := TPanel():New(aPosObj[1,1] ,aPosObj[1,2],"",oDlgXX001,NIL,.T.,.F.,NIL,NIL,aPosObj[1,4] - aPosObj[1,2], aPosObj[1,3] - aPosObj[1,1],.T.,.F.)
oPanel2 := TPanel():New(aPosObj[2,1] ,aPosObj[2,2],"",oDlgXX001,NIL,.T.,.F.,NIL,NIL,aPosObj[2,4] - aPosObj[1,2], aPosObj[2,3] - aPosObj[2,1],.T.,.F.)

nLarg4 = (aPosObj[1,4] - 6) / 4
nLarg2 = (aPosObj[1,4] - 6) / 2
nLarg1 = (aPosObj[1,4] - 6)
/////////////////////////////////////////////////////////////////////////////////////////////////////////
aPosObj1 := {}
aAdd(aPosObj1,{3,3         , aPosObj[1,3] - aPosObj[1,1] - 6 , nLarg4  })
aAdd(aPosObj1,{3,nLarg4    , aPosObj[1,3] - aPosObj[1,1] - 6 , nLarg4 * 3 })
oPanel1_1 := TPanel():New(aPosObj1[1,1] ,aPosObj1[1,2],"",oPanel1,NIL,.T.,.F.,NIL,NIL,aPosObj1[1,4],aPosObj1[1,3],.T.,.F.)
oPanel1_2 := TPanel():New(aPosObj1[2,1] ,aPosObj1[2,2],"",oPanel1,NIL,.T.,.F.,NIL,NIL,aPosObj1[2,4],aPosObj1[2,3],.T.,.F.)
/////////////////////////////////////////////////////////////////////////////////////////////////////////
dDatIni := stod(STRZERO(Year(ddatabase),4) + STRZERO(Month(ddatabase),2) + "01")
dDatFim := dDatabase
nLin := aPosObj1[1,3] / 5
oSay01 := TSay():New(  3 ,3,{|| STR0002 },oPanel1_1,,oFnt3,,,,.t.,CLR_BLACK,,120,8)
@3 , aPosObj1[1,4] / 2 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE aPosObj1[1,4] / 2 - 4 ,8 PIXEL OF oPanel1_1
oSay01 := TSay():New(nLin ,3,{|| STR0003 },oPanel1_1,,oFnt3,,,,.t.,CLR_BLACK,,120,8)
@ nLin , aPosObj1[1,4] / 2 MSGET oDatFim VAR dDatFim PICTURE "@D" SIZE aPosObj1[1,4] / 2 - 4 ,8 PIXEL OF oPanel1_1
@ nLin*2,3 BUTTON oSalvar PROMPT STR0004 OF oPanel1_1 SIZE aPosObj1[1,4] - 8 ,10 PIXEL ACTION ( FS_APLICA() ) 
@ nLin*3,3 BUTTON oImprime PROMPT STR0032 OF oPanel1_1 SIZE aPosObj1[1,4] - 8 ,10 PIXEL ACTION ( OFNJD14IMP() ) // Imprimir
@ nLin*4,3 BUTTON oSalvar2 PROMPT STR0027 OF oPanel1_1 SIZE aPosObj1[1,4] - 8 ,10 PIXEL ACTION ( oDlgXX001:End() ) 
/////////////////////////////////////////////////////////////////////////////////////////////////////////
nCel := ((aPosObj1[2,4])-10) / 4
aSM0       := FS_Filiais()
@ 0,0 LISTBOX oLbEmp FIELDS HEADER " ",STR0005,STR0010 COLSIZES 10,60,120 SIZE aPosObj1[2,4]-3,aPosObj1[2,3] OF oPanel1_2 ;
ON DBLCLICK (aSM0[oLbEmp:nAt,1] := !aSM0[oLbEmp:nAt,1]) PIXEL
oLbEmp:SetArray(aSM0)
oLbEmp:bLine := { || { IIF(aSM0[oLbEmp:nAt,01],oVerd,oVerm) , aSM0[oLbEmp:nAt,02] , aSM0[oLbEmp:nAt,03] }}
lMarcarEmp := .f.
oLbEmp:bHeaderClick := { |oObj,nCol| IIf( nCol == 1 , ( lMarcarEmp := !lMarcarEmp , aEval( aSM0 , { |x| x[1] := lMarcarEmp } ) ) ,Nil) , oLbEmp:Refresh() }
/////////////////////////////////////////////////////////////////////////////////////////////////////////
aPosObj2 := {}
aAdd(aPosObj2,{3,3         , aPosObj[2][3] - aPosObj[2][1] - 6 , nLarg2 })
aAdd(aPosObj2,{3,nLarg2    , aPosObj[2][3] - aPosObj[2][1] - 6 , nLarg2 })
oPanel2_1 := TPanel():New(aPosObj2[1,1] ,aPosObj2[1,2],"",oPanel2,NIL,.T.,.F.,NIL,NIL,aPosObj2[1,4],aPosObj2[1,3],.T.,.F.)
oPanel2_2 := TPanel():New(aPosObj2[2,1] ,aPosObj2[2,2],"",oPanel2,NIL,.T.,.F.,NIL,NIL,aPosObj2[2,4],aPosObj2[2,3],.T.,.F.)
oSay01 := TSay():New(3,3,{|| STR0006 },oPanel2_1,,oFnt3,,,,.t.,CLR_BLACK,,120,8)
oSay01 := TSay():New(3,3,{|| STR0007 },oPanel2_2,,oFnt3,,,,.t.,CLR_BLACK,,120,8)
/////////////////////////////////////////////////////////////////////////////////////////////////////////
nCel := ((aPosObj1[2,4])-10) / 4
aVE1 := FS_Marcas()
@ 0,0 LISTBOX oLbMar FIELDS HEADER " ",STR0005,STR0006;
COLSIZES 10,60,90 SIZE aPosObj2[1,4]-3,aPosObj2[1,3] OF oPanel2_1;
ON DBLCLICK (aVE1[oLbMar:nAt,1] := !aVE1[oLbMar:nAt,1], FS_REFSBM())  PIXEL
oLbMar:SetArray(aVE1)
oLbMar:bLine := { || { IIF(aVE1[oLbMar:nAt,01],oVerd,oVerm) , aVE1[oLbMar:nAt,02] , aVE1[oLbMar:nAt,03] }}
lMarcarMar := .f.
oLbMar:bHeaderClick := { |oObj,nCol| IIf( nCol == 1 , ( lMarcarMar := !lMarcarMar , aEval( aVE1 , { |x| x[1] := lMarcarMar } ) ) ,Nil) , oLbMar:Refresh(),FS_REFSBM() }
/////////////////////////////////////////////////////////////////////////////////////////////////////////
nCel := ((aPosObj1[2,4])-10) / 4
aSBM := {{.f.,"",""}}
@ 0,0 LISTBOX oLbGru FIELDS HEADER " ",STR0005,STR0007;
COLSIZES 10,60,90 SIZE aPosObj2[2,4]-3,aPosObj2[2,3] OF oPanel2_2 ;
ON DBLCLICK (aSBM[oLbGru:nAt,1] := !aSBM[oLbGru:nAt,1]) PIXEL
oLbGru:SetArray(aSBM)
oLbGru:bLine := { || { IIF(aSBM[oLbGru:nAt,01],oVerd,oVerm) , aSBM[oLbGru:nAt,02] , aSBM[oLbGru:nAt,03] }}
lMarcarGru := .f.
oLbGru:bHeaderClick := { |oObj,nCol| IIf( nCol == 1 , ( lMarcarGru := !lMarcarGru , aEval( aSBM , { |x| x[1] := lMarcarGru } ) ) ,Nil) , oLbGru:Refresh() }
/////////////////////////////////////////////////////////////////////////////////////////////////////////

nCel := (aPosObj[3,4]-10)/3
nCel16 := (aPosObj[3,4]-10)/16
nCel17 := (aPosObj[3,4]-10)/17
//
aNivAte := {{" ",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}
aNivAteP := {{" ",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}
//
aTitulo = { STR0001,STR0008,STR0009 }
 
oFoldX001 := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitulo,{}, oDlgXX001,,,,.t.,.f.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1])
// oFoldX001:bSetOption := { |x| MsgInfo("Aqui") }
oFoldX001:SetOption(1)

@ 0,0 LISTBOX oLbNivAte FIELDS HEADER STR0010,STR0011, STR0012,STR0013,STR0014,STR0015,STR0016, STR0012,STR0013,STR0014,STR0015,STR0017, STR0012,STR0013,STR0014,STR0015 ;
COLSIZES nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16,nCel16 SIZE aPosObj[3,4] - aPosObj[3,2] - 1 ,aPosObj[3,3]-aPosObj[3,1]-14 OF oFoldX001:aDialogs[1] ; 
ON CHANGE ( FS_GRAFICO() ) PIXEL 
oLbNivAte:Align := CONTROL_ALIGN_ALLCLIENT
oLbNivAte:SetArray(aNivAte)
oLbNivAte:bLine := { || { aNivAte[oLbNivAte:nAt,01] , ; //empresa
Transform(aNivAte[oLbNivAte:nAt,02],"@E 9999999"), ; //HITS B
Transform(aNivAte[oLbNivAte:nAt,03]*100,"@E 999.99%"), ; // IMED
Transform(aNivAte[oLbNivAte:nAt,04]*100,"@E 999.99%"), ; // 8
Transform(aNivAte[oLbNivAte:nAt,05]*100,"@E 999.99%"), ; // 8D
Transform(aNivAte[oLbNivAte:nAt,06]*100,"@E 999.99%"), ; // 24
Transform(aNivAte[oLbNivAte:nAt,07],"@E 9999999"), ;
Transform(aNivAte[oLbNivAte:nAt,08]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,09]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,10]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,11]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,12],"@E 9999999"), ;
Transform(aNivAte[oLbNivAte:nAt,13]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,14]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,15]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,16]*100,"@E 999.99%") }}

@ 0,0 LISTBOX oLbNivAte2 FIELDS HEADER STR0018,STR0011, STR0012,STR0013,STR0014,STR0014,STR0016, STR0012,STR0013,STR0014,STR0014,STR0017, STR0012,STR0013,STR0014,STR0014 ;
COLSIZES nCel17 * 2,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17,nCel17 SIZE aPosObj[3,4] - aPosObj[3,2] - 1 ,aPosObj[3,3]-aPosObj[3,1]-14 OF oFoldX001:aDialogs[3] 
oLbNivAte2:Align := CONTROL_ALIGN_ALLCLIENT
oLbNivAte2:SetArray(aNivAteP)
oLbNivAte2:bLine := { || { aNivAteP[oLbNivAte2:nAt,01] , ;
Transform(aNivAteP[oLbNivAte2:nAt,02],"@E 9999999"), ;
Transform(aNivAteP[oLbNivAte2:nAt,03]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,04]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,05]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,06]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,07],"@E 9999999"), ;
Transform(aNivAteP[oLbNivAte2:nAt,08]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,09]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,10]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,11]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,12],"@E 9999999"), ;
Transform(aNivAteP[oLbNivAte2:nAt,13]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,14]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,15]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,16]*100,"@E 999.99%") }}

oPanel3_21 := TPanel():New(0 ,0,"",oFoldX001:aDialogs[2],NIL,.T.,.F.,NIL,NIL,nCel, aPosObj[3,3] - aPosObj[3,1] - 15 ,.T.,.F.)
oPanel3_22 := TPanel():New(0 ,0 + nCel,"",oFoldX001:aDialogs[2],NIL,.T.,.F.,NIL,NIL,nCel, aPosObj[3,3] - aPosObj[3,1] - 15,.T.,.F.)
oPanel3_23 := TPanel():New(0 ,0 + nCel * 2,"",oFoldX001:aDialogs[2],NIL,.T.,.F.,NIL,NIL,nCel, aPosObj[3,3] - aPosObj[3,1] - 15,.T.,.F.)

oDlgXX001:Activate()
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_Filiais | Autor |  Manoel		          | Data | 13/09/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Retorna as Filiais da Empresa                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_Filiais()
Local nCntFor := 0
Local aSM0_1  := FWLoadSM0()
Local aSM0_2  := {}
local oDpm    := DMS_Dpm():New()

aFils := oDpm:GetFiliais()

For nCntFor := 1 to Len(aSM0_1)
	If aSM0_1[nCntFor,SM0_GRPEMP] == cEmpAnt
		lIsDpm := ascan(aFils, {|f| f[1] == aSM0_1[nCntFor,SM0_CODFIL] }) > 0
		if lIsDpm
			aadd(aSM0_2,{.f., aSM0_1[nCntFor,SM0_CODFIL], aSM0_1[nCntFor,SM0_NOMRED]})
		endif
	Endif
Next

Return(aSM0_2)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_Marcas  | Autor |  Manoel		          | Data | 13/09/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Retorna as Marcas  da Empresa                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_Marcas()
Local aRet  := {}
DBSelectArea("VE1")
DBSetOrder(1)
DbSeek(xFilial('VE1'))
while !eof() .AND. VE1->VE1_FILIAL == xFilial('VE1')
	aAdd( aRet, {.f.,VE1->VE1_CODMAR, VE1->VE1_DESMAR})
	DBSkip()
enddo
if Empty(aRet)
	aAdd(aRet, {.f.,'Nenhuma', 'Nenhuma'})
endif
Return(aRet)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_REFSBM  | Autor |  Manoel		          | Data | 13/09/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Retorna os grupos de peças das marcas                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_REFSBM()
//
Local nCntFor
//
cMarcas := "("
For nCntFor := 1 to Len(aVE1)
	if aVE1[nCntFor,1]
		cMarcas += "'"+aVE1[nCntFor,2]+"',"
	endif
next
if cMarcas == "("
	aSBM := {{.f.,"",""}}
else
	cMarcas = Left(cMarcas,Len(cMarcas)-1)
	cMarcas += ")"
	cAl1 := GetNextAlias()
	cQuery := "SELECT BM_GRUPO, BM_DESC FROM " + RetSqlName("SBM")
	cQuery += " WHERE BM_FILIAL ='" + xFilial("SBM")+ "' AND"
	cQuery += " BM_CODMAR IN " + cMarcas + " AND"
	cQuery += " D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl1, .F., .T. )
	aSBM := {}
	while !((cAl1)->(eof()))
	 	aAdd(aSBM,{.f.,(cAl1)->(BM_GRUPO), (cAl1)->(BM_DESC)})
		(cAl1)->(DBSkip())
	enddo
	(cAl1)->(dbCloseArea())
	if Len(aSBM) == 0
		aSBM := {{.f.,"",""}}
	endif
endif

oLbGru:SetArray(aSBM)
oLbGru:bLine := { || { IIF(aSBM[oLbGru:nAt,01],oVerd,oVerm) , aSBM[oLbGru:nAt,02] , aSBM[oLbGru:nAt,03] }}
oLbGru:Refresh()

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_APLICA  | Autor |  Luis Delorme         | Data | 13/09/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Monta resultados das consultas (tabelas e gráficos)          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_APLICA()
Local nCntFor
local cQuery
local cQuery2
local cInMarcas := ""

If lNewGrpDPM
	cGrupos := "(SELECT BM_GRUPO FROM "+RetSqlName('SBM')+" WHERE BM_FILIAL = '"+xFilial('SBM')+"' AND BM_VAIDPM = '1' AND D_E_L_E_T_ = ' ')"
Else
	cGrupos := "("
	For nCntFor := 1 to Len(aSBM)
		if aSBM[nCntFor,1]
			cGrupos += "'"+aSBM[nCntFor,2]+"',"
		endif
	next
	if cGrupos == "("
		return
	endif

	cGrupos = Left(cGrupos,Len(cGrupos)-1)
	cGrupos += ")"
Endif 
//
cFiliais := "("
For nCntFor := 1 to Len(aSM0)
	if aSM0[nCntFor,1]
		cFiliais += "'"+aSM0[nCntFor,2]+"',"
	endif
next
if cFiliais == "("
	return
endif

cFiliais = Left(cFiliais,Len(cFiliais)-1)
cFiliais += ")"


cInMarcas := IIF(Empty(cMarcas) .OR. ALLTRIM(cMarcas) == "(", "", " AND BM_CODMAR IN "+cMarcas)

//
cAl1   := GetNextAlias()   //VB8_ANO, VB8_MES, VB8_DIA, 
cQuery := "SELECT VB8_FILIAL, SUM(VB8_HIPERB) VB8_HIPERB, SUM(VB8_HITSB) VB8_HITSB, SUM(VB8_IMEDB) VB8_IMEDB, SUM(VB8_8HRDB) VB8_8HRDB, SUM(VB8_8HROB) VB8_8HROB,"
cQuery += "       SUM(VB8_24HRB) VB8_24HRB, SUM(VB8_HITSO) VB8_HITSO, SUM(VB8_IMEDO) VB8_IMEDO, SUM(VB8_8HRDO) VB8_8HRDO, SUM(VB8_8HROO) VB8_8HROO, SUM(VB8_24HRO) VB8_24HRO, "
cQuery += "       SUM(VB8_HITSI) HITSI, SUM(VB8_IMEDI) IMEDI, SUM(VB8_8HRDI) HRDI8, SUM(VB8_8HROI) HROI8, SUM(VB8_24HRI) HRI24 "
cQuery += " FROM  "+RetSQLName("VB8")+" VB8 "
cQuery += "       JOIN "+RetSQLName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND VB8_PRODUT = B1_COD   AND B1_GRUPO IN " + cGrupos
cQuery += "       JOIN "+RetSQLName("SBM")+" SBM ON BM_FILIAL = '"+xFilial('SBM')+"' AND BM_GRUPO   = B1_GRUPO AND SBM.D_E_L_E_T_ = ' ' " + cInMarcas
cQuery += " WHERE (VB8_ANO " + FG_CONVSQL("CONCATENA") + " VB8_MES " + FG_CONVSQL("CONCATENA") + " VB8_DIA) >= '" + dtos(dDatIni) + "' AND "
cQuery += "       (VB8_ANO " + FG_CONVSQL("CONCATENA") + " VB8_MES " + FG_CONVSQL("CONCATENA") + " VB8_DIA) <= '" + dtos(dDatFim) + "' AND "
cQuery += "       VB8.D_E_L_E_T_ = ' ' AND "
cQuery += "       VB8_FILIAL IN "+cFiliais
cQuery += " GROUP BY VB8_FILIAL ORDER BY VB8_FILIAL "

cAl2    := GetNextAlias()   
cQuery2 := "SELECT B1_GRUPO, B1_CODITE, SUM(VB8_HIPERB) VB8_HIPERB, SUM(VB8_HITSB) VB8_HITSB, SUM(VB8_IMEDB) VB8_IMEDB, SUM(VB8_8HRDB) VB8_8HRDB, SUM(VB8_8HROB) VB8_8HROB,"
cQuery2 += "       SUM(VB8_24HRB) VB8_24HRB, SUM(VB8_HITSO) VB8_HITSO, SUM(VB8_IMEDO) VB8_IMEDO, SUM(VB8_8HRDO) VB8_8HRDO, SUM(VB8_8HROO) VB8_8HROO, SUM(VB8_24HRO) VB8_24HRO, "
cQuery2 += "       SUM(VB8_HITSI) HITSI, SUM(VB8_IMEDI) IMEDI, SUM(VB8_8HRDI) HRDI8, SUM(VB8_8HROI) HROI8, SUM(VB8_24HRI) HRI24 "
cQuery2 += " FROM "+RetSQLName("VB8")+" VB8 "
cQuery2 += "       JOIN "+RetSQLName("SB1")+" SB1 ON VB8_PRODUT = B1_COD AND B1_FILIAL = '"+xFilial("SB1")+ "' AND B1_GRUPO IN " + cGrupos 
cQuery2 += "       JOIN "+RetSQLName("SBM")+" SBM ON BM_FILIAL = '"+xFilial('SBM')+"' AND BM_GRUPO = B1_GRUPO AND SBM.D_E_L_E_T_ = ' ' " + cInMarcas
cQuery2 += " WHERE (VB8_ANO " + FG_CONVSQL("CONCATENA") + " VB8_MES " + FG_CONVSQL("CONCATENA") + " VB8_DIA) >= '" + dtos(dDatIni) + "' AND "
cQuery2 += "       (VB8_ANO " + FG_CONVSQL("CONCATENA") + " VB8_MES " + FG_CONVSQL("CONCATENA") + " VB8_DIA) <= '" + dtos(dDatFim) + "' AND "
cQuery2 += "       VB8.D_E_L_E_T_ = ' ' AND "
cQuery2 += "       VB8_FILIAL IN "+cFiliais
cQuery2 += " GROUP BY B1_GRUPO, B1_CODITE "
cQuery2 += " ORDER BY B1_GRUPO, B1_CODITE "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery  ), cAl1, .F., .T. )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cAl2, .F., .T. )

aTotal  := {STR0018,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
nVPerdB := 0
nHBTot  := 0
nVPerdO := 0
nHOTot  := 0
aNivAte := {}
while !((cAl1)->(eof()))
	aNiv := {}
	nHBTot   := (cAl1)->(VB8_HITSB) + (cAl1)->(VB8_HIPERB)
	nHOTot   := (cAl1)->(VB8_HITSO) // + (cAl1)->(VB8_HIPERO) // nao tem ainda
	nImedTot := (cAl1)->(VB8_IMEDB) + (cAl1)->(VB8_IMEDO)
 
	aAdd(aNiv, (cAl1)->(VB8_FILIAL))
	// balcao
	aAdd(aNiv, nHBTot) // hits total balcao
	aAdd(aNiv, (cAl1)->(VB8_IMEDB) / nHBTot )
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	// oficina
	aAdd(aNiv, nHOTot )
	aAdd(aNiv, (cAl1)->(VB8_IMEDO) / nHOTot)
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	// total
	aAdd(aNiv, nHBTot + nHOTot)
	aAdd(aNiv, nImedTot / (nHBTot + nHOTot))
	aAdd(aNiv, 0 )
	aAdd(aNiv, 0 )
	aAdd(aNiv, 0 )
	
	aTotal[2] += nHBTot
	aTotal[3] += (cAl1)->(VB8_IMEDB)
	aTotal[4] += 0
	aTotal[5] += 0
	aTotal[6] += 0
	aTotal[7] += nHOTot
	aTotal[8] += (cAl1)->(VB8_IMEDO)
	aTotal[9] += 0
	aTotal[10] += 0
	aTotal[11] += 0
	aTotal[12] += nHBTot + nHOTot
	aTotal[13] += nImedTot
	aTotal[14] += 0
	aTotal[15] += 0
	aTotal[16] += 0

	aAdd(aNivAte, aNiv)
	(cAl1)->(DBSkip())
enddo  

aTotal[3]  := aTotal[3] / aTotal[2]
aTotal[8]  := aTotal[8] / aTotal[7]
aTotal[13] := aTotal[13] / aTotal[12]

aAdd(aNivAte, aTotal)

aNivAteP := {}
nHBTot   := 0
nHOTot   := 0
while !((cAl2)->(eof()))
	aNiv     := {}
	nHBTot   := (cAl2)->(VB8_HITSB) + (cAl2)->(VB8_HIPERB)
	nHOTot   := (cAl2)->(VB8_HITSO) // + (cAl2)->(VB8_HIPERO) // nao tem ainda
	nImedTot := (cAl2)->(VB8_IMEDB) + (cAl2)->(VB8_IMEDO)

	aAdd(aNiv, (cAl2)->(B1_GRUPO) + " " + (cAl2)->(B1_CODITE)  )
	// balcao
	aAdd(aNiv, nHBTot)
	aAdd(aNiv, (cAl2)->(VB8_IMEDB) / nHBTot)
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	// oficina
	aAdd(aNiv, nHOTot )
	aAdd(aNiv, (cAl2)->(VB8_IMEDO) / nHOTot)
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	// total
	aadd(aNiv, nHBTot + nHOTot)
	aAdd(aNiv, nImedTot / (nHBTot + nHOTot))
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	aAdd(aNiv, 0)
	
	aAdd(aNivAteP, aNiv)
	(cAl2)->(DBSkip())
enddo


if Len(aNivAte) == 0
	aNivAte := {{" ",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}
endif 

if Len(aNivAteP) == 0
	aNivAteP := {{" ",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}
endif

aSort(aNivAteP,,,{|x,y| x[2] > y[2] })

(cAl1)->(dbCloseArea())
(cAl2)->(dbCloseArea())

oLbNivAte:SetArray(aNivAte)
oLbNivAte:bLine := { || { aNivAte[oLbNivAte:nAt,01] , ;
Transform(aNivAte[oLbNivAte:nAt,02],"@E 9999999"), ;
Transform(aNivAte[oLbNivAte:nAt,03]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,04]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,05]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,06]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,07],"@E 9999999"), ;
Transform(aNivAte[oLbNivAte:nAt,08]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,09]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,10]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,11]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,12],"@E 9999999"), ;
Transform(aNivAte[oLbNivAte:nAt,13]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,14]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,15]*100,"@E 999.99%"), ;
Transform(aNivAte[oLbNivAte:nAt,16]*100,"@E 999.99%") }}
oLbNivAte:Refresh()

oLbNivAte2:SetArray(aNivAteP)
oLbNivAte2:bLine := { || { aNivAteP[oLbNivAte2:nAt,01] , ;
Transform(aNivAteP[oLbNivAte2:nAt,02],"@E 9999999"), ;
Transform(aNivAteP[oLbNivAte2:nAt,03]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,04]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,05]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,06]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,07],"@E 9999999"), ;
Transform(aNivAteP[oLbNivAte2:nAt,08]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,09]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,10]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,11]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,12],"@E 9999999"), ;
Transform(aNivAteP[oLbNivAte2:nAt,13]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,14]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,15]*100,"@E 999.99%"), ;
Transform(aNivAteP[oLbNivAte2:nAt,16]*100,"@E 999.99%") }}
oLbNivAte2:Refresh()

FS_GRAFICO()

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRAFICO ³ Autor ³ Luis Delorme        ³ Data ³ 19/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta os Gráficos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAFICO()

oGraphic1 := TMSGraphic():New( 0,0,oPanel3_21,,,RGB(239,239,239),(aPosObj[3,4]-10)/3,aPosObj[3,3] - aPosObj[3,1] - 15)
oGraphic1:SetMargins(0,0,0,0)
oGraphic1:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)
oGraphic1:SetTitle(STR0001+" "+STR0019, "", CLR_BLACK, A_CENTER, .f. )

oGraphic2 := TMSGraphic():New( 0,0,oPanel3_22,,,RGB(239,239,239),(aPosObj[3,4]-10)/3,aPosObj[3,3] - aPosObj[3,1] - 15)
oGraphic2:SetMargins(0,0,0,0)
oGraphic2:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)
oGraphic2:SetTitle(STR0001+" "+STR0020, "", CLR_BLACK, A_CENTER, .f. )

oGraphic3 := TMSGraphic():New( 0,0,oPanel3_23,,,RGB(239,239,239),(aPosObj[3,4]-10)/3,aPosObj[3,3] - aPosObj[3,1] - 15)
oGraphic3:SetMargins(0,0,0,0)
oGraphic3:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)
oGraphic3:SetTitle(STR0001+" "+STR0021, "", CLR_BLACK, A_CENTER, .f. )

nSerie1 := oGraphic1:CreateSerie( GRP_PIE )
nSerie2 := oGraphic2:CreateSerie( GRP_PIE )
nSerie3 := oGraphic3:CreateSerie( GRP_PIE )

oGraphic1:Add(nSerie1, Round(aNivAte[oLbNivAte:nAt,3]*100,1), STR0022, CLR_HGREEN )
oGraphic1:Add(nSerie1, Round(aNivAte[oLbNivAte:nAt,4]*100,1), STR0023, CLR_GREEN )
oGraphic1:Add(nSerie1, Round(aNivAte[oLbNivAte:nAt,5]*100,1), STR0024, CLR_YELLOW )
oGraphic1:Add(nSerie1, Round(aNivAte[oLbNivAte:nAt,6]*100,1), STR0025, CLR_HCYAN )
oGraphic1:Add(nSerie1, Round((1 - aNivAte[oLbNivAte:nAt,3] - aNivAte[oLbNivAte:nAt,4] - aNivAte[oLbNivAte:nAt,5] - aNivAte[oLbNivAte:nAt,6]) *100,2), STR0026, CLR_RED )

oGraphic2:Add(nSerie2, Round(aNivAte[oLbNivAte:nAt,8]*100,1), STR0022, CLR_HGREEN )
oGraphic2:Add(nSerie2, Round(aNivAte[oLbNivAte:nAt,9]*100,1), STR0023, CLR_GREEN )
oGraphic2:Add(nSerie2, Round(aNivAte[oLbNivAte:nAt,10]*100,1), STR0024, CLR_YELLOW )
oGraphic2:Add(nSerie2, Round(aNivAte[oLbNivAte:nAt,11]*100,1), STR0025, CLR_HCYAN )
oGraphic2:Add(nSerie2, Round((1 - aNivAte[oLbNivAte:nAt,8] - aNivAte[oLbNivAte:nAt,9] - aNivAte[oLbNivAte:nAt,10] - aNivAte[oLbNivAte:nAt,11]) *100,2), STR0026, CLR_RED )

oGraphic3:Add(nSerie3, Round(aNivAte[oLbNivAte:nAt,13]*100,1), STR0022, CLR_HGREEN )
oGraphic3:Add(nSerie3, Round(aNivAte[oLbNivAte:nAt,14]*100,1), STR0023, CLR_GREEN )
oGraphic3:Add(nSerie3, Round(aNivAte[oLbNivAte:nAt,15]*100,1), STR0024, CLR_YELLOW )
oGraphic3:Add(nSerie3, Round(aNivAte[oLbNivAte:nAt,16]*100,1), STR0025, CLR_HCYAN )
oGraphic3:Add(nSerie3, Round((1 - aNivAte[oLbNivAte:nAt,13] - aNivAte[oLbNivAte:nAt,14] - aNivAte[oLbNivAte:nAt,15] - aNivAte[oLbNivAte:nAt,16]) *100,2), STR0026, CLR_RED )

Return

/*/{Protheus.doc} OFNJD14IMP

Função que efetua a impressão do relatório de nivel de atendimento

@author Renato Vinicius
@since 14/09/2017
@type function

/*/

Function OFNJD14IMP()

//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef

Função para criar as celulas que serão impressas

@author Renato Vinicius
@since 14/09/2017
@type function

/*/

Static Function ReportDef()

Local cPerg     := "OFN14I"


//AADD(aRegs,{STR0028, STR0028, STR0028, "mv_ch1", "N", 1, 0, 1, "C", '' , "mv_par01", STR0029, STR0029 , STR0029 , "" , "" , STR0009 , STR0009, STR0009 , "" , "" , STR0031 , STR0031 , STR0031 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , {},{},{}})

Pergunte(cPerg,.f.)

oReport := TReport():New("OFINJD14",;	//Nome do Relatório
	STR0001,;			//Título do Relatório - "Nível de Atendimento"
	"OFN14I",;								//Nome da Pergunta
	{|oReport| ReportPrint(oReport)},; //Bloco de código que será executado na confirmação
	STR0030) // Descrição do relatório // "Este relatório irá imprimir o nível de atendimento"
	
oReport:nFontBody := 8
oReport:SetTotalInLine(.F.) //Define se os totalizadores serão impressos em linha ou coluna.
oReport:SetLandscape() //Imprime o relatório em Paisagem

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection1 := TRSection():New(oReport,"Nível de Atendimento - Empresa",/*{Array de tabelas}*/,/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Romaneio de Saída de Peças"
oSection1:SetAutoSize(.t.)

TRCell():New(oSection1,"cEmpre" ,,STR0010	,			 ,40,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cHitsB" ,,STR0011	,"@E 9999999",25,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNAImdB",,STR0012	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNA8hFB",,STR0013	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNA8hOB",,STR0014	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNA24hB",,STR0015	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cHitsO" ,,STR0016	,"@E 9999999",25,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNAImdO",,STR0012	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNA8hFO",,STR0013	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNA8hOO",,STR0014	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNA24hO",,STR0015	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cHitsT" ,,STR0017	,"@E 9999999",25,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNAImdT",,STR0012	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNA8hFT",,STR0013	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNA8hOT",,STR0014	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection1,"cNA24hT",,STR0015	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)

oSection2 := TRSection():New(oReport,"Nível de Atendimento - Itens",{"VB8","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Romaneio de Saída de Peças"

oSection2:SetAutoSize(.t.)

TRCell():New(oSection2,"cItem"	  ,,STR0009	,			 ,40,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cHitsBP" ,,STR0011	,"@E 9999999",25,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNAImdBP",,STR0012	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNA8hFBP",,STR0013	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNA8hOBP",,STR0014	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNA24hBP",,STR0015	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cHitsOP" ,,STR0016	,"@E 9999999",25,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNAImdOP",,STR0012	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNA8hFOP",,STR0013	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNA8hOOP",,STR0014	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNA24hOP",,STR0015	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cHitsTP" ,,STR0017,"@E 9999999",25,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNAImdTP",,STR0012	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNA8hFTP",,STR0013	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNA8hOTP",,STR0014	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)
TRCell():New(oSection2,"cNA24hTP",,STR0015	,"@E 999.99%",20,/*lPixel*/,/*{|| FS_LEVORC()  }*/,,,,.t.,,.t.)

Return(oReport)

/*/{Protheus.doc} ReportPrint

Função para adicionar as informações que serão impressas

@author Renato Vinicius
@since 14/09/2017
@type function

/*/

Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local nPosNv := 0
Local nPosNvP:= 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo TrPosition()                                                     ³
//³                                                                        ³
//³Posiciona em um registro de uma outra tabela. O posicionamento será     ³
//³realizado antes da impressao de cada linha do relatório.                ³
//³                                                                        ³
//³                                                                        ³
//³ExpO1 : Objeto Report da Secao                                          ³
//³ExpC2 : Alias da Tabela                                                 ³
//³ExpX3 : Ordem ou NickName de pesquisa                                   ³
//³ExpX4 : String ou Bloco de código para pesquisa. A string será macroexe-³
//³        cutada.                                                         ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If MV_PAR01 == 1 .or. MV_PAR01 == 3
	oSection1:Init()

	For nPosNv := 1 to Len(aNivAte)

		oSection1:Cell("cEmpre"	):SetValue( aNivAte[nPosNv,1]) //Insere o conteudo no espaço destinado
		oSection1:Cell("cHitsB"	):SetValue( aNivAte[nPosNv,2]) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNAImdB"):SetValue( aNivAte[nPosNv,3]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNA8hFB"):SetValue( aNivAte[nPosNv,4]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNA8hOB"):SetValue( aNivAte[nPosNv,5]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNA24hB"):SetValue( aNivAte[nPosNv,6]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cHitsO"	):SetValue( aNivAte[nPosNv,7]) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNAImdO"):SetValue( aNivAte[nPosNv,8]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNA8hFO"):SetValue( aNivAte[nPosNv,9]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNA8hOO"):SetValue( aNivAte[nPosNv,10]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNA24hO"):SetValue( aNivAte[nPosNv,11]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cHitsT"	):SetValue( aNivAte[nPosNv,12]) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNAImdT"):SetValue( aNivAte[nPosNv,13]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNA8hFT"):SetValue( aNivAte[nPosNv,14]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNA8hOT"):SetValue( aNivAte[nPosNv,15]*100) //Insere o conteudo no espaço destinado
		oSection1:Cell("cNA24hT"):SetValue( aNivAte[nPosNv,16]*100) //Insere o conteudo no espaço destinado
		oSection1:PrintLine()

	Next

	oSection1:Finish()
EndIf

If MV_PAR01 == 2 .or. MV_PAR01 == 3
	oSection2:Init()

	For nPosNvP := 1 to Len(aNivAteP)

		oSection2:Cell("cItem")   :SetValue( aNivAteP[nPosNvP,1]) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cHitsBP") :SetValue( aNivAteP[nPosNvP,2]) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNAImdBP"):SetValue( aNivAteP[nPosNvP,3]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNA8hFBP"):SetValue( aNivAteP[nPosNvP,4]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNA8hOBP"):SetValue( aNivAteP[nPosNvP,5]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNA24hBP"):SetValue( aNivAteP[nPosNvP,6]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cHitsOP") :SetValue( aNivAteP[nPosNvP,7]) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNAImdOP"):SetValue( aNivAteP[nPosNvP,8]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNA8hFOP"):SetValue( aNivAteP[nPosNvP,9]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNA8hOOP"):SetValue( aNivAteP[nPosNvP,10]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNA24hOP"):SetValue( aNivAteP[nPosNvP,11]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cHitsTP") :SetValue( aNivAteP[nPosNvP,12]) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNAImdTP"):SetValue( aNivAteP[nPosNvP,13]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNA8hFTP"):SetValue( aNivAteP[nPosNvP,14]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNA8hOTP"):SetValue( aNivAteP[nPosNvP,15]*100) //Insere o conteudo no espaço destinado 
		oSection2:Cell("cNA24hTP"):SetValue( aNivAteP[nPosNvP,16]*100) //Insere o conteudo no espaço destinado 
		oSection2:PrintLine()

	Next

	oSection2:Finish()

EndIf

Return
