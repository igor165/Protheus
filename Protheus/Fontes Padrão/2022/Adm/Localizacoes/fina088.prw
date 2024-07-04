#Include "FINA088.CH"
#Include "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWLIBVERSION.CH"

Static _oFINA0881
Static _oFINA0882

Static lExistFKD	:= ExistFunc("FAtuFKDBx")
STATIC lExistVa		:= ExistFunc("FValAcess")
Static __lF088EAI	:= NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA088  ³ Autor ³ BRUNO SOBIESKI                             ³ Data ³ 12/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ CANCELAMENTO DO RECIBO.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA088()                                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			                            ATUALIZACOES SOFRIDAS					               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³WagnerMontenegro³08/06/10³          ³Implementado tratamento para cancelamento do ITF e con-³±±
±±³                 ³       ³          ³tabilização.                                           ³±±
±±³RobertoGonzález ³01/03/17³          ³Se añaden filtros en la anulación para borrar solamente³±± 
±±³                ³        ³          ³los propios registros.                                 ³±±
±±³Raul Ortiz      ³07/06/17³MMI-5895  ³Modificaciones para Mexico "Complemento de Recepción de³±± 
±±³                ³        ³          ³Pagos.                                                 ³±±
±±³Luis Enríquez   ³19/04/18³DMINA-2015³Se modifica func. para tomar valor de nVlrBaiP de      ³±± 
±±³                ³        ³          ³acuerdo a E5_MOEDA.  (COL)                             ³±±
±±³Diego Rivera    ³05/06/18³DMINA-2202³Replica de DMINA-1557: Se modifica función FA088CKMX   ³±± 
±±³                ³        ³          ³para que permita selección de recibos ya timbrados     ³±±
±±³                ³        ³          ³para poder realizar la impresión de los mismos.        ³±±
±±³                ³        ³          ³En Fun menuDef se agrega función FA088IMP que es       ³±±
±±³                ³        ³          ³la encargada de realizar la impresión del recibo en PDF³±±
±±³                ³        ³          ³Así mismo se agrega función FA088IMPPDF que se encarga ³±±
±±³                ³        ³          ³de detonar FINA815 para generación del PDF.            ³±±
±±³ Marco A.       ³13/07/18³DMANSISTE-³Se replica para V12.1.17 la solucion realizada en      ³±±
±±³                ³        ³16        ³issue DMINA-1227, el cual soluciona la correcta        ³±±
±±³                ³        ³          ³actualizacion del campo E5_SITUACA cuando se anula     ³±±
±±³                ³        ³          ³un Cobro Diverso. (MEX)                                ³±±
±±³Luis Enríquez   ³16/07/18³DMINA-3630³Se replica funcionalidad atendida en DMINA-62 de Factu-³±±
±±³                ³        ³          ³ración de Anticipos. (PER)                             ³±± 
±±³Luis Enríquez   ³23/08/18³DMINA-3941³Se realiza adecuación para envío de mensaje para anula-³±±
±±³                ³        ³          ³ción de baja de títulos por cobrar mediante integración³±± 
±±³                ³        ³          ³EAI. (MEX)                                             ³±± 
±±³Oscar Garcia    ³06/11/18³DMINA-4461³Se replica para v12.1.17 la solucion realizada en issue³±±
±±³                ³        ³          ³DMINA-4049, el cual valida el parámetro MV_VERICFD para³±± 
±±³                ³        ³          ³informar al usuario que debe informar el parámetro. MEX³±±
±±³Verónica Flores ³30/11/18³DMINA-4874³Se remueven las validaciones donde verífica            ³±±
±±³                ³        ³          ³que los recibos son de tipo RA de las funciones        ³±±    
±±³                ³        ³          ³fa088Imp y fa088CFDI. MEX                              ³±±
±±³Verónica Flores ³18/12/18³DMINA-4989³Se agrega funcionalidad del parametro MV_CFDREC        ³±±
±±³                ³        ³          ³para la generación del complemento de Pagos en la      ³±±    
±±³                ³        ³          ³en la función fa088CFDI                                ³±±
±±³ Marco A. Glez  ³18/01/19³DMINA-5246³Se agregan validaciones para timbrado e impresion de   ³±±
±±³ Luis Enriquez  ³        ³          ³Recibos, cuando estos esten o no marcado para generar  ³±±    
±±³                ³        ³          ³CFDI. (MEX)                                            ³±±
±±³ Luis Enríquez  ³30/05/19³DMINA-6614³Se agrega funcionalidad para borrado de recibos de baja³±±
±±³                ³        ³          ³de titulos por cobrar de tipo DGA. (MEX)               ³±±
±±³Oscar Garcia    ³09/07/19³DMINA-6961³Se crean las func. PesqKeyCTB,ArmaKeyCTB y AtuCTBFF    ³±±
±±³                ³        ³          ³para actualizar UUID en tabla CT2 y CTK al realizar el ³±± 
±±³                ³        ³          ³timbrado despues de captura de cobro diverso. MEX      ³±±
±±³Oscar Garcia    ³14/11/19³DMINA-7824³Se ajusta macrosustitucion Fun. AtuCTBFF(MEX)          ³±±
±±³Oscar Garcia    ³29/01/20³DMINA-7825³Se indicar alias de la base para campos de SE5 en fun. ³±±
±±³                ³        ³          ³F088DelSE5(). (MEX)                                    ³±±
±±³ Luis Enríquez  ³30/05/19³DMINA-6614³Se agrega llamado a la función F815VldTim() para vali- ³±±
±±³                ³        ³          ³dar timbrado de recibos previos sin timbrar (MEX)      ³±±
±±³José González   ³08/07/20³DMINA-9242³Se agrega loop a ciclo do while en función F088DelSE5  ³±±
±±³                ³        ³          ³desdpues del dbskip (MEX)                              ³±±
±±³José González   ³10/08/20³DMINA-9386³Se Cambia en la función AtuCTBFF el Count to a Lastrec ³±±
±±³                ³        ³          ³y se elimina DBGotop (MEX)                             ³±±
±±³Oscar Garcia    ³18/11/20³DMINA-    ³Se añade tratamiento para abrir PDF generado al Timbrar³±±
±±³                ³        ³     10169³o Imprimir en Fun. fa088CFDI y fa088Imp. (MEX)         ³±±
±±³José González   ³24/11/20³DMINA-    ³En la función Cancela() se modifica en el llamado a    ³±±
±±³                ³        ³     10504³Sel070Baixa el tipo RA para Peru (PER)                 ³±±
±±³Verónica Flores ³14/02/21³DMINA-    ³En la función FA088Integ() se modifica el llamado a    ³±±
±±³                ³        ³     10747³la función para adaptador EAI (MEX)                    ³±±
±±³Oscar Garcia    ³15/02/21³DMINA-    ³En Func Cancela() se altera tratamiento a titulos proc-³±±
±±³                ³        ³     10939³esados para actualizar campo E1_BAIXA mediante  la     ³±±
±±³                ³        ³          ³función ActBajaSE1(). (MEX)                            ³±±
±±³Oscar Garcia    ³17/03/21³DMINA-    ³En Func f088AtuaSE1() y F088DelSE5() se añade filtro de³±±
±±³                ³        ³     11464³movimientos generados desde FINA087A. (MEX)            ³±±
±±³ Marco A.       ³18/06/21³  DMINA-  ³Se agrega tratamiento en funcion FA088ChkCFDI() para   ³±±
±±³                ³        ³     12829³validar la serie en caso de que exista en el Recibo.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fina088(nOpcAuto,lMsg,aCab,aResponse,jData)

Local lPergunte := .F.
Local cChave
Local aCampos := {}
Local cIndOrdPag
Local cIndArqTmp
Local aCpos := {}
Local cPerg := "FIN088"
Local lF088NP1 := ExistBlock ("F088NP1")
Local lF088NP2 := ExistBlock ("F088NP2")
Local aCores := {}
Local cVersion := GetRpoRelease()

Default aResponse 	:= 	{} //Variable para recibos totvs (FINA998)
Default jData		:= JsonObject():New()


If  cVersion >= "12.1.2210"  .and. cpaisloc <> "BRA" .and. funname() == "FINA088"
   	FWCallApp( "FINA998") 
ElseIf  cVersion <= "12.1.033".and. cpaisloc <> "BRA" .and. funname() == "FINA088"
	If FindFunction("ExpRot088")
   	    ExpRot088("FINA088",;  
   	                "CANCELACIÓN DE RECIBO (FINA088)",;
   	                "https://tdn.totvs.com/pages/releaseview.action?pageId=625965279" )
   	EndIf
EndIf

If nOpcAuto = 3 .And. !Empty(aCab)
	lPergunte := .F.
Else
	If IsPanelFin()
		lPergunte := PergInPanel(cPerg,.T.)
	Else
	   lPergunte := pergunte(cPerg,.T.)
	Endif	
Endif

If !lPergunte .And. nOpcAuto != 3
	Return
EndIf

Private cCond	:= ".T."
Private nDecs := MsDecimais(mv_par06)
Private cCadastro := OemToAnsi(STR0009) 
Private aPos:= {  8,  4, 11, 74 }
Private lInverte := .F.
Private cMarcaTR       
Private cCodDiario := ""
Private aDiario :={}
Private aDoctos := {}

DEFAULT nOpcAuto := 0
DEFAULT lMsg := .F.
DEFAULT aCab := {}

AADD(aCampos,{ "MARK"     , "C", 2, 0 })
AADD(aCampos,{ "SERIE "   , "C", TamSX3("EL_SERIE")[1], 0 })
AADD(aCampos,{ "NUMERO"   , "C", TamSX3("EL_RECIBO")[1], 0 })
AADD(aCampos,{ "PARCELA"   , "C", TamSX3("EL_PARCELA")[1], 0 })
AADD(aCampos,{ "CLIENTE"  , "C", TamSX3("EL_CLIENTE")[1], 0 })
AADD(aCampos,{ "SUCURSAL" , "C", TamSX3("EL_LOJA")[1], 0 })
AADD(aCampos,{ "CLIORIG"  , "C", TamSX3("EL_CLIORIG")[1], 0 })
AADD(aCampos,{ "SUCORIG"  , "C", TamSX3("EL_LOJORIG")[1], 0 })
AADD(aCampos,{ "TOTALBRUT", "N", 17, nDecs })
AADD(aCampos,{ "TOTALRET" , "N", 17, nDecs })
AADD(aCampos,{ "TOTALRAS" , "N", 17, nDecs })
AADD(aCampos,{ "TOTALNETO", "N", 17, nDecs })
AADD(aCampos,{ "EMISION"  , "D",  8, 0 })
AADD(aCampos,{ "NATUREZA", "C",  TamSX3("EL_NATUREZA")[1], 0 })
AADD(aCampos,{ "CHEQUE"  , "C",  1, 0 })
If cPaisLoc == "MEX"
	AADD(aCampos,{ "FECTIMB"  , "D",  TamSX3("EL_FECTIMB")[1], 0 })
	AADD(aCampos,{ "UUID"  , "C",  TamSX3("EL_UUID")[1], 0 })
	If SEL->(ColumnPos("EL_GENCFD")) > 0
		aAdd(aCampos, {"GENCFD", "C",  TamSX3("EL_GENCFD")[1], 0 })
	EndIf
	If SEL->(ColumnPos("EL_TIPAGRO")) > 0
		aAdd(aCampos, {"EL_TIPAGRO", "C",  TamSX3("EL_TIPAGRO")[1], 0 })
	EndIf
EndIF
AADD(aCampos,{ "CANCELADA", "C",  1, 0 })
AADD(aCampos,{ "PODE", "C",  1, 0 })
AADD(aCampos,{ "COBRADOR", "C", TamSX3("EL_COBRAD")[1], 0 })
If SEL->(ColumnPos("EL_HORA")) > 0
	AADD(aCampos,{ "HORA", "C", TamSX3("EL_HORA")[1], 0 })
EndIf

If cPaisLoc = "MEX" .and. lF088NP1
  aCampos := ExecBlock ("F088NP1",.F.,.F.,aCampos)
EndIf

If(_oFINA0881 <> NIL)
	_oFINA0881:Delete()
	_oFINA0881 := NIL

EndIf

//Cria o Objeto do FwTemporaryTable
_oFINA0881 := FwTemporaryTable():New("TRB")

//Cria a estrutura do alias temporario
_oFINA0881:SetFields(aCampos)

//Adiciona o indicie na tabela temporaria
_oFINA0881:AddIndex("1",{"SERIE","NUMERO"})

//Criando a Tabela Temporaria
_oFINA0881:Create()

cIndOrdPag :=	CriaTrab(Nil,.F.)
cIndArqTmp :=	CriaTrab(Nil,.F.)


cChave   := "EL_FILIAL+EL_CLIENTE+EL_LOJA+EL_SERIE+EL_RECIBO" 

DbSelectArea("SEL")
If ExistBlock('F088FLT')
	cCond	:=	ExecBlock('F088FLT',.F.,.F.)
Endif
IndRegua("SEL",cIndArqTmp,cChave,,cCond,OemToAnsi(STR0043))  // "Creando Archivo..."
nIndex   := Retindex("SEL")

DbSetOrder(nIndex+1)

Processa({|| GeraTRB()})

Retindex("SEL")
Ferase(cIndArqTmp+OrdBagExt())

If BOF() .and. EOF()
	Help(" ",1,"RECNO")
Else
	aCpos:={}
	AADD(aCpos,{ "MARK"     , "","" })
	AADD(aCpos,{ "SERIE"   , "", OemToAnsi(STR0023) })  //"Serie"
	AADD(aCpos,{ "NUMERO"   , "", OemToAnsi(STR0002) })  //"Recibo"
	AADD(aCpos,{ "PARCELA"   , "", OemToAnsi(STR0128) })  //"Recibo"
	AADD(aCpos,{ "CLIORIG"  , "", OemToAnsi(STR0050) })  //"Cliente"
	AADD(aCpos,{ "SUCORIG" , "", OemToAnsi(STR0003) })  //"Suc."
	AADD(aCpos,{ "TOTALBRUT", "", OemToAnsi(STR0004),PesqPict("SEL","EL_VALOR",16,mv_par06) })  //"Total Bruto"
	AADD(aCpos,{ "TOTALRET" , "", OemToAnsi(STR0005) })  //"Retenciones"
	AADD(aCpos,{ "TOTALRAS" , "", OemToAnsi(STR0006),PesqPict("SEL","EL_VALOR",16,mv_par06) })  //"RCs. Anticipados"
	AADD(aCpos,{ "TOTALNETO", "", OemToAnsi(STR0007),PesqPict("SEL","EL_VALOR",16,mv_par06) })  //"Total Neto"
	AADD(aCpos,{ "EMISION"  , "", OemToAnsi(STR0008) })  //"Emitida"
        
	If cPaisLoc = "MEX" .and. lF088NP2
  		aCpos := ExecBlock ("F088NP2",.F.,.F.,aCpos)
	EndIf

	Private aRotina := MenuDef()
	
	lInverte:=.F.
	cMarcaTR := GetMark()
	
	If ( nOpcAuto > 0 )
		F088TEL("TRB","MARK","CANCELADA+PODE",aCpos,cMarcaTR,nOpcAuto,aCab,lMsg,@aResponse,@jData)
	Else	
		If cPaisLoc=="ARG"
			aAdd(aCores,{' Empty(CANCELADA) .and. Empty(TRB->PODE) .and. Empty(TRB->CHEQUE)'	, "BR_VERDE"   })
			Aadd(aCores,{' Empty(CANCELADA) .and. TRB->PODE == "C"  '							, "BR_PINK" })
			Aadd(aCores,{'!Empty(CANCELADA) .OR. !Empty(TRB->PODE) .OR.  TRB->CHEQUE=="U"  '	, "BR_VERMELHO"})
	    	Aadd(aCores,{' Empty(CANCELADA) .and. Empty(TRB->PODE) .and. TRB->CHEQUE=="L"  '	, "BR_AMARELO" })
	    	Aadd(aCores,{' Empty(CANCELADA) .and. Empty(TRB->PODE) .and. TRB->CHEQUE=="N"  '	, "BR_LARANJA" })
	  		MarkBrow("TRB","MARK","CANCELADA+PODE",aCpos,,cMarcaTR,"FA088MkAll('TRB','TRB->NUMERO')",.F.,,,"FA088CkCan('TRB',TRB->NUMERO)",,,,aCores)
		ElseIf cPaisLoc == "MEX"
			AAdd(aCores,{' TRB->CANCELADA == "P"' , "BR_AMARELO" }) //Anulada pero sin timbrar
     		Aadd(aCores,{' !Empty(CANCELADA) .AND. TRB->CANCELADA <> "P"'		, "BR_VERMELHO"	})
     		AAdd(aCores,{'  Empty(CANCELADA)  .AND. Empty(TRB->FECTIMB) .AND. Empty(TRB->UUID)' , "BR_VERDE"   	})
     		AAdd(aCores,{' !Empty(TRB->FECTIMB) .AND. !Empty(TRB->UUID) .AND. Empty(CANCELADA)' 	, 'BR_AZUL'		})		// Timbrado	|
  			MarkBrow("TRB","MARK","",aCpos,,cMarcaTR,,.F.,,,"FA088CKMX('TRB',TRB->NUMERO)",,,,aCores)
		Else
			MarkBrow("TRB","MARK","CANCELADA+PODE",aCpos,,cMarcaTR,,.F.)
		Endif
	ENDIF

	If(_oFINA0881 <> NIL)
		_oFINA0881:Delete()
		_oFINA0881 := NIL
	
	EndIf

EndIf
RETURN

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ GeraTRB  ¦ Autor ¦ Bruno Sobieski        ¦ Data ¦ 12/07/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Genera el archivo de trabajo.                              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ PAG0018                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GeraTRB()
Local aRegs 	:= {}
Local cPode		:= ""
Local cQuery	:= ""
Local cAliasSEL := ""
Local lFilCanc 	:= If( mv_par01==1,.T.,.F.)
Local lF088NP3 	:= ExistBlock("F088NP3")
Local nTB 		:= 0
Local nTR 		:= 0
Local nTRa		:= 0 
Local nI 		:= 0   
Local nComp		:= 0
Local nOrdSE1	:= (SE1->(indexord()))
Local aChaveTmp := {}
Local cRcboAnt
Local cForAnt
Local cLojaAnt 
Local cSerAnt
Local nRet
Local lHora := SEL->(ColumnPos("EL_HORA")) > 0


SE1->(DbSetOrder(2))

If(_oFINA0882 <> NIL)

	_oFINA0882:Delete()
	_oFINA0882 := NIL

EndIf

dbSelectArea("SEL")
aStruTRB := SEL->(DbStruct())
	
cQuery := "SELECT  "
		
For nI:=1 To Len(aStruTRB)
	cQuery += aStruTRB[nI][1]+","
Next nI

//Pegando a Chave 1 da tabela SEL para a chave da tabela temporaria
aChaveTmp := Strtokarr2( SEL->(IndexKey(1)), "+" , .F.)

//Criando o Objeto FwTemporaryTable
_oFINA0882 := FwTemporaryTable():New("TRB1")

//Setando a estrutura da tabela temporaria
_oFINA0882:SetFields(aStruTRB)

//Criando o indicie da tabela temporaria
_oFINA0882:AddIndex("1",aChaveTmp)

//Criando a Tabela temporaria
_oFINA0882:Create()

cQuery += " SEL.R_E_C_N_O_  "
cQuery += "  FROM "+	RetSqlName("SEL") + " SEL "
cQuery += "  WHERE SEL.EL_RECIBO BETWEEN '"+MV_PAR02+"' And '"+MV_PAR03+"' And SEL.EL_SERIE = '" +MV_PAR07+"'"
If !lFilCanc
	If SEL->(ColumnPos("EL_RETGAN")) > 0
		cQuery += "	  AND  (SEL.EL_CANCEL = 'F' OR (SEL.EL_CANCEL = 'T' AND SEL.EL_RETGAN = 'S')) "
	Else 
		cQuery += "	  AND  SEL.EL_CANCEL <> 'T' "
	EndIf
EndIf 
cQuery += "   AND  SEL.EL_FILIAL = '" + xFilial("SEL") + "'"
cQuery += "	  AND  SEL.EL_TIPODOC <> 'TJ' "
cQuery += "   AND  SEL.D_E_L_E_T_ <> '*' "
MsAguarde({|| SqlToTrb(cQuery, aStruTRB, 'TRB1' )},OemToAnsi(STR0043))
DbSelectArea("TRB1")
TRB1->(DbGoTop())
cAliasSEL := "TRB1"
ProcRegua(Reccount())
WHILE !TRB1->(EOF()) .And. (TRB1->EL_RECIBO >= mv_par02 .And. TRB1->EL_RECIBO <= Lower(mv_par03)) .And. AllTrim(TRB1->EL_SERIE) == AllTrim(mv_par07)
	nTB:=0
	nTR:=0
	nTRa:=0    
	nComp:=0
	//VldUltOp()
	IF   EL_TIPODOC <> "TJ" .And. &cCond
		cSerAnt   :=    EL_SERIE
		cRcboAnt  :=	EL_RECIBO
		cForAnt   :=	EL_CLIENTE
		cLojaAnt  :=	EL_LOJA
		cPode	  := ""
		TRB->(DbAppend())
		TRB->CLIENTE  :=EL_CLIENTE
		TRB->SUCURSAL :=EL_LOJA
		TRB->EMISION  :=EL_DTDIGIT
		TRB->SERIE    :=EL_SERIE
		TRB->PARCELA  :=EL_PARCELA 
		TRB->NUMERO   :=EL_RECIBO
		TRB->CANCELADA:=IIF(EL_CANCEL,"S","")
		TRB->COBRADOR	:=EL_COBRAD
		TRB->CLIORIG 	:=EL_CLIORIG
		TRB->SUCORIG 	:=EL_LOJORIG
		TRB->NATUREZA	:=EL_NATUREZA
		If lHora
			TRB->HORA :=EL_HORA
		EndIf
		If cPaisLoc = "MEX"
			TRB->FECTIMB 	:= EL_FECTIMB
			TRB->UUID		:= EL_UUID
			If SEL->(ColumnPos("EL_GENCFD")) > 0
				TRB->GENCFD	:= EL_GENCFD
			EndIf			
			If lF088NP3
		 		ExecBlock ("F088NP3",.F.,.F.,"TRB")
			EndIf
			If SEL->(ColumnPos("EL_RETGAN")) > 0
				If EL_RETGAN == "S"
					TRB->CANCELADA := "P"
				EndIf
			EndIf
			If SEL->(ColumnPos("EL_TIPAGRO")) > 0
				TRB->EL_TIPAGRO := EL_TIPAGRO
			EndIf
		EndIf
		
		If GetMV("MV_DATAFIN") >= EL_DTDIGIT 
			cPode:= "N"
		Endif    
		aRegs := {}
		Do While EL_RECIBO==cRcboAnt .And. EL_SERIE == cSerAnt
			IncProc()
			If Subs(EL_TIPODOC,1,2)=="TB"
				If EL_TIPO $ MVRECANT+"/"+MV_CRNEG
					nComp+= If( mv_par06==1,EL_VLMOED1,xMoeda(EL_VALOR,Max(Val(EL_MOEDA),1),mv_par06,EL_DTDIGIT,nDecs+1))
				Else
					nTB+= If( mv_par06==1,EL_VLMOED1,xMoeda(EL_VALOR,Max(Val(EL_MOEDA),1),mv_par06,EL_DTDIGIT,nDecs+1))
				Endif
			ElseIf   Subs(EL_TIPODOC,1,2)$"RI|RG|RB|RS|RR"
				nTR+= If( mv_par06==1,EL_VLMOED1,xMoeda(EL_VALOR,Max(Val(EL_MOEDA),1),mv_par06,EL_DTDIGIT,nDecs+1))
			Else
				
				//Controle de Conciliação Bancária
				aAdd(aRegs,{(cAliasSEL)->EL_PREFIXO,(cAliasSEL)->EL_NUMERO,(cAliasSEL)->EL_PARCELA,(cAliasSEL)->EL_TIPO,(cAliasSEL)->EL_CLIENTE,(cAliasSEL)->EL_LOJA,(cAliasSEL)->EL_BANCO,(cAliasSEL)->EL_AGENCIA,(cAliasSEL)->EL_CONTA})
				
				If cPode==""
					SE1->(DbSeek(xFilial("SE1")+(cAliasSEL)->EL_CLIENTE+(cAliasSEL)->EL_LOJA+(cAliasSEL)->EL_PREFIXO+(cAliasSEL)->EL_NUMERO+(cAliasSEL)->EL_PARCELA+(cAliasSEL)->EL_TIPO) )
					If SE1->(FOUND()).And.(IIf(Subs(EL_TIPODOC,1,2)=="RA",.F.,!SE1->E1_SITUACA$"0 ").OR.SE1->E1_SALDO <> SE1->E1_VALOR)
						If cPaisLoc<>"ARG"
							If SE1->E1_STATUS == "B" 
								cPode:="N"
							Else
								cPode:=""
							EndIf	
						Else
							If RTRIM(EL_TIPODOC) <> "CH"
								cPode:="N"
							Else
								nRet:=FA088CkSEF(EL_BCOCHQ,EL_AGECHQ,EL_CTACHQ,EL_PREFIXO,EL_NUMERO) //verifica se existe historico ou foi usado na OP
								If nRet == 0
									TRB->CHEQUE:="U"
									cPode:="N"
								Elseif nRet==2
									TRB->CHEQUE:="L"
								Else
									TRB->CHEQUE:="N"
								Endif
							Endif
						Endif
					Endif
				Endif
				If Subs((cAliasSEL)->EL_TIPODOC,1,2)=="RA"
					nTRa+=If( mv_par06==1,EL_VLMOED1,xMoeda(EL_VALOR,Max(Val(EL_MOEDA),1),mv_par06,EL_DTDIGIT,nDecs+1))
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar se o documento foi ajustado por diferencia ³
			//³de cambio com data posterio a OP                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			SIX->(DbSetOrder(1))
			If SIX->(DbSeek('SFR'))
				DbSelectArea('SFR')
				DbSetOrder(1)
				DbSeek(xFilial()+"1"+(cAliasSEL)->EL_CLIENTE+(cAliasSEL)->EL_LOJA+(cAliasSEL)->EL_PREFIXO+(cAliasSEL)->EL_NUMERO+(cAliasSEL)->EL_PARCELA+(cAliasSEL)->EL_TIPO+Dtos((cAliasSEL)->EL_DTDIGIT),.T.)
				If FR_FILIAL==xFilial() .And.	FR_CHAVOR==(cAliasSEL)->EL_CLIENTE+(cAliasSEL)->EL_LOJA+(cAliasSEL)->EL_PREFIXO+(cAliasSEL)->EL_NUMERO+(cAliasSEL)->EL_PARCELA+(cAliasSEL)->EL_TIPO.And.;
					SFR->FR_CARTEI=="1".And.(cAliasSEL)->EL_DTDIGIT <= SFR->FR_DATADI
					cPode	:=	'N'
				Endif			
				DbSelectArea(cAliasSEL)
			Endif                                      
			TRB1->(DbSkip())
		Enddo
		
		//Conciliação Bancária
		If cPaisLoc != "BRA" .AND. F472VldConc(aRegs)
			cPode := "C" //Conciliado		
		EndIf		
		
		TRB->PODE:=cPode
		TRB->TOTALBRUT:=Round(nTB,nDecs)
		TRB->TOTALRET :=Round(nTR,nDecs)
		TRB->TOTALRAS :=Round(nTRa,nDecs)
		TRB->TOTALNETO:=nTB-nTR-nComp+nTRa
	Else
		IncProc()
		TRB1->(DbSkip())
	Endif
EndDo
SE1->(Dbsetorder(nOrdSE1))

If(_oFINA0882 <> NIL)

	_oFINA0882:Delete()
	_oFINA0882 := NIL

EndIf
Return        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ RCBO019  ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ CANCELACION DE LA ORDEN DE RCBO                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ FINA088                                                    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦  DATA    ¦ BOPS ¦                  ALTERACAO                          ¦¦¦
¦¦+----------+------+-----------------------------------------------------¦¦¦
¦¦¦19.05.99	 ¦Melhor¦Modificacion para impedir que sean cancelados recibos¦¦¦
¦¦¦        	 ¦      ¦con algun cheque que no esta en cartera.   			  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function fa088Cancel(cAlias,nReg,nOpcx,cControl,lMsg,aResponse,jData)
Local lOk := .T.           
Local lCfdi33 :=  SuperGetMv("MV_CFDI33",.F.,.F.) .Or. SuperGetMV("MV_CFDI40", .F., .F.) 

Default lMsg := .F.
Default cControl := ""
Default aResponse := {}
Default jData	:= JsonObject():New()

If ExistBlock("FA088OK")
	lOk := ExecBlock("FA088OK",.F.,.F.)
Endif

If lOk
	If UsaSeqCor() 
		If !FinOkDiaCTB()
			lOk := .F.
		endif
	Endif
	
	If nOpcx == 3
		lBorrar := .F.
	Else
		lBorrar := .T.
	Endif
	If cPaisLoc == "MEX"
	    If !Empty(TRB->PODE) //si tiene cheque liquidado no permite anular
	       If jData['origin'] ==  "FINA998" 
				AADD(aResponse,{.F.,400,STR0133,""})
			Else
	      		MsgAlert(STR0133) //"Contiene cheque liquidado y no se permite la anulación o borrado."
		    EndIf
			Return
	    EndIf 
	EndIf
	If cPaisLoc == "MEX" .And. lCfdi33
		If !FA088AnuBor(lBorrar,@aResponse,@jData)	// Validar cancelacion o borrado; depende si el recibo está o no timbrado
			Return
		Endif
	Endif

	If lBorrar
		If(lMsg)

			Cancela(lBorrar,lMsg,@aResponse,@jData)
		
		Else
			If MsgYesNo(OemToAnsi(STR0054))
				Processa({||Cancela(lBorrar,,@aResponse,@jData)})
			EndIf
		EndIf
	ElseIf lOk
		If(lMsg)

			Cancela(lBorrar,lMsg,@aResponse,@jData)

		Else
		
			Processa({||Cancela(lBorrar,,@aResponse,@jData)})

		EndIf
	EndIf
EndIf

Return

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Static Function Cancela(lBorrar,lAutomato,aResponse,jData)
Local cAlias		:= ""
Local cKeyImp		:= ""
Local lDigita		:= If( mv_par04==1,.T.,.F.)
Local lAglutina		:= If( mv_par05==1,.T.,.F.)
Local cArquivo		:= ""
Local nHdlPrv		:= 0
Local nTotalLanc	:= 0
Local cLoteCom		:= ""
Local nLinha		:= 2
Local cPadrao		:= "576" 
Local lLanctOk		:= .F.
Local lLancPad		:= .F.
Local aFlagCTB		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local nOrdSE5		:= 0 //Usada para posicionar no indice E5_FILIAL+E5_PROCTRA
Local aTitRec		:= {}
Local aChaveCH		:= {}
Local nChaveCH		:= 0
Local cFilSEF		:= ""
Local cFilFRF		:= ""
Local cChaveCH		:= ""   
Local nRegSM0 		:= SM0->(RecNo())
Local nRegAnt		:= SM0->(RecNo())	
Local nColig		:=GetNewPar("MV_RMCOLIG",0)//integracao Protheus X TOP Argentina/Mexico
Local lMsgUnica		:= IsIntegTop()
Local lRet			:= .T.//so sera possivel cancelar o recibo se o RA nao estiver associado no Totvs Obras e projetos.
Local cFilLoop 		:=""
Local cChaveSE1 	:= ""
Local aAreaSE1		:= {}
Local lCfdi33		:= SuperGetMv("MV_CFDI33",.F.,.F.) .Or. SuperGetMV("MV_CFDI40", .F., .F.) 
Local aAnulados		:= {}
Local aNoAnulados	:= {}
Local cMsg			:= ""
Local lReconc		:= .F.
Local nX			:= 0
Local aChaveSE1		:= {}

//Variables para uso de Telemetria
Local cIdMetrica	:= "financiero-protheus_cantidad-de-anulaciones-recibo-de-cobro-por-pais-por-empresa_total" //Identificador de Métrica
Local cSubRutina	:= ""
Local lMetAut		:= (GetRemoteType() == 5 .Or. isBlind())
Local cMtCanR       := ""
Local cUUIDCanR     := ""
Local lCanCFDI      := .T.
Local cMsgCan       := ""
Local cMotSF3       := ""
Local lCRPTimb      := .F.
Local cRecTimb      := ""
Local cNomRec       := ""
Local lSerRec       := SuperGetMv("MV_SERREC",.F.,.F.)

Private aRatAFT   :={} //utilizado na integracao com o TOP
Private aBaixaSE5 := {}	//Atualizada pela função Sel070Baixa()
Private lBInteg   := .F.
Private lBDGA     := .F.

DEFAULT lAutomato := .F.
Default aResponse := {}
Default jData	:= JsonObject():New()

If jData['origin'] ==  "FINA998" 
	lDigita		:= jData["mv_par01"]
	lAglutina	:= jData["mv_par02"]
ENDIF

lBorrar := Iif(lBorrar==Nil,.F.,lBorrar)
nRegSM0 := SM0->(Recno())
SA1->(DbSetOrder(1))             

DbSelectArea("TRB")
DbGoTop()
ProcRegua(Reccount())

Do WHile !TRB->(EOF()) .and. lRet
BEGIN TRANSACTION
	
	IncProc()

	If(lAutomato)

		TRB->MARK := cMarcaTR

	EndIf

	If IsMArk("MARK",cMarcaTR,lInverte)
		If Fa088VldCa(TRB->NUMERO, , lBorrar)
			lCanCFDI := .T.
			//+--------------------------------------------------------------------------------+
			//¦Chequeo que no se puedan cancelar recibos cuyos cheques no estan en Cartera     ¦
			//+--------------------------------------------------------------------------------+
			If cPaisLoc == "MEX" .And. !lBorrar .And. SEL->(ColumnPos("EL_TIPAGRO")) > 0 
				cMotSF3 := F815MOTCAN(TRB->SERIE, TRB->NUMERO)
				lCRPTimb := F088TIMBRE(TRB->SERIE, TRB->NUMERO, lSerRec, @cRecTimb, @cUUIDCanR)
				If !lCRPTimb //Si no se timbró el Cobro Diverso
					If alltrim(jData["origin"]) == "FINA998"
						cMtCanR := jData["motCanc"] 
						lCanCFDI := .T.
					Else
					lCanCFDI := F88VisCanc(TRB->SERIE, TRB->NUMERO, TRB->UUID, @cMtCanR)
					EndIf
				EndIf
				If lCanCFDI 
					If cMotSF3 == "01" .And. lCRPTimb
						cMtCanR := cMotSF3
						cNomRec := IIf(lSerRec,Alltrim(TRB->SERIE) + "-","") + Alltrim(TRB->NUMERO)
						cMsgCan := STR0176 + cNomRec + STR0177 + cRecTimb + STR0178 //"Se solicitará la Cancelación ante el SAT del Complemento de Recepción de Pago " //", ya que para el Cobro Diverso que lo sustituye " //" ya fue timbrado el CFDI, ¿Desea continuar?"
					ElseIf cMtCanR == "01" .And. cMotSF3 <> cMtCanR
						cMsgCan := STR0167 //"Para el Motivo  de Cancelación 01, solo se anulará el Cobro Diverso, pero no se solicitará la cancelación del Complemento de Recepción de Pago ante el SAT, para hacerlo es necesario realizar un nuevo Cobro Diverso informando el Recibo a Sustituir. ¿Desea continuar?
					Else
						cMsgCan := STR0168 //"Se solicitará la cancelación del Complemento de Recepción de Pago y/o se anulará el Cobro Diverso, ¿Desea continuar?"
					EndIf
					IF !(alltrim(jData["origin"]) == "FINA998")
						lCanCFDI := MSGYESNO(  cMsgCan, STR0091  ) //"Complemento de Recepción de Pagos" 
					Endif
				EndIf
			EndIf

			If lCanCFDI
			// Posiciona Cliente - Sergio Camurca
			SA1->(DbSeek(xFilial("SA1")+TRB->CLIENTE+TRB->SUCURSAL))
			/**/
			cFilLoop:=""
			While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. lRet .And. alltrim(xFilial("SEL")) == PadR(SM0->M0_CODFIL,Len(Alltrim(xFilial("SEL"))))
			IF (PadR(cFilLoop,Len(Alltrim(xFilial("SEL")))) == PadR(SM0->M0_CODFIL,Len(Alltrim(xFilial("SEL"))))) .and. IIF(empty(PadR(SM0->M0_CODFIL,Len(Alltrim(xFilial("SEL"))))),!empty(cFilLoop),.T.)
				SM0->(DbSkip())
				Loop
			Endif   
			cFilLoop :=SM0->M0_CODFIL
		   	cFilAnt	:= FWGETCODFILIAL
		   	nRegAnt	:= SM0->(RecNo())	
			DbSelectArea("SEL")
			DbSetOrder(8)
			DbSeek(FwxFilial("SEL")+TRB->SERIE+TRB->NUMERO)
			Do While FwxFilial("SEL")==EL_FILIAL.AND.TRB->NUMERO==EL_RECIBO .AND. TRB->SERIE==EL_SERIE .And. lRet				 
		    	If nColig >0  .and. IntePMS() .And. SEL->EL_TIPODOC=="RA" .and. !lMsgUnica
					lRet:=FA088PMS(@aResponse,@jData)
				Endif
		    	If !(Subs(EL_TIPODOC,1,2) $ "RG|RI|RB|RS|RR")
			    	
			    	SM0->(dbGoTo(nRegSM0))
					cFilAnt := SM0->M0_CODFIL
					F088AtuaSE1(TRB->SERIE,TRB->NUMERO,,,@cChaveSE1)       
					SM0->(dbGoTo(nRegAnt))
					cFilAnt := SM0->M0_CODFIL
					If cPaisLoc $ "MEX|PER|COL" .And. AScan(aChaveSE1, cChaveSE1) == 0
						AADD(aChaveSE1, cChaveSE1)	//Array con las llaves a procesar en SE1
					EndIf
				Endif			
				If cPaisLoc == "COS"
					aAdd(aTitRec,SEL->(FwxFilial("SE1")+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO))
				EndIf
				If SE5->E5_TIPODOC == "VL" 
					lReconc:= Iif(SE5->E5_RECONC=="x", .T. , .F.)
				Endif
				If !lReconc .or. (!lReconc .and. !cPaisLoc == "CHI") 
					RecLock("SEL",.F.)
					Replace EL_CANCEL With .T.
					If cPaisLoc == "MEX" .And. SEL->(ColumnPos("EL_TIPAGRO")) > 0 .And. SEL->(ColumnPos("EL_RETGAN")) > 0
						SEL->EL_TIPAGRO := cMtCanR
						If cMtCanR == "01" 							
							SEL->EL_RETGAN := "S"
						Else
							SEL->EL_RETGAN := ""
						EndIf
					EndIf
					MsUnLock()
				EndIf
				If lRet
					If ExistBlock("FA088CAN")
						ExecBlock("FA088CAN",.F.,.F.)	
					EndIf
					IF !Empty(SEL->EL_COBRAD) .and. !(Alltrim(SEL->EL_TIPODOC) $"TB|RA")
						fa088Comis()
					EndIf
					If ALLTRIM(SEL->EL_TIPODOC) == "CH"
						Aadd(aChaveCH,{SEL->EL_BCOCHQ,SEL->EL_AGECHQ,SEL->EL_CTACHQ,SEL->EL_PREFIXO,SEL->EL_NUMERO})
					Endif
					SEL->(DbSkip())
				Endif
			EndDo
		        If cPaisLoc == "MEX" 
		        	BajaTitEAI(TRB->SERIE,TRB->NUMERO,@aResponse,@jData)
				EndIf
				F088DelSE5(TRB->SERIE,TRB->NUMERO)
				F088DelRet(aTitRec,TRB->SERIE,TRB->NUMERO)  // Borra todos los documentos relativos a Retenciones.
				F088DelNCC(TRB->SERIE,TRB->NUMERO,,TRB->PARCELA) // excluir as NCCs geradas a partir do recibo excluido
				If cPaisLoc $ "MEX|PER" .And. X3Usado("ED_OPERADT")				
					FA088DelRA(lBDGA)	//Deleta os titulos RA gerados pelo processo de adiantamento
				EndIf
				
				// Após processo de manutenção na movimentação (SE5), atualizar a data da baixa do título.
				aAreaSE1 := SE1->(GetArea())
				SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				
				If cPaisLoc $ "MEX|PER|COL"
					For nX := 1 to Len(aChaveSE1)
						ActBajaSE1(aChaveSE1[nX])
					Next nX
				Else
					ActBajaSE1(cChaveSE1)
				EndIf
				cChaveSE1 := ""
				aChaveSE1 := {}
				RestArea(aAreaSE1)
				If !lReconc .or. (!lReconc .and. !cPaisLoc == "CHI") 
					DbSelectArea("TRB")
					RecLock("TRB",.f.)
					Replace MARK      With IIF(lInverte,cMarcaTR,"  ")
					Replace CANCELADA With "Si"
					If cPaisLoc == "MEX" .And. SEL->(ColumnPos("EL_RETGAN")) > 0 .And. cMtCanR == "01"
						TRB->CANCELADA := "P"
					EndIf
					MsUnLock() 
					SM0->(DbSkip())
				EndIf
		  	End

			//Se agrega la informacion de los recibos anulados para paises diferentes de mexico
			If cPaisLoc <> "MEX"
				Aadd(aAnulados, TRB->SERIE+TRB->NUMERO)
			EndIf

			//+--------------------------------------------------------------+
			//¦ Genera asiento contable.                                     ¦
			//+--------------------------------------------------------------+
			If lRet
			   SM0->(dbGoTo(nRegSM0))
				cFilAnt := SM0->M0_CODFIL 
	
				cPadrao := "576"
				lLancPad := VerPadrao(cPadrao)
				
				If lLancPad // .and. !__TTSInUse
				
					//+--------------------------------------------------------------+
					//¦ Posiciona numero do Lote para Lancamentos do Financeiro      ¦
					//+--------------------------------------------------------------+
					dbSelectArea("SX5")
					dbSeek(xFilial()+"09FIN")
					cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
					nHdlPrv := HeadProva( cLoteCom,;
					                      "FINA088",;
					                      Substr( cUsuario, 7, 6 ),;
					                      @cArquivo )
				
					If nHdlPrv <= 0
						Help(" ",1,"A100NOPROV")
					EndIf
				EndIf
			
				If nHdlPrv > 0 
					SEL->(DbSetOrder(8))
					SEL->(DbSeek(xFilial("SEL")+TRB->SERIE+TRB->NUMERO,.F.))
					Do while !SEL->(EOF()).And.SEL->EL_RECIBO==TRB->NUMERO .And. SEL->EL_SERIE == TRB->SERIE
						If UsaSeqCor()
							aDiario := {{"SEL",SEL->(recno()),cCodDiario,"EL_NODIA","EL_DIACTB"}}
						endif
					
						SA6->(DbsetOrder(1))
						SA6->(DbSeek(xFilial("SA6")+SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA,.F.))
						SE1->(DbsetOrder(2))
						SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO,.F.))
						If SEL->EL_LA=="S"
							Do Case
								Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NCC")) )
									cAlias := "SF1"
								Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NDE")) )
									cAlias := "SF1"         
								Otherwise
									cAlias := "SF2"    
							EndCase
							cKeyImp := 	xFilial(cAlias)	+;
										SE1->E1_NUM		+;
										SE1->E1_PREFIXO	+;
										SE1->E1_CLIENTE	+;
										SE1->E1_LOJA			
							If ( cAlias == "SF1" )
								cKeyImp += SE1->E1_TIPO
							Endif
							Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, {"EL_LA", "C", "SEL", SEL->( Recno() ), 0, 0, 0} )
							Else
								RecLock("SEL",.F.)
								Replace EL_LA With "C"
								MsUnLock()
							Endif
			
							nTotalLanc := nTotalLanc + DetProva( 	nHdlPrv,;
												                    "576",;
											                    "FINA088",;
											                    cLoteCom,;
											                    nLinha,;
											                    /*lExecuta*/,;
											                    /*cCriterio*/,;
											                    /*lRateio*/,;
											                    /*cChaveBusca*/,;
											                    /*aCT5*/,;
											                    /*lPosiciona*/,;
											                    @aFlagCTB,;
											                    /*aTabRecOri*/,;
											                    /*aDadosProva*/ )
						Endif
						SEL->(DbSkip())
					ENDDO
					IF cPaisLoc $ "PER|BOL"
						nOrderSE5:=SE5->(IndexOrd())
						SE5->(dBSetOrder(8))
						IF SE5->(DbSeek(xFilial("SE5")+TRB->NUMERO+TRB->SERIE))
							Do While (xFilial("SE5")==SE5->E5_FILIAL .And. TRB->NUMERO==SE5->E5_ORDREC .And. TRB->SERIE == SE5->E5_SERREC)
						   		If !(SE5->E5_TIPODOC $ "BA/JR/MT/OG/DC") .And. SE5->E5_TIPO!="CH"  
							  		nRecOldE5:=SE5->(Recno())  
							  		nProcITF:=SE5->E5_PROCTRA
							  		If !Empty(nProcITF)
							  			nOrdSE5 := SE5ProcInd()						  		
							  			SE5->(DbSetOrder(nOrdSE5))
							  			IF SE5->(DBSeek(xFilial("SE5")+nProcITF))
						   	 				While !SE5->(Eof()) .And. SE5->E5_PROCTRA == nProcITF
			                     				If cPaisloc=="PER" .And. FinProcITF( SE5->( Recno() ),2 )
			                     					FinProcITF( SE5->( Recno() ),5,, .F.,{ nHdlPrv, "573", "", "FINA089", cLoteCom } , @aFlagCTB )
				             					EndIf							
			                     				If cPaisloc=="BOL" .And. Alltrim(SE5->E5_RECPAG) == "P" .And. Alltrim(SE5->E5_TIPODOC) == "IT" .And. FinProcITF( SE5->( Recno() ),1 )
					                	   			FinProcITF( SE5->( Recno() ),5,, .F.,{ nHdlPrv, "573", "", "FINA089", cLoteCom } , @aFlagCTB )
				             					EndIf								
				              		 			SE5->(DBSkip())
				           		 			Enddo
				           		 		EndIf				        	  		      						   
				        	  			SE5->(dBSetOrder(8))
				        	  			SE5->(DbGoTo(nRecOldE5))
				        	  		EndIf
				           		ENDIF	  
				           		SE5->(DBSkip())
							ENDDO
						ENDIF 
						SE5->(DbSetOrder(nOrderSE5))
					ENDIF
					//+-----------------------------------------------------+
					//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
					//+-----------------------------------------------------+
					RodaProva(  nHdlPrv,;
								nTotalLanc)
						//+-----------------------------------------------------+
						//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
						//+-----------------------------------------------------+
					lLanctOk := cA100Incl( cArquivo,;
								           nHdlPrv,;
								           3,;
								           cLoteCom,;
								           lDigita,;
								           lAglutina,;
								           /*cOnLine*/,;
								           /*dData*/,;
								           /*dReproc*/,;
								           @aFlagCTB,;
								           /*aDadosProva*/,;
								           aDiario )
					aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			
					If !lLanctOk
						SEL->(DbSeek(xFilial("SEL")+TRB->SERIE+TRB->NUMERO))
						Do while TRB->NUMERO==SEL->EL_RECIBO .AND. TRB->SERIE==SEL->EL_SERIE .AND. SEL->(!EOF())
							RecLock("SEL",.F.)
			           		Replace SEL->EL_LA With "S"
							MsUnLock()
							SEL->(DbSkip())
						Enddo
					EndIf
				Endif
				If lBorrar
					If !lReconc .or. (!lReconc .and. !cPaisLoc == "CHI")
						F088NumPend(TRB->SERIE,TRB->NUMERO)
						dbSelectArea("SEL")
						DbSeek(xFilial("SEL")+TRB->SERIE+TRB->NUMERO)
						Do While xFilial("SEL")==SEL->EL_FILIAL .AND. TRB->NUMERO==SEL->EL_RECIBO .AND. TRB->SERIE==SEL->EL_SERIE
							RecLock("SEL",.F.)
							dbDelete()
							MsUnLock()
							SEL->(dbSkip())
						EndDo
						dbSelectArea("TRB")
						RecLock("TRB",.F.)			
						dbDelete()
						MsUnLock()
					EndIf
				EndIf
	      		/*
	      		Atualiza os arquivos de controle de cheques recebidos*/
	      		If !Empty(aChaveCH)
					cFilSEF := xFilial("SEF")
					
					For nChaveCH := 1 To Len(aChaveCH)
						If cPaisLoc <> 'BRA'
							cFilFRF := xFilial("FRF")
						 	/*
						 	apaga os registros do historico */
							If FRF->(dbSeek(cFilFRF + aChaveCH[nChaveCH,1] + aChaveCH[nChaveCH,2] + aChaveCH[nChaveCH,3] + aChaveCH[nChaveCH,4] + aChaveCH[nChaveCH,5]))
								While !FRF->(Eof()) .And. FRF->FRF_FILIAL == cFilFRF .And. FRF->FRF_BANCO == aChaveCH[nChaveCH,1]  .And. FRF->FRF_AGENCIA == aChaveCH[nChaveCH,2] ;
									.And. FRF->FRF_CONTA == aChaveCH[nChaveCH,3]  .And. FRF->FRF_PREFIX == aChaveCH[nChaveCH,4] .And. FRF->FRF_NUM == aChaveCH[nChaveCH,5]
								 	RecLock("FRF",.F.)
								 	FRF->(DbDelete())
								 	FRF->(MsUnLock())
									FRF->(dbSkip())
								EndDo
							Endif
						EndIf
						
					 	/*
					 	apaga o registro do cheque */
					 	cChaveCH := cFilSEF + aChaveCH[nChaveCH,1] + aChaveCH[nChaveCH,2] + aChaveCH[nChaveCH,3] + aChaveCH[nChaveCH,5]
		      			If SEF->(DbSeek(cChaveCH))
						 	RecLock("SEF",.F.)
						 	SEF->(DbDelete())
						 	SEF->(MsUnLock())
						 Endif
					Next
	      			aChaveCH := {} 
	      		Endif
	      		/**/
	      		If cPaisLoc $ "PER|BOL" 
		      		If !(lLancPad) .OR. nHdlPrv <= 0
						nOrderSE5:=SE5->(IndexOrd())
						SE5->(dBSetOrder(8))
						IF SE5->(DbSeek(xFilial("SE5")+TRB->NUMERO+TRB->SERIE))
							Do While (xFilial("SE5")==SE5->E5_FILIAL .And. TRB->NUMERO==SE5->E5_ORDREC .And. TRB->SERIE == SE5->E5_SERREC)
							   If !(SE5->E5_TIPODOC $ "BA/JR/MT/OG/DC") .And. SE5->E5_TIPO!="CH"  
								  nRecOldE5:=SE5->(Recno())
								  nProcITF:=SE5->E5_PROCTRA
								  If !Empty(nProcITF)
							  	 	 nOrdSE5 := SE5ProcInd()						  		
							  	  	SE5->(DbSetOrder(nOrdSE5))
								  	IF SE5->(DBSeek(xFilial("SE5")+nProcITF))
							     		While !SE5->(Eof()) .and. SE5->E5_PROCTRA == nProcITF
									     	If cPaisloc=="PER" .And. FinProcITF( SE5->( Recno() ),2 )
							                	FinProcITF( SE5->( Recno() ),5,, .F.)
						                 	EndIf	  
						                   	If cPaisloc=="BOL" .And. FinProcITF( SE5->( Recno() ),1 )
							                	FinProcITF( SE5->( Recno() ),5,, .F.)
						                 	EndIf								
					              			 SE5->(DBSkip())
					           		 	Enddo					           		 
					        	  	Endif      						   
					        	  	SE5->(dBSetOrder(8))
					        	  	SE5->(DbGoTo(nRecOldE5))
					        	  EndIf
					           EndIf	  
					           SE5->(DBSkip())
							ENDDO
						ENDIF
						SE5->(DbSetOrder(nOrderSE5))
						ENDIF
					EndIf
				EndIf

			If cPaisLoc == "MEX" .And. lCfdi33 .And. !lBorrar .And. lRet .And. !lBInteg .And. !lBDGA
				// Cancelación de CFDI con complemento de pago
				If !(cMtCanR == "01") .Or. (cMotSF3 == "01" .And. lCRPTimb)
					If FA088CFDIAnu(cMtCanR,cUUIDCanR,aResponse,jData)
						Aadd(aAnulados, TRB->SERIE+TRB->NUMERO)
						F088ActTRB(TRB->SERIE,TRB->NUMERO)
					Else
						// Falló; forzar Rollback
						Aadd(aNoAnulados, TRB->SERIE+TRB->NUMERO)
						DisarmTransaction()

						// Rollback no funciona con tabla temporal ==> quitar marca de recibo cancelado
						DbSelectArea("TRB")
						RecLock("TRB",.F.)
							Replace CANCELADA With " "
							If SEL->(ColumnPos("EL_RETGAN")) > 0 .And. cMtCanR == "01"
								Replace CANCELADA With "P"
							EndIf
						MsUnLock()

						Break
					Endif
				Else
					Aadd(aAnulados, TRB->SERIE+TRB->NUMERO)
				EndIf
			Endif
			If !lBorrar .And. LibMetric()	//Valida que sea anulacion y la fecha de la LIB para utilizacion en Telemetria
				cSubRutina	:= "Recibo_Anulado_" + cPaisLoc + IIf(!Empty(cMtCanR),cMtCanR,"") + IIf(lMetAut, "_auto", "")
				FwCustomMetrics():setSumMetric(cSubRutina, cIdMetrica, 1, /*dDateSend*/, /*nLapTime*/, "FINA088")
			EndIf
			EndIf
		Endif
	Endif

END TRANSACTION

DbSelectArea("TRB")
DbSkip()

EndDo

//DisarmTransaction()
MsUnlockAll()

DbSelectArea("SEL")
DbSetOrder(1)

If cPaisLoc == "MEX" .And. lCfdi33 .And. !lBorrar
	If Len(aAnulados) > 0
		If jData['origin'] ==  "FINA998" 
			cMsg := STR0110
		Else
			cMsg := STR0110 + CRLF		// #Recibos anulados correctamente:#
			aEval( aAnulados , {|x| cMsg += x + CRLF})
		EndIf
	Endif

	If Len(aNoAnulados) > 0
		If jData['origin'] ==  "FINA998" 
			cMsg += STR0111
		Else
			cMsg += STR0111 + CRLF		// #Recibos no anulados (verifique la causa y reintente):#
			aEval( aNoAnulados , {|x| cMsg += x + CRLF})
		EndIf
	Endif

	If !Empty(cMsg)
		If Len(aAnulados) > 0
			If jData['origin'] ==  "FINA998" 
				AADD(aResponse,{.T.,200,STR0091+" "+cMsg,""})
			Else
				MsgInfo( cMsg , STR0091 )	// #Complemento de Recepción de Pagos#
			EndIf
		elseif Len(aNoAnulados) > 0
			If jData['origin'] ==  "FINA998" 
				AADD(aResponse,{.F.,200,STR0091+" "+cMsg,""})
			Else
				MsgInfo( cMsg , STR0091 )	// #Complemento de Recepción de Pagos#
			EndIf
		EndIf
	Endif
Endif

//Mensaje que retornara para los anulados para paises diferentes de mexico
If cPaisLoc <> "MEX"
	If Len(aAnulados) > 0
		If jData['origin'] ==  "FINA998" 
			cMsg := STR0166 //Recibo anulado correctamente
			AADD(aResponse,{.T.,200,cMsg+"",""})
		EndIf
	EndIf
EndIf

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xAtuaSE1 ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Actualizar los titulos del cuentas a Recibir.              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦Uso       ¦ RCBO019                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function f088AtuaSE1(cSerie,cRecibo,lUpdtDados,cParamParcela,cChaveSE1)
Local cAliasAnt		:= ALIAS()
Local nOrderAnt		:=IndexOrd()
Local nRecno		:=	Recno()
Local nRecAnt		:= 0   
Local cRecTmp		:= ""
Local cNumero		:= ""
Local cSerTmp		:= ""
Local cTitAnt		:= ""
Local cCliente		:= ""
Local aAreaSE1		:={}
Local nVlrSld		:= 0
Local nVlrBaiP		:= 0
Local nVlrDac		:= 0
Local lAtuSld		:= .F.
Local nRecSE5  		:=	0
Local nValorBaix	:=	0
Local aAreaAnt		:={}
Local cLstDesc		:= FN022LSTCB(2)	//Lista das situacoes de cobranca (Descontada)
Local oModelBxR		:= Nil
Local oFKA			:= Nil
Local lRet			:= .T.
Local cLog			:= ''
Local nSaldoAnt  	:= 0
Local nSaldo		:= 0
Local cChaveTit 	:= ""
Local cChaveFK7 	:= ""
Local lExistFJU 	:= FJU->(ColumnPos("FJU_RECPAI")) >0 .and. FindFunction("FinGrvEx")
Local cFilOrig		:= ""
Local nVA			:= 0

Default lUpdtDados		:= .T.
Default cParamParcela	:= ""
Default cChaveSE1		:= "" 

SE5->(dBSetOrder(7))
IF SE5->(DbSeek(xFilial("SE5")+SEL->EL_PREFIXO + SEL->EL_NUMERO + SEL->EL_PARCELA + SEL->EL_TIPO + SEL->EL_CLIORIG + SEL->EL_LOJORIG ))
	cFilOrig:= xFilial("SE1",SE5->E5_FILORIG)	
Else        
	cFilOrig:= xFilial("SE1")
Endif 

cChaveSE1 := cFilOrig+ SEL->EL_PREFIXO + PadR(SEL->EL_NUMERO,TamSX3("E1_NUM")[1]) + SEL->EL_PARCELA 

If Subs(SEL->EL_TIPODOC,1,2) == "TB"
	cChaveSE1 += SEL->EL_TIPO
Else
	cChaveSE1 += PadR(SEL->EL_TIPODOC,TamSX3("E1_TIPO")[1])
Endif

DbSelectArea("SE1")
DbSetOrder(1)
If SE1->(DbSeek(cChaveSE1))
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA))
	
	RecLock("SE1",.F.)
	If Subs(SEL->EL_TIPODOC,1,2)=="TB"
		cRecTmp	:=	SEL->EL_RECIBO
		cSerTmp :=  SEL->EL_SERIE
		cNumero := Padr(SE1->E1_NUM,TamSX3("EL_NUMERO")[1])
		SE5->(DbSetOrder(2))
		//Nos casos de baixas parciais pelo recibo gera registros com a mesma chave.
		//A diferenca estah no campo E5_ORDREC(numero do recibo)		
		If SE5->(DbSeek(xFilial("SE5")+IIF(SE1->E1_SITUACA $ cLstDesc,"V2","BA")+;        
							 SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))
			While xFilial("SE5") == SE5->E5_FILIAL .And. SEL->EL_PREFIXO == SE5->E5_PREFIXO .And.;
				SEL->EL_NUMERO == SE5->E5_NUMERO .And. SEL->EL_PARCELA == SE5->E5_PARCELA .And.;  
				SEL->EL_TIPO == SE5->E5_TIPO .And. IIF(SE1->E1_SITUACA $ cLstDesc,SE5->E5_TIPODOC=="V2",SE5->E5_TIPODOC=="BA") .And.!SE5->(Eof())  
				If SE5->E5_SITUACA == "C" .Or. (cPaisLoc $ "MEX" .And. (RTrim(SE5->E5_ORIGEM) <> "FINA087A" .and. RTrim(SE5->E5_ORIGEM) <> "FINA887"))

					SE5->(dbSkip())
					Loop
				EndIf 
				If SE5->E5_ORDREC == cRecTmp .And. SE5->E5_SERREC== cSerTmp .And. nVlrBaiP == 0
					nVlrBaiP := Iif(cPaisLoc<>"BRA",IIf(Val(SE5->E5_MOEDA)<>1,SE5->E5_VALOR,SE5->E5_VLMOED2),SE5->E5_VALOR)
					nRecSE5	 :=	SE5->(Recno())   
				ElseIf SE5->E5_ORDREC == cRecTmp .And. SE5->E5_SERREC== cSerTmp .And. nVlrBaiP <> 0 .And. cPaisLoc=="MEX" .And. SE5->E5_MOTBX <> "DAC"
					nVlrBaiP := SE5->E5_VLMOED2
					nRecSE5	 :=	SE5->(Recno()) 
				ElseIf SE5->E5_MOTBX == "DAC" .And. Empty(SE5->E5_SITUACA) .And.;
					SEL->EL_CLIENTE+SEL->EL_LOJA == SE5->E5_CLIFOR+SE5->E5_LOJA
					nVlrDac	:= Iif(cPaisLoc<>"BRA",SE5->E5_VLMOED2,SE5->E5_VALOR)
        			aAreaSE1:=GetArea() 
        			Reclock("SE5")
					SE5->E5_SITUACA := "C"
					MsUnlock()
        			If AllTrim( SE5->E5_TABORI ) == "FK1"
						aAreaAnt	:= GetArea()
						oModelBxR	:= FWLoadModel("FINM010") //Recarrega o Model de movimentos para pegar o campo do relacionamento (SE5->E5_IDORIG)
						oModelBxR:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
						oModelBxR:Activate()
						oModelBxR:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
						//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK1
						oModelBxR:SetValue( "MASTER", "E5_OPERACAO", 1 )
						
						//Posiciona a FKA com base no IDORIG da SE5 posicionada
             			oFKA := oModelBxR:GetModel( "FKADETAIL" )
						oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
						
						If oModelBxR:VldData()
					       oModelBxR:CommitData()
					       oModelBxR:DeActivate()
						Else
							lRet := .F.
							cLog := cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
							cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
							cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_MESSAGE]) 
				    		
				    		Help( ,,"MF088ATUSE1",,cLog, 1, 0 )
						Endif
					EndIf
					RestArea(aAreaSE1)
				EndIf			
				SE5->(DbSkip())
		   EndDo
        EndIf

       SE5->(MsGoTo(nRecSE5))

		If lUpdtDados
			nSaldoAnt := E1_SALDO
			
			If lExistVa
				nVA	:= (FxLoadFK6("FK1",SE5->E5_IDORIG,"VA")[1,2])
			EndIf

			DbSelectArea("SE1")    

			nSaldo	:=  E1_SALDO + If(nVlrDac=E1_SALDO,0,nVlrDac) + If(nVlrBaiP=E1_SALDO .And. E1_STATUS == "B",0,xMoeda((nVlrBaiP), 1,SE1->E1_MOEDA,E1_BAIXA,4,1,SE5->E5_VALOR/SE5->E5_VLMOED2)) + xMoeda((SE5->E5_VLDESCO - SE5->E5_VLJUROS - SE5->E5_VLMULTA), 1,SE1->E1_MOEDA,E1_BAIXA,4,1,SE5->E5_VALOR/SE5->E5_VLMOED2)
			Replace E1_DESCONT	    With (E1_DESCONT - xMoeda(SE5->E5_VLDESCO,1,E1_MOEDA,E1_BAIXA,4,1,SE5->E5_VALOR/SE5->E5_VLMOED2))
			Replace E1_VALLIQ		With 0
			Replace E1_JUROS		With (E1_JUROS   - xMoeda(SE5->E5_VLJUROS,1,E1_MOEDA,E1_BAIXA,4,1,SE5->E5_VALOR/SE5->E5_VLMOED2))
			Replace E1_MULTA		With (E1_MULTA   - xMoeda(SE5->E5_VLMULTA,1,E1_MOEDA,E1_BAIXA,4,1,SE5->E5_VALOR/SE5->E5_VLMOED2))
			Replace E1_SALDO		With (nSaldo - nVA)
			
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³A consistência acima sobre o saldo deixa de atualizá-lo quando³
			*³existem dois ou mais recebimentos no mesmo valor , pois o     ³
			*³saldo e o valor de recebimento podem acabar com o mesmo valor ³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÄÄÄÄ*/
			If E1_SALDO == nSaldoAnt .And. cPaisLoc $ "COS"
				Replace E1_SALDO With E1_SALDO + nVlrDac + nVlrBaiP + xMoeda((SE5->E5_VLDESCO - SE5->E5_VLJUROS - SE5->E5_VLMULTA - nVA),1,SE1->E1_MOEDA,E1_BAIXA,4,1,SE5->E5_VALOR/SE5->E5_VLMOED2)
			EndIf

			//Apenas para evitar saldos negativos
			If E1_SALDO < 0
				Replace E1_SALDO With 0
			EndIf

			Replace E1_STATUS	With If(SE1->E1_SALDO<=0,"B","A")
		EndIf

		nValorBaix	:=	nVlrDac + nVlrBaiP + xMoeda((SE5->E5_VLDESCO - SE5->E5_VLJUROS - SE5->E5_VLMULTA - nVA),1,SE1->E1_MOEDA,E1_BAIXA,4,1,SE5->E5_VALOR/SE5->E5_VLMOED2)	    
	    
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		*³Verifica se h  abatimentos para voltar a carteira			    	³
		*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		aAreaSE1:=GetArea()
		//Atualiza o status de viagem
		If (ALLTRIM(SE1->E1_ORIGEM) == "FINA677")
			FINATURES(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),.F.,SE1->E1_ORIGEM,"R")
		Endif

		dbSetOrder(1)

		If lUpdtDados
			cTitAnt := SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
		Else
			cTitAnt := SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+cParamParcela
		EndIf

		cCliente:= SE1->E1_CLIENTE+SE1->E1_LOJA
		nVlrSld := E1_VALOR - E1_SALDO

		If dbSeek(cTitAnt)
			While !SE1->(Eof()) .and. cTitAnt == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
 				If !SE1->E1_TIPO $ MVABATIM .Or. (SE1->E1_CLIENTE+SE1->E1_LOJA != cCliente)
					SE1->(dbSkip())
					Loop
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retornar o valor do abatimento           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF SE1->E1_VALOR == nVlrSld
					RecLock("SE1",.F.)
					Replace SE1->E1_SALDO With nVlrSld
					Replace SE1->E1_BAIXA With cTOd(Spac(08))
					MsUnLock()
					lAtuSld := .T.
				EndIf
				SE1->(dbSkip())
			Enddo
		Endif
		RestArea(aAreaSE1)
        If lAtuSld
			E1_SALDO += nVlrSld
        EndIf

		If lUpdtDados
			AtuSalDup(IIF(SE1->E1_TIPO$MVRECANT+"/"+MV_CRNEG,"-","+"),nValorBaix,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
		EndIf

  		DbSelectArea("SE1")
		SEL->(DbSetOrder(2))
		SEL->(DbSeek(xFilial("SEL")+SE1->E1_PREFIXO+cNumero+SE1->E1_PARCELA+SE1->E1_TIPO+;
				SE1->E1_CLIENTE+SE1->E1_LOJA))
		While SEL->(!EOF()) .AND. SEL->EL_PREFIXO==SE1->E1_PREFIXO .AND. SEL->EL_NUMERO==cNumero;
				.AND. SEL->EL_PARCELA==SE1->E1_PARCELA .AND. SEL->EL_TIPO==SE1->E1_TIPO .AND.;
				SEL->EL_CLIENTE==SE1->E1_CLIENTE .AND. SEL->EL_LOJA==SE1->E1_LOJA
				If !SEL->EL_CANCEL .And. (SEL->EL_RECIBO <> cRecTmp .Or. SEL->EL_SERIE <> cSerTmp)
					nRecAnt := SEL->(recno())
				EndIf
				SEL->(DbSkip())
		Enddo
		If	nRecAnt > 0 // Existe outra baixa
			SEL->(DbGoTo(nRecAnt))
			Replace E1_BAIXA  With SEL->EL_DTDIGIT
			Replace E1_RECIBO WITH SEL->EL_RECIBO 
			Replace E1_SERREC WITH SEL->EL_SERIE
		Else // Unica Baixa
			Replace E1_BAIXA  With CTOD("  /  /  ")
			Replace E1_RECIBO WITH space(LEN(SEL->EL_RECIBO))
			Replace E1_SERREC WITH space(LEN(SEL->EL_SERIE))
		EndIf
					
			
		//Atualiza saldo dos valores acessórios (FKD)
		If lExistFKD
			FAtuFKDBx(.T.)
		EndIf
		
	ElseIf lUpdtDados
      AtuSalDup(IIF(SE1->E1_TIPO$MVRECANT+"/"+MV_CRNEG,"+","-"),SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,(SE1->E1_VLCRUZ/SE1->E1_VALOR),SE1->E1_EMISSAO)
		SEA->(DbSetOrder(1))
		If SEA->(DbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
			aAreaAnt:=GetArea()
			DbSelectarea("SEA")
			RecLock("SEA",.F.)
			SEA->(DbDelete())
			MsUnLock()		
			RestArea(aAreaAnt)
		EndIf	
		If lExistFJU 
			FinGrvEx("R")
		Endif		
		SE1->(DbDelete())
		
	Endif
	SE1->(MsUnLock())
	/*
	Atualiza o status do titulo no SERASA */
	If cPaisLoc == "BRA"
		cChaveTit := xFilial("SE1") + "|" +;
					SE1->E1_PREFIXO + "|" +;
					SE1->E1_NUM		+ "|" +;
					SE1->E1_PARCELA + "|" +;
					SE1->E1_TIPO	+ "|" +;
					SE1->E1_CLIENTE + "|" +;
					SE1->E1_LOJA
		cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
		F770BxRen("3","",cChaveFK7)
	Endif	
Endif

DbSelectArea(cAliasAnt)
DbSetOrder(nOrderant)
DbGoTo(nRecno)
Return


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xDelSE5  ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 20.01.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Borrar los movimientos en SE5.                             ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
Uso       ¦ RCBO019                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function xDelSE5
Function F088DelSE5(cSerie,cNumero)
Local aBaixaSE3	:= {}
Local cAliasAnt	:= ALIAS()
Local nOrderAnt	:= IndexOrd()
Local oModelBxR	:= Nil
Local oFKA		:= Nil
Local lRet		:= .T.
Local cLog		:= ''
Local cProc		:= ""
Local cProcAux	:= ""
Local cSeq		:= ""
Local lFina088	:= FunName() $ "FINA088|FINA846|FINA887"
Local cCondic	:= IIf(lFina088, "", " (SE5->E5_SEQ == cSeq) ")

DbSelectArea("SE5")
SE5->(dBSetOrder(8)) //E5_FILIAL+E5_ORDREC+E5_SERREC
If SE5->(DbSeek(xFilial("SE5") + cNumero + cSerie))
	If !lFina088
		cSeq := SE5->E5_SEQ
	End If
EndIf


Do While !SE5->(EOF()) .And. (xFilial("SE5")==SE5->E5_FILIAL.And.cNumero==SE5->E5_ORDREC .And. cSerie == SE5->E5_SERREC) .And. IIf(!Empty(cCondic),&cCondic,.T.)
	If !Empty(SE5->E5_RECONC) .and. cPaisLoc = "CHI"
			MsgAlert(STR0135 + SE5->E5_NUMERO + STR0136)
		Return	
	Else
		If SE5->E5_RECPAG <> 'R' .Or. (cPaisLoc $ "MEX" .And. (RTrim(SE5->E5_ORIGEM) <> "FINA087A" .And. RTrim(SE5->E5_ORIGEM) <> "FINA887"))

			SE5->(DbSkip())
			loop
		EndIf
		If !(SE5->E5_TIPODOC $ "BA/JR/MT/OG/DC") .And. SE5->E5_TIPO!="CH"
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")
		Endif
		If (SE5->E5_RECPAG=="R" .And. SE5->E5_TIPODOC!="ES") .Or. (SE5->E5_RECPAG=="P" .And. SE5->E5_TIPODOC=="ES")
			aadd(aBaixaSE3,{ SE5->E5_MOTBX , SE5->E5_SEQ , SE5->(Recno()) })
		
			cProcAux := FINProcFKs( SE5->E5_IDORIG, "FK1" )
			If AllTrim( SE5->E5_TABORI ) == "FK1" .AND. SE5->E5_TIPODOC $ "BA|VL" .AND. cProc <> cProcAux
				cProc := cProcAux
			
				oModelBxR	:= FWLoadModel("FINM010") //Recarrega o Model de movimentos para pegar o campo do relacionamento (SE5->E5_IDORIG)
				oModelBxR:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
				oModelBxR:Activate()
				oModelBxR:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
				//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK1
				oModelBxR:SetValue( "MASTER", "E5_OPERACAO", 1 )
				oModelBxR:SetValue( "MASTER", "HISTMOV", OemToAnsi( STR0082 ) + cNumero )
			
				//Posiciona a FKA com base no IDORIG da SE5 posicionada
				oFKA := oModelBxR:GetModel( "FKADETAIL" )
				oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
			
				If oModelBxR:VldData()
		       		oModelBxR:CommitData()
		       		oModelBxR:DeActivate()
				Else
					lRet := .F.
					cLog := cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
					cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
					cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_MESSAGE]) 
	    		
	    			Help( ,,"MF088DELSE5",,cLog, 1, 0 )
				Endif
			Else
				RecLock( "SE5", .F. )
				Replace E5_SITUACA WITH "C"
				SE5->( MsUnLock() )
			EndIf
		Endif
	Endif
	
	SE5->(DbSkip())

	If !lFina088
		cSeq := SE5->E5_SEQ
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estorna Comissao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Fa440DeleB(aBaixaSE3,.F.,.F.,"FINA087")
//

DbSelectArea(cAliasAnt)
DbSetOrder(nOrderant)

Return


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ xDelNCC  ¦ Autor ¦ Guilherme/Leonardo    ¦ Data ¦ 27.07.01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Borrar los movimientos en SE1 referente aos NCC gerados aut¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦+Uso       ¦ FINA088                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function F088DelNCC(cSerie,cNumero,cVersao,cParcela)
Local aArea := GetArea()
Local lExistFJU := FJU->(ColumnPos("FJU_RECPAI")) >0 .and. FindFunction("FinGrvEx")
//
Default cParcela := Space(TamSx3("E1_PARCELA")[1])

DbSelectArea("SEL")
DbSetOrder(8)
DbSeek(xFilial("SEL")+cSerie+cNumero)

//
While !EOF() .AND. xFilial('SEL') + cSerie + cNumero == EL_FILIAL + EL_SERIE + EL_RECIBO
	If (cVersao == Nil .Or. cVersao == EL_VERSAO) .AND. SEL->EL_TIPO $ MV_CRNEG+","+MVRECANT
		DbSelectArea("SE1")
		DbSetOrder(2)
		IF(SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIENTE+SEL->EL_LOJA+"REC"+SEL->EL_RECIBO + SEL->EL_PARCELA)))
		Do While !SE1->(Eof()) .and. ;
				SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+"REC"+SE1->E1_NUM + SE1->E1_PARCELA = xFilial("SE1")+SEL->EL_CLIENTE+;
				SEL->EL_LOJA+"REC"+SEL->EL_RECIBO + SEL->EL_PARCELA
			If (SE1->E1_TIPO $ MV_CRNEG+","+MVRECANT) .And. (Upper(AllTrim(SE1->E1_ORIGEM)) = "FINA087A" .Or. Upper(AllTrim(SE1->E1_ORIGEM)) = 'FINA840' .Or. Upper(AllTrim(SE1->E1_ORIGEM)) = 'FINA887')
				If lExistFJU
					FingrvEx("R")
				EndIf
				SE1->(RecLock("SE1",.F.))
				SE1->(DbDelete())
				SE1->(MsUnLock())
			EndIf   
			SE1->(DbSkip())
		EndDo
		EndIf
	Endif
	DbSelectArea('SEL')
	dBsKIP()
EnddO
RestArea(aArea)

Return            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA088DelRAºAutor  ³Microsiga           º Data ³  26/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se os titulos do tipo RA (processo de adiantamento) º±±
±±º          ³ foram compensados e caso não os exclui.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN - Mexico                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA088DelRA(lBjDGA)
Local aArea		:= GetArea()
Local aAreaSE1	:= SE1->(GetArea())
Local aAreaSEL	:= SEL->(GetArea())
Local cAliasQry := GetNextAlias()
Local cQuery	:= ""
Default lBjDGA := .F.

DbSelectArea("SEL")
DbSetOrder(8) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
If DbSeek(xFilial("SEL")+TRB->SERIE+TRB->NUMERO)

	cQuery := "	SELECT SE1.R_E_C_N_O_ SE1_RECNO							   	"+CRLF
	cQuery += "		FROM " + RetSQLName("SE1") + " SE1					   	"+CRLF
	cQuery += "			INNER JOIN "+ RetSQLName("SED")+" SED ON		   	"+CRLF
	cQuery += "				SE1.E1_NATUREZ = SED.ED_CODIGO				   	"+CRLF
	cQuery += "		WHERE SE1.E1_FILIAL		= '" + XFilial("SE1") + "'	   	"+CRLF
	cQuery += "			AND SED.ED_FILIAL	= '" + XFilial("SED") + "'	   	"+CRLF
	cQuery += "			AND SE1.D_E_L_E_T_	= ''						   	"+CRLF
	cQuery += "			AND SED.D_E_L_E_T_	= ''						  	"+CRLF
	cQuery += "			AND SE1.E1_CLIENTE	= '" + SEL->EL_CLIENTE + "'	   	"+CRLF
	cQuery += "			AND SE1.E1_LOJA		= '" + SEL->EL_LOJA + "'		"+CRLF
	cQuery += "			AND SE1.E1_TIPO		= '" + Substr(MVRECANT,1,3) + "'"+CRLF //"RA" no Mexico
	cQuery += "			AND SE1.E1_RECIBO	= '" + SEL->EL_RECIBO + "'		"+CRLF
	cQuery += "			AND SE1.E1_ORIGEM	= 'FINA087A'					"+CRLF
	If !lBjDGA
		cQuery += "			AND SED.ED_OPERADT	= '1'							"+CRLF //Operacao de adiantamento igual a SIM
	EndIf
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	While (cAliasQry)->(!Eof())

		SE1->(DbGoTo((cAliasQry)->SE1_RECNO))
		RecLock("SE1",.F.)
		SE1->(DbDelete())
		SE1->(MsUnLock())

	(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

EndIf

RestArea(aAreaSEL)
RestArea(aAreaSE1)
RestArea(aArea)

Return Nil

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ RCBO020  ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 12.05.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ CANCELACION DEL Recibo (Visualizacao)                      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ FINA088                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function fa088Visual(cAlias)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

Local cRecibo   
Local cSerie 
Local cCliOrig
Local cLojOrig
Local nZ := 0
Local aAux := {}
Local nA := 0

Private aHeader :={}
Private aCols :={}

If Empty(cAlias)
	nDecs    := MsDecimais(Val(SEL->EL_MOEDA))
	mv_par06 := Val(SEL->EL_MOEDA)
EndIf

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("EK_VALOR")
Aadd(aHeader,{OemToAnsi(STR0022) ,"DETALLE"    ,"@!",15,0,".T.",X3_usado,"C","SEL"}) //"Tipo de Valor"
Aadd(aHeader,{OemToAnsi(STR0058) ,"EL_PREFIXO" ,"@!",3 ,0,".T.",X3_usado,"C","SEL"}) //"Prefixo"
Aadd(aHeader,{OemToAnsi(STR0023) ,"EL_SERIE"   ,"@!",3 ,0,".T.",X3_usado,"C","SEL"}) //"Serie"
Aadd(aHeader,{OemToAnsi(STR0024) ,"EL_NUMERO"  ,"@!",12,0,".T.",X3_usado,"C","SEL"}) //"Numero"
Aadd(aHeader,{OemToAnsi(STR0025) ,"EL_PARCELA" ,"@!",1 ,0,".T.",X3_usado,"C","SEL"}) //"Cuota"
Aadd(aHeader,{OemToAnsi(STR0026) ,"EL_TIPO"    ,"@!",3 ,0,".T.",X3_usado,"C","SEL"}) //"Tipo"
Aadd(aHeader,{OemToAnsi(STR0027+GetMv("MV_MOEDA"+Str(mv_par06,1))) ,"EL_VLMOED1" ,PesqPict("SEL","EL_VALOR",17,mv_par06),17 ,nDecs,".t.",X3_usado,"N","SEL"}) //"Valor "
Aadd(aHeader,{OemToAnsi(STR0028) ,"EL_DTDIGIT" ,""  , 8,0,".T.",X3_usado,"D","SEL"}) //"Emision"

aCols:={}
DbSelectArea("SEL")
DbSetOrder(8)
If ! Empty(cAlias)
	cCliente	:= TRB->CLIENTE
	cLoja		:= TRB->SUCURSAL   
	cSerie      := TRB->SERIE
	cRecibo		:= TRB->NUMERO 
	cCliOrig	:= TRB->CLIORIG
	cLojOrig	:= TRB->SUCORIG
	DbSeek(xFilial("SEL")+TRB->SERIE+TRB->NUMERO)
Else      
	cSerie      := SEL->EL_SERIE
	cRecibo		:= SEL->EL_RECIBO 
	cCliOrig	:= SEL->EL_CLIORIG
	cLojOrig	:= SEL->EL_LOJORIG
	DbSeek(xFilial("SEL")+SEL->EL_SERIE+SEL->EL_RECIBO )
Endif

cRecibo := SEL->EL_RECIBO  
cSerie  := SEL->EL_SERIE

nZ:=0
While xFilial("SEL")==EL_FILIAL .And. cRecibo==EL_RECIBO .And. cSerie == EL_SERIE
	nZ		:=nZ+1
	aAux	:={}
	Aadd(aAux,Space(20))
	For nA:=2  to Len(aHeader)
		Aadd(aAux,Criavar(aHeader[nA,2]))
	Next

	Aadd(aAux,.F.)
	Aadd(aCols,aAux)

	Do Case
		Case Subs(SEL->EL_TIPODOC,1,2)=="TB"
			aCols[nZ][1]:= OemToAnsi(STR0029)  // "Titulo Cobrado"
		Case Subs(SEL->EL_TIPODOC,1,2)=="RA"
			aCols[nZ][1]:= OemToAnsi(STR0030)	// "Rec.Anticipado"
		Case Subs(SEL->EL_TIPODOC,1,2)=="RG"
			aCols[nZ][1]:= OemToAnsi(STR0031)	// "Ret. Ganancias"
		CASE Subs(SEL->EL_TIPODOC,1,2) =="RV"
			aCols[nZ][1]:= OemToAnsi(STR0032)	// "Ret. I.V.A."
		Case Subs(SEL->EL_TIPODOC,1,2)=="RI"
			aCols[nZ][1]:= OemToAnsi(STR0033)	// "Ret.Ing.Brut."
		Case Subs(SEL->EL_TIPODOC,1,2)=="RR"
			aCols[nZ][1]:= OemToAnsi(STR0134)	// "Ret.Ing.Brut."	
		OtherWise
			aCols[nZ][1]:= OemToAnsi(STR0034)	// "Valor Recib."
	EndCase

	aCols[nZ][2]:=SEL->EL_PREFIXO  
	aCols[nZ][3]:=SEL->EL_SERIE
	aCols[nZ][4]:=SEL->EL_NUMERO
	aCols[nZ][5]:=SEL->EL_PARCELA
	aCols[nZ][6]:=SEL->EL_TIPO
	aCols[nZ][7]:=Round(If( mv_par06==1,EL_VLMOED1,xMoeda(EL_VALOR,Max(Val(EL_MOEDA),1),mv_par06,EL_DTDIGIT,nDecs+1)),nDecs)
	aCols[nZ][8]:=SEL->EL_DTDIGIT

	SEL->(DbSkip()	)
EndDo

oDialog := MSDialog():New(65, 0, 280, 600, OemToAnsi(STR0011),,,,,,,,,.t.,,,)
@  1,4  To 30,297
IW_MultiLine(33,4,105,297,.F.,.F.,,500)
@  7,6  Say OemToAnsi(STR0035) + cSerie + Iif(Empty(cSerie),' ',"-")+ cRecibo  SIZE 200,10  //"Detalles del Recibo Nro  "
@ 19,6  Say OemToAnsi(STR0036) + cCliOrig SIZE 80,10   //"Cliente : "
@ 19,64 Say OemToAnsi(STR0037) + cLojOrig SIZE 60,10   //"Sucursal :"
Activate Dialog oDialog CENTERED

If !Empty(cAlias)
	DbSelectArea("TRB")
EndIf	

Return


/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ RCBO021  ¦ Autor ¦ BRUNO SOBIESKI        ¦ Data ¦ 12.05.99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ AxPesqui para cancelacion de Recibo.                       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ FINA088                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function fa088Buscar()        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CCAMPO,CORD,AORD,NOPT1,")

cCampo := Space(TamSx3("EL_SERIE")[1]) + Space(TamSx3("EL_RECIBO")[1])
cOrd   := OemToAnsi(STR0002) // "Recibo"
aOrd   := {}
Aadd(aOrd,OemToAnsi(STR0002)) // "Recibo"
@ 5,5 TO 68,400 DIALOG oDlg TITLE OemToAnsi(STR0038) //"Buscar"

@ 1.6 ,002 COMBOBOX cOrd ITEMS aOrd SIZE 165,44 // ON CHANGE (nOpt1:=oCbx:nAt)  OF oDlg
@ 15  ,002 GET cCampo SIZE 165,10
@ 1.6 ,170 BMPBUTTON TYPE 1 ACTION Buscar(cCampo)
@ 14.6,170 BMPBUTTON TYPE 2 ACTION Salir()
ACTIVATE DIALOG oDlg CENTERED
RETURN

Static Function Buscar(cCampo)
DbSelectArea("TRB")
TRB->(DbSeek(cCampo,.T.))
Close(oDlg)
Return


Static Function Salir()
Close(oDlg)
Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦FA088COMIS¦ Autor ¦ Paulo Augusto         ¦ Data ¦ 15.08.02 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Monta array para calcular a comissao do cobrador           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ FINA088                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Function fa088Comis()
Local nPerc:=0         
Local aCpoSEX:={} 
Local aArea:=GetArea()
// Verifica comissao de cobrador
SEX->(DbSetorder(2))
If SEX->(DbSeek(xFilial("SEX")+SEL->EL_COBRAD+SEL->EL_RECIBO+SEL->EL_TIPODOC+SEL->EL_NUMERO+SEL->EL_SERIE))
	If SEX->EX_DATA <> cToD("  /  /  ")
		SAQ->(DbSetOrder(1))
		SAQ->(Dbseek(xFilial("SAQ")+SEL->EL_COBRAD))
		nPerc:=SAQ->AQ_COMIS
	 	//SE MUDAR ALGUMA POSICAO DO ARRAY ABAIXO, PRECISA CORRIGIR TB NOS FONTES FINA016/FINA87A/FINA088.	
	 	AADD(aCpoSEX,SEL->EL_COBRAD )  
		AADD(aCpoSEX,SEL->EL_SERIE )	 	
		AADD(aCpoSEX,SEL->EL_RECIBO )
		AADD(aCpoSEX,SEL->EL_DTDIGIT )
		AADD(aCpoSEX,SEL->EL_CLIORIG)
		AADD(aCpoSEX,SEL->EL_LOJORIG)
		AADD(aCpoSEX,SEL->EL_VALOR * (-1))
		AADD(aCpoSEX, nPerc)
		AADD(aCpoSEX,Val(SEL->EL_MOEDA))
		AADD(aCpoSEX,(SEL->EL_VALOR * (-1)) *(nPerc/100) )
		AADD(aCpoSEX,SEL->EL_TIPODOC )	
		AADD(aCpoSEX,SEL->EL_NUMERO)
		Fa016Calc(aCpoSEX)
	Else
		RecLock("SEX",.F.)
		SEX->(dbDelete())
		MsUnLock("SEX")
	EndIf
EndIf	
RestArea(aArea)
Return()		

Function F088NumPend(cSerie,cRecibo)
Local aArea:=GetArea() 
Local cRecComp, cSerComp

dbSelectArea("SEL")   
DbSetOrder(8)
DbSeek(xFilial("SEL")+cSerie+cRecibo)
If !Empty(SEL->EL_COBRAD)
	DbSelectArea("SAQ")
	DbSetOrder(1)
	If dbSeek(xFilial("SAQ")+SEL->EL_COBRAD) 
		cTipo:=AQ_TIPOREC   
		cSerComp:= cSerie
		cRecComp:= cRecibo
		DbSelectArea("SEY")
		DbSetOrder(1)
		If dbSeek(xFilial("SEY")+SEL->EL_COBRAD)
			While !EOF() .and. SEL->EL_COBRAD == SEY->EY_COBRAD 	
   			If  cTipo == SEY->EY_TIPOREC .and. cRecComp  >= SEY->EY_RECINI .and. cRecComp <= SEY->EY_RECFIN .and. cSerComp == SEY->EY_SERIE  
   		 		RecLock("SEY",.f.)
   		 		SEY->EY_RECPEND 	:=SEY->EY_RECPEND +1
   		 		If SEY->EY_STATUS == "2"
   		        	MsgStop(OemToAnsi(STR0055)+ SEY->EY_TALAO + OemToAnsi(STR0056) + SEY->EY_COBRAD + OemToAnsi(STR0057)) //"O talao numero : "###" do cobrador numero :"###"  estava encerrado e apartir deste momento sera reaberto "
   		        	SEY->EY_STATUS	:= "1" 	
   		 	   	EndIf
   		 	   	
   		 	   	MsUnlock()
   		 		Exit
   		 	EndIf	
     			DbSkip()
			Enddo
		EndIf
	EndIf
EndIf   
RestArea(aArea)
Return()




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA088   ºAutor  ³Sabrina P. Soares   º Data ³  24/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusao das retencoes associadas com o recebimento        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F088DelRet(aTitRec, cSerie, cNumero, cCliente, cFilialCl)
Local lEstorna := (GetNewPar("MV_DELRET","D") == "E" )
Local lCmpEst  := SFE->(ColumnPos("FE_NRETORI")) > 0 .And. SFE->(ColumnPos("FE_DTRETOR")) > 0
Local aAreaAux := {}
Local cRecibo  := ""
Local nI

Default cCliente := ""
Default cFilialCl := ""

Private acerts:= {}
cAliasAnt:=ALIAS()
nOrderAnt:=IndexOrd() 

If FunName() == "FINA846" .And. cPaisLoc == "ARG"
	SEL->(DbSelectArea("SEL"))
	SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	SEL->(DbSeek(FwxFilial("SEL") + cSerie + cNumero))
	Do While FwxFilial("SEL") == SEL->EL_FILIAL .And. FJT->FJT_RECIBO == SEL->EL_RECIBO .And. FJT->FJT_SERIE == SEL->EL_SERIE
		If FJT->FJT_VERSAO == SEL->EL_VERSAO
			If (Subs(SEL->EL_TIPODOC, 1, 2) $ "RG|RI|RB|RS|RM")
				SFE->(DbSelectArea("SFE"))
				SFE->(DbSetOrder(6)) //FE_FILIAL+FE_RECIBO+FE_TIPO
				SFE->(DbSeek(xFilial("SFE")+Alltrim(cNumero)))
				Do While SFE->(!EOF())
					If xFilial("SFE") == SFE->FE_FILIAL .And. Alltrim(cNumero) == Alltrim(SFE->FE_RECIBO) .And. AllTrim(SFE->FE_CLIENTE) == AllTrim(cCliente) .And. AllTrim(SEL->EL_NUMERO) ==  AllTrim(SFE->FE_NROCERT) .And. AllTrim(SFE->FE_LOJCLI) == AllTrim(cFilialCl) .And. Alltrim(SEL->EL_SERIE) == Alltrim(SFE->FE_SERIE)
						// Genera un registro por retención.
						If Empty(SFE->FE_FORNECE) .And. Empty(SFE->FE_DTESTOR) .And. lEstorna .And. lCmpEst
							// Actualiza el registro de retención actual con los datos del entorno.
							SFE->(RecLock("SFE",.F.))
							Replace SFE->FE_DTESTOR With dDatabase
							MsUnLock()
							
							nRecReg :=SFE->(Recno())
							nValImp:= SFE->FE_VALIMP * (-1)
							nValBase:= SFE->FE_VALBASE * (-1)
							nValReten:= SFE->FE_RETENC * (-1)
							nValDeduc:= SFE->FE_DEDUC * (-1)
							nDtRetOrig := SFE->FE_EMISSAO
							nNroOrig := SFE->FE_NROCERT
							dDtEstor := dDatabase
							nRecInc := 0
							
							PmsCopyReg("SFE",nRecReg,{{"FE_EMISSAO",dDtEstor},{"FE_VALIMP",nValImp},{"FE_VALBASE",nValBase},{"FE_RETENC",nValReten},{"FE_DEDUC",nValDeduc},{"FE_DTRETOR",nDtRetOrig},{"FE_NRETORI",nNroOrig}},@nRecInc)
						ElseIf !lEstorna
							SFE->(RecLock("SFE",.F.))
							SFE->(DbDelete())
							SFE->(MsUnLock())
						EndIf
					EndIf
					SFE->(DbSkip())
				EndDo
			Endif
		Endif
		SEL->(DbSkip())
	EndDo
Else
	If SIX->(DbSeek('SFE6'))
	DbSelectArea("SFE")
	dBsetOrder(6)   // ordem por recibo
	DbSeek(xFilial("SFE")+Alltrim(cNumero))
	Do While (xFilial("SFE")==FE_FILIAL .And. Alltrim(cNumero)==Alltrim(FE_RECIBO))
	//-- Apaga títulos de Retenção gerados pelo configurador de impostos.
		If cPaisLoc == "COS"
			aAreaAux := {SE1->(GetArea()),SEL->(GetArea()),SFE->(GetArea()),GetArea()}
			If (nI := aScan(aTitRec,{|x| x == xFilial("SE1")+SFE->(FE_SERIE+FE_NFISCAL+FE_PARCELA+FE_TPTPAI) } )) > 0
				SE1->(DbSetOrder(1)) //--E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

				//-- Se não encontrou o titulo principal em outro recibo, exclui a retenção
				If SE1->(MsSeek(aTitRec[nI])) .And. Empty(cRecibo)
					//-- Busca o título de Retenção e o deleta
					If SE1->(MsSeek(Left(aTitRec[nI],Len(aTitRec[nI])-Len(SEL->EL_TIPO))+SFE->FE_TPTIMP))
						RecLock("SE1" ,.F.,.T.)
						dbDelete()
						MsUnLock()
					EndIf
				EndIf
				aEval( aAreaAux, {|xArea| RestArea(xArea) })
			EndIf
			//Atualiza os documentos de retenção criados proporcionalmente pela baixa parcial-
			F088UpDcRetencao(cNumero,cSerie,SFE->FE_FILIAL,SFE->FE_SERIE,SFE->FE_NFISCAL,SFE->FE_PARCELA,SFE->FE_TPTIMP,FE_CLIENTE,SFE->FE_LOJCLI,SFE->FE_VALIMP,SFE->FE_TPTPAI)
		EndIf


		If (cPaisLoc $ "ARG|COS|PAR") .And. Empty(SFE->FE_FORNECE) .And. Empty(FE_DTESTOR) .And. lEstorna		// Gera um registro de estorno das retenções.
				// Atualiza o registro da retenção atual com a data do estorno		
			RecLock("SFE",.F.)
			Replace FE_DTESTOR With dDatabase
			MsUnLock()
				//If cPaisLoc == "ARG"
			If SFE->FE_TIPO == "G"
				cImp:="GANAN"
			ElseIf SFE->FE_TIPO == "B"
				cImp:="IB "
			ElseIf SFE->FE_TIPO == "I"
				cImp:="IVA"
			ElseIf SFE->FE_TIPO == "S"
				cImp:="SU "
			ElseIf SFE->FE_TIPO == "L"
				cImp:="SI "
			ElseIf SFE->FE_TIPO == "Z"
				cImp:="SIS"
			EndIf
			If cPaisLoc=="PAR"
				If SFE->FE_TIPO == "I"
					cImp:="IVA"
				ElseIf SFE->FE_TIPO == "R"
					cImp:="IR"		
				EndIf                      
			EndIf
			If cPaisLoc == "PER
				If SFE->FE_TIPO == "I"
					cImp:="IGV"	
				EndIf	
			ElseIf cPaisLoc == "COS"
				//cImp := SFE->FE_TPTIMP
			EndIf		
			nRecReg :=SFE->(Recno())
			nValImp:= SFE->FE_VALIMP * (-1)
			nValBase:= SFE->FE_VALBASE * (-1)		                   
			nValReten:= SFE->FE_RETENC * (-1)
			nValDeduc:= SFE->FE_DEDUC * (-1)
			nDtRetOrig := SFE->FE_EMISSAO
			nNroOrig := SFE->FE_NROCERT			
			dDtEstor := dDatabase
			nRecInc := 0               	
			PmsCopyReg("SFE",nRecReg,{{"FE_EMISSAO",dDtEstor},{"FE_VALIMP",nValImp},{"FE_VALBASE",nValBase},{"FE_RETENC",nValReten},{"FE_DEDUC",nValDeduc},{"FE_DTRETOR",nDtRetOrig},{"FE_NRETORI",nNroOrig}},@nRecInc)
		Elseif !lEstorna						  
			RecLock("SFE",.F.)
			DbDelete()
			MsUnLock()
		EndIf
		SFE->(DbSkip())			
	EndDo
EndIf
EndIf

DbSelectArea(cAliasAnt)
DbSetOrder(nOrderant)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³22/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local lFA088BTN := ExistBlock("FA088BTN")
Local aRotina 
aRotina:= {	{ OemToAnsi(STR0010),'fa088Buscar',0 ,1,,.F.},; // "Buscar"
					{ OemToAnsi(STR0011),'fa088Visual',0 ,1},;  // "Visualizar"
					{ OemToAnsi(STR0053),'fa088Cancel',0 ,3},;  // "Anular"
					{ OemToAnsi(STR0012),'fa088Cancel',0 ,4},;  // "Borrar"
					{ OemToAnsi(STR0070),"FA088Leg",0,5,0,.F.}}	//"Legenda"		

If cPaisLoc == "MEX"
	AADD(aRotina, { OemToAnsi(STR0084),'fa088CFDI',0 ,3})	//"Timbrar"
	AADD(aRotina, { OemToAnsi(STR0117),'fa088Imp',0 ,3})	// "Imprimir"
	AADD(aRotina, { OemToAnsi(STR0143),'fa088Env',0 ,3})	// "Envío por email"
EndIf

If lFA088BTN
	aRotina := Execblock("FA088BTN",.F.,.F.,aRotina)
EndIF

						
Return(aRotina)
            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F088TEL   ºAutor  ³Mauricio Pequim Jr  º Data ³  21/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela com a markbrowse para escolha dos recibos a se-  º±±
±±º          ³rem cancelados.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cancelamento de Recibos (Painel Financeiro apenas)         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function F088TEL(cAlias,cCpoMark,cCpo,aCampos,cMarca,nOpcAuto,aCab,lMsg,aResponse,jData)
                         
Local nOpca   := 0
Local aCores  := {}

If(Empty(aCab))

	Aadd(aCores, { 'Empty(CANCELADA) .and. Empty(TRB->PODE)', "BR_VERDE" } )//"Titulo Protestado"
	Aadd(aCores, { '!Empty(CANCELADA) .OR. !Empty(TRB->PODE)', "BR_VERMELHO" } )// "Titulo em Carteira"

	aSize := MSADVSIZE()

	DEFINE MSDIALOG oDlg TITLE STR0009 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL  //"Cancelamento do Recibo"
	oDlg:lMaximized := .T.

	(cAlias)->(Dbgotop())

	oMark:=MsSelect():New(cAlias,cCpoMark,cCpo,aCampos,,cMarca,{02,1,123,316},,,,,aCores)
	oMark:oBrowse:lhasMark := .t.
	oMark:oBrowse:lCanAllmark := .t.
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                                 •
	oMark:oBrowse:REFRESH()

	ACTIVATE MSDIALOG oDlg  ON INIT (FaMyBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()}))

	DbSelectArea("SEL")
	FinVisual("SEL",FinWindow,SE1->(Recno()))

	If nOpca == 1
		Fa088Cancel(cAlias,nOpcAuto)
	Endif
Else
	//Setando a Chave
	SEL->(DbSetOrder(1))
	//Posicionando a Tabela SEL 
	SEL->(DbSeek(xFilial("SEL")+aCab[Ascan(aCab,{|x|x[1]== "EL_RECIBO"})][2]+aCab[Ascan(aCab,{|x|x[1]== "EL_TIPODOC"})][2]+aCab[Ascan(aCab,{|x|x[1]== "EL_PREFIXO"})][2]+aCab[Ascan(aCab,{|x|x[1]== "EL_NUMERO"})][2]))
	
	Fa088Cancel(cAlias,SEL->(Recno()),nOpcAuto,,lMsg,@aResponse,@jData)

EndIf
Return




/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA088T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 27.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA088                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA088T(aParam)

	ReCreateBrow("SEL",FinWindow)      	
	FinA088(aParam[1])
	ReCreateBrow("SEL",FinWindow)      	
	dbSelectArea("SEL")
	
	INCLUI := .F.
	ALTERA := .F.

Return .T.	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa088VldCa  ³ Autor ³ Ana Paula Nasc. Silva³Data ³ 26.11.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ validação do cancelamento para verificar apuração(Peru)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA088                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function Fa088VldCa(cNumero,lHelp,lBorrar,aResponse,jData)
Local aArea		:= GetArea()
Local aAreaSE1	:= SE1->(GetArea())
Local aAreaSEL	:= SEL->(GetArea())
Local cAliasQry := GetNextAlias()
Local aDatas	:= {}
Local aFiles	:= Iif(cPaisLoc=="PER",Array(ADIR("*.IG")),{})
Local cQuery	:= ""
Local lRet		:= .T.
Local nX		:= 0
Local lCfdi33   := SuperGetMv("MV_CFDI33",.F.,.F.)
Local lBajaEAI  := .F.
Local lBajaDGA  := .F.
Default lHelp	:= .T.
Default lBorrar := .F.

If cPaisLoc=="PER"
	DbSelectArea("SFE") 
	DbSetOrder(6)   // / Pesquisa por recibo
	If	SFE->(dbSeek(xFilial("SFE")+ cNumero+ "P"))
		//Exemplo de nome de arquivo de apuração: ADDMMAADDMMAA0101.II, onde:
		//A	Indica que o arquivo em questão é de apuração de impostos.
		//DDMMAA	Data inicial do processamento (dia, com dois caracteres, mês, com dois caracteres e ano, com dois caracteres)
		//DDMMAA	Data final do processamento (dia, com dois caracteres, mês, com dois caracteres e ano, com dois caracteres)
		//01	Código da empresa que está efetuando a apuração.
		//01	Código da filial que está efetuando a apuração.
		//II	Indica o imposto apurado, sendo:
			//IG = IGV;
			//IS = ISC
		ADIR("A????????????"+cEmpAnt+cFilAnt+".IG", aFiles)
		For nX:=1 TO Len(aFiles)
			AAdd(aDatas,{Ctod(Substr(aFiles[nX],2,2)+"/"+Substr(aFiles[nX], 4,2)+"/"+Substr(aFiles[nX],6,2)),;
					Ctod(Substr(aFiles[nX],8,2)+"/"+Substr(aFiles[nX],10,2)+"/"+Substr(aFiles[nX],12,2))})
		Next
		For nX:= 1 To Len(aDatas)
			If SFE->FE_EMISSAO >= aDatas[nX,1] .And. SFE->FE_EMISSAO <= aDatas[nX,2]
				If Aviso(STR0059,STR0060+CHR(13)+CHR(10)+STR0061,{STR0062,STR0063}) == 2
					lRet	:=	.F.	
				Endif			
				Exit
			Endif
		Next	
	Endif

ElseIf cPaisLoc $ "MEX|PER" .And. X3Usado("ED_OPERADT")
	
	DbSelectArea("SEL")
	DbSetOrder(8) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If DbSeek(xFilial("SEL")+FJT->(FJT_SERIE+FJT_RECIBO))
	
		cQuery := "	SELECT SE1.R_E_C_N_O_ SE1_RECNO							   	"+CRLF
		cQuery += "		FROM " + RetSQLName("SE1") + " SE1					   	"+CRLF
		cQuery += "			INNER JOIN "+ RetSQLName("SED")+" SED ON		   	"+CRLF
		cQuery += "				SE1.E1_NATUREZ = SED.ED_CODIGO				   	"+CRLF
		cQuery += "		WHERE SE1.E1_FILIAL		= '" + XFilial("SE1") + "'	   	"+CRLF
		cQuery += "			AND SED.ED_FILIAL	= '" + XFilial("SED") + "'	   	"+CRLF
		cQuery += "			AND SE1.D_E_L_E_T_	= ''						   	"+CRLF
		cQuery += "			AND SED.D_E_L_E_T_	= ''						  	"+CRLF
		cQuery += "			AND SE1.E1_CLIENTE	= '" + SEL->EL_CLIENTE + "'	   	"+CRLF
		cQuery += "			AND SE1.E1_LOJA		= '" + SEL->EL_LOJA + "'		"+CRLF
		cQuery += "			AND SE1.E1_TIPO		= '" + Substr(MVRECANT,1,3) + "'"+CRLF //"RA" no Mexico
		cQuery += "			AND SE1.E1_BAIXA	<> ''                           "+CRLF
		cQuery += "			AND SE1.E1_RECIBO	= '" + SEL->EL_RECIBO + "'		"+CRLF
		cQuery += "			AND SE1.E1_ORIGEM	= 'FINA087A'					"+CRLF
		cQuery += "			AND SED.ED_OPERADT	= '1'							"+CRLF //Operacao de adiantamento igual a SIM

		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		If (cAliasQry)->(!Eof())
			lRet := .F.		

			Help(" ",1,"FA088VLDCOMP")
			
		EndIf

		(cAliasQry)->(DbCloseArea())

	EndIf

EndIf

DbSelectArea("SEL")
SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO

//Validación EAI
If cPaisLoc == "MEX"
	If DbSeek(xFilial("SEL")+TRB->SERIE+TRB->NUMERO+'TB')
		DbSelectArea("SE1")
		SE1->(DbSetOrder(2)) //E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		If SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIENTE+SEL->EL_LOJA+SEL->EL_PREFIXO+SEL->EL_NUMERO))
			If Alltrim(SE1->E1_ORIGEM) $ 'FINI055|FINI040'
				lBajaEAI := .T.
				lBajaDGA := .T.
			ElseIf Alltrim(SE1->E1_ORIGEM) $ 'FINA040' .And. Alltrim(SE1->E1_TIPO) $ 'DGA'
				lBajaDGA := .T.
			EndIf
		EndIf
	EndIf
	If lBajaEAI
		If !FWHasEAI("FINA088",.T.,,.T.) //Valida que rutina se encuentre configurada como adapter para integración EAI
			If jData['origin'] ==  "FINA998" 
			AADD(aResponse,{.F.,400,STR0127,""})
		Else
			MsgAlert(STR0127) //"Para Anulación de Baja de Cuentas por Cobrar de origen FINI055 y FINI040, es necesario configurar adapter FINA088 para mensaje REVERSALOFACCOUNTRECEIVABLEDOCUMENTDISCHARGE."
		EndIf
		lRet := .F.
		EndIf
		If !(FA088Integ(.T.))
			lRet := .F.
		EndIf
	EndIf
EndIf

If cPaisLoc == "MEX" .and. lRet .and. lCfdi33 .And. !lBajaEAI .And. !lBajaDGA
	DbSelectArea("SEL")
	DbSetOrder(8) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If DbSeek(xFilial("SEL")+TRB->SERIE+TRB->NUMERO)
		If !lBorrar .And. Empty(SEL->EL_UUID)
			lRet := .F.
			If jData['origin'] ==  "FINA998" 
				AADD(aResponse,{.F.,400,STR0107,""})
			Else
				Help("",1,"PF088VLDUUID",, STR0107 ,1, 0 ) // #No puede anular recibo sin timbrar.#
			EndIf
		ElseIf lBorrar .And. !Empty(SEL->EL_UUID)
			lRet := .F.
			If jData['origin'] ==  "FINA998" 
				AADD(aResponse,{.F.,400,STR0108,""})
			Else
				Help("",1,"PF088VLDUUID",, STR0108 ,1, 0 )// #No puede borrar recibo timbrado.#
			EndIf
		EndIf
	EndIf
	
EndIf

RestArea(aAreaSEL)
RestArea(aAreaSE1)
RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SE5ProcIndºAutor  ³ Pedro Pereira Lima º Data ³  12/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a posição onde esta o indice E5_FILIAL+E5_PROCTRA  º±±
±±º          ³ pois esses indices estão em desacordo no dicionario atual  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA088 - exclusão de cobranças diversas                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SE5ProcInd()
Local nOrdem := 0

DbSelectArea("SIX")
DbSetOrder(1)
DbSeek("SE5")
While SIX->INDICE == "SE5" .And. !SIX->(Eof())
	nOrdem++
	If SIX->ORDEM == "F" .Or. SIX->CHAVE $ "E5_PROCTRA" //Verifico se o indice posicionado contem o campo E5_PROCTRA
		Exit
	EndIf
	SIX->(DbSkip())
EndDo

Return nOrdem
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA088CkSEF  ºAutor ³ Wagner Montenegro º Data ³ 18/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validação status do cheque p/Geração TRB cancel. recibo   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Argentina                                                 ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FA088CkSEF(cBcoCH,cAgeCH,cCtaCH,cPrxCH,cNumCH) 
Local aAreaSEF:=SEF->(GetArea())
Local nRet:=2
	SEF->(DbSetOrder(6))
	If SEF->(DbSeek(xFilial("SEF")+"R"+cBcoCH+cAgeCH+cCtaCH+Substr(cNumCH,1,TamSX3("EF_NUM")[1])+cPrxCH))
	   If SEF->EF_STATUS<>"00"
			If SEF->EF_STATUS<>"01"
			   nRet:=0
			Elseif SEF->EF_STATUS=="01" .and. FRF->(dbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM))
   	      nRet:=0
   	   Else
   	   	nRet:=1
			Endif
		Else
			If FRF->(dbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+SEF->EF_NUM))
				nRet:=0
			Else
				nRet:=2
			Endif
		Endif
   Endif

SEF->(RestArea(aAreaSEF))		
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA088MkAll  ºAutor ³ Marcos Berto      º Data ³ 06/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validação de seleção p/ cancelamento do recibo (ALL)      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Argentina                                                 ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA088MkAll(cAlias,cCampo)

While !(cAlias)->(Eof())

	FA088CkCan(cAlias,(cAlias)->&cCampo)
	(cAlias)->(dbSkip())	

EndDo 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA088CkCan  ºAutor ³ Wagner Montenegro º Data ³ 18/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validação de seleção no TRB p/ cancelamento do recibo     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Argentina                                                 ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA088CkCan(cAlias,cRecibo)
Local lRet:=.T. 
Local lMarca := NIL


If Empty((cAlias)->MARK) 
	If Empty((cAlias)->PODE) .and. Empty((cAlias)->CANCELADA)
	 	If (cAlias)->CHEQUE=="N" 
	  		If !IsInCallStack("FA088MkAll")
	  			Help(" ",1,"HELP",STR0064,STR0065,1,0)//"FA088 - CHEQUE EM CARTEIRA"//"Este recibo possui cheque em carteira no Controle de Cheques."
	  		EndIf
	  		lRet:=.F.
	   Elseif (cAlias)->CHEQUE=="U" 
	  		If !IsInCallStack("FA088MkAll")
	  			Help(" ",1,"HELP",STR0066,STR0067,1,0)//"FA088 - RECIBO LIQUIDADO"//"Este recibo não pode ser cancelado ou excluido."
	  		EndIf
	  		lRet:=.F.	   
	  	Endif
		If lRet
		   If (lMarca==NIL)
		   	lMarca := ((cAlias)->MARK== cMarcaTR)
		   Endif
		   TRB->MARK := If(lMarca,"",cMarcaTR)
		Endif
	Else
		If (cAlias)->PODE == "C"
			Help(" ",1,"HELP",STR0080,STR0081,1,0)//"FA088 - MOV. COMPENSADO"//"Este recibo possui mov. bancários compensados"	
		ElseIf !IsInCallStack("FA088MkAll")
			Help(" ",1,"HELP",STR0068,STR0069,1,0)//"FA088 - RECIBO LIQUIDADO"//"Este recibo não pode ser cancelado ou excluido."
		EndIf
		lRet:=.F.
	Endif
Else
   (cAlias)->MARK := ""
Endif	

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA088Leg³ Autor ³Wagner Montenegro        ³ Data ³18.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Exibe uma janela contendo a legenda                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA088Leg()

Local aCores     := {}
aAdd(aCores,{"BR_VERDE"		,STR0071}) //"Disponivel"
aAdd(aCores,{"BR_VERMELHO"	,STR0072}) //"Indisponivel"
If cPaisLoc=="ARG"
	aAdd(aCores,{"BR_LARANJA"	,STR0073}) //"Possui Cheque em Carteira"
	aAdd(aCores,{"BR_AMARELO"	,STR0074}) //"Pendente de Cancelamento"
	aAdd(aCores,{"BR_PINK"		,STR0079}) //"Pendente de Cancelamento"
ElseIf cPaisLoc=="MEX"
	aAdd(aCores,{"BR_AZUL"	,STR0083}) //"Timbrado"
	aAdd(aCores,{"BR_AMARELO",STR0169}) //"Anulado-No Timbrado"
Endif
BrwLegenda(cCadastro,STR0075,aCores) //Legenda//"Status para Cancelamento"

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA088PMS   ³ Autor ³Jandir Deodato        ³ Data ³04/09/12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida se o recibo está apropriado no Totvs Obras e Projetos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA088PMS(aResponse,jData)
Local aArea
Local aAreaSE1
Local aAreaAFT
Local cAliasTMP
Local lRet:=.T.
aArea:=GetArea()
dbSelectArea("SE1")
aAreaSE1:=SE1->(GetArea())
SE1->(dbSetOrder(1))//FILIAL+PREFIXO+NUM+PARCELA+TIPO
dbSelectArea("AFT")
aAreaAFT:=AFT->(GetArea())
AFT->(dbSetOrder(2))//FILIAL+PREFIXO+NUM+PARCELA+TIPO+CLIENTE+LOJA+PROJETO+REVISAO+TAREFA
cAliasTMP:=GetNextAlias()
If SE1->(dbSeek(xFilial("SE1")+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))
	If AFT->(dbSeek(xFilial("SE2")+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO+SEL->EL_CLIENTE+SEL->EL_LOJA))
		cQuery:="SELECT AFT_VIAINT FROM " +RetSqlName("AFT")
		cQuery+=" WHERE AFT_FILIAL = '"+xFilial("AFT") + "' AND AFT_PREFIX ='"+SEL->EL_PREFIXO+"' AND AFT_NUM ='"+SEL->EL_NUMERO+"'"
		cQuery+=" AND AFT_PARCEL='"+SEL->EL_PARCELA+"' AND AFT_TIPO='"+SEL->EL_TIPO+"' AND AFT_CLIENT='"+SEL->EL_CLIENTE+"'"
		cQuery+=" AND AFT_LOJA='"+SEL->EL_LOJA+"' AND D_E_L_E_T_ =' ' "
		cQuery:=ChangeQuery(cQuery)
		If Select(cAliasTMP)>0
			(cAliasTMP)->(dbCloseArea())
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTMP, .T., .T.)
		(cAliasTMP)->(dbGoTop())
		While (cAliasTMP)->(!EOF()) .and. lRet
			If (cAliasTMP)->AFT_VIAINT=='S'
				lRet:=.F.
				If jData['origin'] ==  "FINA998" 
					AADD(aResponse,{.F.,400,OemToAnsi(STR0076)+" "+"("+SEL->EL_TIPO+")"+" "+rTrim(SEL->EL_NUMERO)+" " +OemToAnsi(STR0077)+" "+OemToAnsi(STR0078),""})
				Else
					Help( " ", 1, "PMSXTOP",, OemToAnsi(STR0076)+" "+"("+SEL->EL_TIPO+")"+" "+rTrim(SEL->EL_NUMERO)+" " +OemToAnsi(STR0077)+CRLF+OemToAnsi(STR0078), 1, 0 )//O Título + "vinculado a este recibo esta apropriado  no Totvs Obras e Projetos." +"Desfaça a apropriação no TOP antes de cancelar o recibo"
				EndIf
			Endif
			(cAliasTMP)->(dbSkip())
		EndDo
		(cAliasTMP)->(dbCloseArea())
		If lRet
			PMSWriteRC(2,"SE1")//extorno
			PMSWriteRC(3,"SE1")//exclusao
		Endif
	Endif
Endif
RestArea(aAreaAFT)
RestArea(aAreaSE1)
RestArea(aArea)
Return lREt

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA088PMS   ³ Autor ³Daniel Mendes        ³ Data ³08/05/14    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida os documentos de retencao gerados proporcionalmente   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Uso exclusivo da Costa Rica que gera retencao na baixa       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function F088UpDcRetencao(cTrbNumero,cTrbSerieD,cFilialRet,cPrefixRet,cNumeroRet,cParcelRet,cTipoDocRet,cClientRet,cLojCliRet,cVlrDocRet,cTipPaiRet)
Local aAreaAuxTb := {}
Local cParAuxDoc := ""
local cTitAuxPai := ""
Local cAliasAnt  := ""
Local lAchouDcto := .F.
Local lVlrDctoIg := .F.
Local nOrdemSEL  := 0

	If cTipoDocRet$MVABATIM .And. cPaisLoc $ "COS"
		aAreaAux   := {SE1->(GetArea()),SEL->(GetArea()),GetArea()}
		cParAuxDoc := cParcelRet
		cAliasAnt  := Alias()
		SE1->(DbSetOrder(1))

		If SE1->(DbSeek(xFilial("SE1")+cPrefixRet+cNumeroRet+cParcelRet+cTipoDocRet+cClientRet+cLojCliRet))
			cTitAuxPai := SE1->E1_TITPAI
			lVlrDctoIg := SE1->E1_VALOR == cVlrDocRet

			//Faz a busca pelo documento que originou a retenção, a parcela pode ser diferente, portanto é feita uma busca até encontrar o mesmo
			If !SE1->(DbSeek(xFilial("SE1")+cPrefixRet+cNumeroRet+cParcelRet+cTipPaiRet+cClientRet+cLojCliRet))
				While !Empty(AllTrim(cParAuxDoc)) .And. !lAchouDcto
					If AllTrim(cParAuxDoc) == "1"//Parcela anterior é vazia
						cParAuxDoc := Space(Len(SE1->E1_PARCELA))
					Else
						cParAuxDoc := Chr(Asc(cParAuxDoc) - 1)
					EndIf
					If SE1->(DbSeek(xFilial("SE1")+cPrefixRet+cNumeroRet+cParAuxDoc+cTipPaiRet+cClientRet+cLojCliRet))
						If AllTrim(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA) == AllTrim(cTitAuxPai)
							nOrdemSEL := SEL->(IndexOrd())
							SEL->(DbSetOrder(2))
							If SEL->(DbSeek(xFilial("SEL")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA))
								lAchouDcto := .T.
								F088AtuaSE1(cTrbSerieD,cTrbNumero,.F.,cParcelRet)
							EndIf
							SEL->(DbSetOrder(nOrdemSEL))
						EndIf
					EndIf
				EndDo
			EndIf

			//Apaga o documento de retenção encontrado, caso o documento original também seja encontrado
			If lAchouDcto .And. lVlrDctoIg
				SE1->(DbSeek(xFilial("SE1")+cPrefixRet+cNumeroRet+cParcelRet+cTipoDocRet+cClientRet+cLojCliRet))
				RecLock("SE1",.F.)
				Replace SE1->E1_BAIXA  With Ctod("  /  /  ")
				Replace SE1->E1_RECIBO With Space(Len(SE1->E1_RECIBO))
				Replace SE1->E1_SERREC With Space(Len(SE1->E1_SERREC))
				Replace SE1->E1_SALDO  With cVlrDocRet
				SE1->(DbDelete())
				SE1->(MsUnLock())
			EndIf
		EndIf

		aEval(aAreaAuxTb,{|xArea| RestArea(xArea)})
		dbSelectArea(cAliasAnt)
	EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fa088CFDI  ³ Autor ³Alfredo Medrano       ³ Data ³08/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Timbrado CFDI para Recibos de Cobro                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias: Alias Actual Utilizado tabla Temporal, nReg, nOpcx  ³±±
±±³          ³ nReg : Número de Registro                                   ³±±
±±³          ³ nOpcx: opcion del MenuDef                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Fina088                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa088CFDI(cAlias,nReg,nOpcx)
Local cSaltoL  := Chr(10)+ Chr(13)
Local cCod	   := ""
Local cMSg 	   := ""
Local aRegPro  := {}
Local nCon 	   := 0
Local nMark    := 0
Local oMark    := GetMarkBrow()
Local cLogRec  := ""
Local nImpAuto := SuperGetMv("MV_CFDREC",.T.,0) //Generacion automatica complemneto de pago
Local cAvisoE  := ""
Local lConfTimb:= .T.
Local lTimVld  := .T.
Local lHora := SEL->(ColumnPos("EL_HORA")) > 0
Local cMensaje := ""
Local nI       := 0
Local cDirLocal:= GetTempPath()
Local cMsjEnv  := ""
Local lVldMsj  := .F.

Private nContT	:= 0
Private nRegT	:= 0
Private nRegC   := 0
Private lSCan   := .F.
Private aRegTim := {}
Private lEnvEmail := (nImpAuto == 3 .Or. nImpAuto == 4)

If cPaisLoc == "MEX" .and. nOpcx == 6
	SEL->(DbSelectArea("SEL"))
	SEL->(DbSetOrder(8))	//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	TRB->(DbSelectArea("TRB"))
	TRB->(DbGoTop())
	cCod:= PADR( "RA",TamSx3("EL_TIPODOC")[1]," ")
	While TRB->(!EOF())
		If IsMArk("MARK",cMarcaTR,lInverte)
			If Empty(TRB->UUID) .And. Empty(TRB->FECTIMB) // Si el recibo ya fue timbrado, no se permite volver a timbrar
				If SEL->(ColumnPos("EL_GENCFD")) > 0
					If !Empty(TRB->GENCFD)
						cAvisoE += IIf(!Empty(TRB->SERIE), Alltrim(TRB->SERIE) + "-" + TRB->NUMERO + space(1), TRB->NUMERO + space(1))
						cAvisoE += STR0132 + cSaltoL //"Contiene documentos pagados en una sola exhibición (PUE), compensaciones o es un Recibo Anticipado (RA)."
					Else
						nMark++
						If lHora
							aAdd(aRegPro, {TRB->NUMERO,TRB->SERIE,TRB->EMISION,TRB->HORA})	
						Else
							aAdd(aRegPro, {TRB->NUMERO,TRB->SERIE})
						EndIf	
					EndIf				
				Else
					nMark++
					If lHora
						aAdd(aRegPro, {TRB->NUMERO,TRB->SERIE,TRB->EMISION,TRB->HORA})
					Else
						aAdd(aRegPro, {TRB->NUMERO,TRB->SERIE})
					EndIf	
				EndIf
			Else
				If !Empty(TRB->CANCELADA) .Or. !Empty(TRB->PODE) .Or. !Empty(TRB->UUID)			
					cAvisoE += IIf(!Empty(TRB->SERIE), Alltrim(TRB->SERIE) + "-" + TRB->NUMERO + space(1), TRB->NUMERO + space(1)) + STR0122 + cSaltoL //"ya fue timbrado."
				EndIf				
				RecLocK("TRB")
				TRB->MARK := ""
				TRB->(MsUnlock())
			EndIf
		EndIf
		TRB->(DbSkip())
		DbSelectArea("TRB")
	EndDo

	SEL->(DbCloseArea())
	If !Empty(cLogRec)
		cLogRec +=  STR0109 //"Solo recibos disponibles pueden ser timbrados."//"Recibo"		
		MsgInfo(cLogRec,STR0059) // Atención
		oMark:oBrowse:Refresh()
	EndIf
	
	If !Empty(cAvisoE)	
		MSGALERT(cAvisoE , STR0083)//"No hay Recibos seleccionados"//"Timbrado"
	Else
		If nMark > 0		    
			If (nImpAuto == 0 .Or. nImpAuto == 1 .Or. nImpAuto == 3 .Or. nImpAuto == 4)
				If nImpAuto == 0 .Or. nImpAuto == 3
					lConfTimb := MSGYESNO( STR0090 , STR0091  ) //"¿Desea realizar el Complemento de Recepción de Pago?"//"Complemento de Recepción de Pagos"
				EndIf
				If lConfTimb
					If FindFunction("F815VldTim") .And. SEL->(ColumnPos("EL_HORA")) > 0
						lTimVld := F815VldTim(aRegPro)
					EndIf
					
					If lTimVld
						IIf(!Empty(cMSg),MSGALERT(STR0094 + substr(cMSg,1,Len(cMSg)-2) + cSaltoL + STR0095, STR0083 ),)//"Los Recibos de Anticipo(RA): " // "no serán timbrados" //"Timbrado"
					   	Processa( {|lEnd| fa088Timb(aRegPro)},STR0092 ,STR0093 , .T. )//"Aguarde..."//"Procesando."
						cMensaje := alltrim(str(nContT)) + space(1) + STR0088	+ space(1) +  Alltrim(str(nRegT)) //"Recibos Timbrados de "
						If lSCan
							cMensaje += cSaltoL + "Recibos anulados: " + Str(nRegC)
						EndIf
						If nContT == 0 .Or. Empty(aDoctos)
							 MsgInfo( cMensaje, STR0089 ) //"Doctos. Timbrados"
						Else
							cMensaje += CRLF + CRLF + STR0137 //"¿Desea visualizar los documentos impresos?"
							If MsgYesNo( cMensaje , STR0089 ) //"Doctos. Timbrados"
								//Copiar archivo al cliente a carpeta temporales.
								For nI := 1 to Len(aDoctos)
									If CpyS2T( aDoctos[nI][1] , cDirLocal)
										aDoctos[nI][3] := .T.
									EndIf
								Next nI
								//Abrir documentos que se copiaron a carpeta temporales.
								For nI := 1 to Len(aDoctos)
									If aDoctos[nI][3] == .T.
										ShellExecute("Open",aDoctos[nI][2],"",cDirLocal,1)
									EndIf
								Next nI
							EndIf
							If nImpAuto == 3
								lEnvEmail := MSGYESNO( STR0140, STR0139 ) // "¿Desea realizar el envío por correo del Complemento de recepción de pago?" - "Envío del Complemento de recepción de pagos"
							Endif
							If (lEnvEmail .or. nImpAuto == 4) .and. ValParam()
								For nI := 1 to Len(aRegTim)
									if Empty(aRegTim[nI][5])
										aRegTim[nI][4] := EnvRecMail(aRegTim[nI][8],aRegTim[nI][9])
									EndIf
								Next nI
								ImprimeLog(aRegTim)
							Endif
						EndIf
						aRegTim := {}
						oMark:oBrowse:Refresh()
					EndIf
				EndIf
			EndIf		     
		Else 	
			MSGALERT(STR0096 , STR0083)//"No hay Recibos seleccionados"//"Timbrado"
		EndIf
	EndIf
EndIf
Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fa088Timb  ³ Autor ³Alfredo Medrano       ³ Data ³08/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Timbrado CFDI para Recibos de Cobro                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  aRegPro : array con Recibos diferentes a RA                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Fina088                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function fa088Timb(aRegPro)
Local aArea	:= GetArea()
Local nI 	:= 0
Local nReg	:= 0
Local cFilSEL := xfilial("SEL")
Local cSerSus := ""
Local cRecSus := ""

nReg := Len(aRegPro)
ProcRegua(nReg)
aDoctos := {}

TRB->(DbSelectArea("TRB"))
TRB->(DbSetOrder(1))//"SERIE+NUMERO"
SEL->(DbselectArea('SEL'))
SEL->(DbSetOrder(8))	//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
For nI := 1 to  nReg
	IncProc(STR0097+aRegPro[nI][1])//"Timbrando Recibo: "
	If SEL->(Dbseek(cFilSEL + aRegPro[nI][2] + aRegPro[nI][1]))
		If !Empty(SEL->EL_SERSUS) .Or. !Empty(SEL->EL_RECSUS)
			cSerSus := SEL->EL_SERSUS
			cRecSus := SEL->EL_RECSUS
		EndIf
	EndIf
	FISA815(aRegPro[nI][1],aRegPro[nI][2],0, @aDoctos,,,cSerSus,cRecSus) //función de XML y timbrado
	If nRegC > 0
		F088ActTRB(cSerSus,cRecSus)
	EndIf
Next

SEL->(dbGoTop())
nRegT := Len(aRegTim) // array que contiene los recibos timbrados y no timbrados
For nI := 1 to  nRegT

	If aRegTim[nI][3]

		If SEL->(Dbseek(xfilial("SEL")+aRegTim[nI][2]+aRegTim[nI][1]))
			If TRB->(Dbseek(aRegTim[nI][2]+aRegTim[nI][1]))
				RecLock("TRB",.f.)
				TRB->FECTIMB 	:= SEL->EL_FECTIMB
				TRB->UUID 		:= SEL->EL_UUID
				TRB->MARK		:= "  "
				MsUnLock()
			EndIf
		Endif
		nContT++
	Endif

Next nI
SEL->(DbCloseArea())
RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA088CKMX  ³ Autor ³Alfredo Medrano       ³ Data ³08/11/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³valida la seleccion de Recibos timbrados y borrados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias: Alias Actual Utilizado tabla Temporal, nReg, nOpcx  ³±±
±±³          ³ cRecibo : Número de Recibo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Fina088                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA088CKMX(cAlias,cRecibo)
Local lRet	:= .T.
Local lMarca := NIL

If Empty((cAlias)->MARK)
	If cPaisLoc=="MEX"
		If  !Empty((cAlias)->CANCELADA) .And. !((cAlias)->CANCELADA == "P")
	  		MsgInfo(STR0085 + space(1) +  STR0086 , STR0002  )//"El Recibo no se puede seleccionar, "//"está anulado"//"Recibo"
	  		lRet := .F.
		EndIf
	Else
		If !Empty((cAlias)->PODE) .OR. !Empty((cAlias)->CANCELADA)
	  		MsgInfo(STR0085 + space(1) +  STR0086 , STR0002  )//"El Recibo no se puede seleccionar, "//"está anulado"//"Recibo"
	  		lRet := .F.
		EndIf
	EndIf

	If lRet
		If (lMarca==NIL)
		 	lMarca := ((cAlias)->MARK== cMarcaTR)
		Endif
		TRB->MARK := If(lMarca,"",cMarcaTR)
	Endif

Else

   (cAlias)->MARK := ""

Endif

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA088AnuBor³ Autor ³A Rodriguez           ³ Data ³20/02/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida anulación/borrado de recibos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lBorrar: .F. = Anular, .T. = Borrar   					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FA088Cancel                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA088AnuBor(lBorrar,aResponse,jData)

Local aAreaTrb	:= TRB->(GetArea())
Local cMsg		:= ""
Local cMsj		:= ""
Local lRet		:= .T.
Local lBajaEAI  := .F.
Local lBajaDGA  := .F.
Local aRetMsg   := {} 

TRB->(DbSelectArea("TRB"))
TRB->(DbGoTop())

While TRB->(!EOF())
	If IsMArk("MARK",cMarcaTR,lInverte)
		If !lBorrar
			If cPaisLoc == "MEX"
				DbSelectArea("SEL")
				SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
				//Validación EAI
				If DbSeek(xFilial("SEL")+TRB->SERIE+TRB->NUMERO+'TB') .Or. DbSeek(xFilial("SEL")+TRB->SERIE+TRB->NUMERO+'CO')
					DbSelectArea("SE1")
					SE1->(DbSetOrder(2)) //E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
					If SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIENTE+SEL->EL_LOJA+SEL->EL_PREFIXO+SEL->EL_NUMERO))
						If Alltrim(SE1->E1_ORIGEM) $ 'FINI055|FINI040'
							lBajaEAI := .T.
						ElseIf Alltrim(SE1->E1_ORIGEM) $ 'FINA040' .And. Alltrim(SE1->E1_TIPO) $ 'DGA'
							lBajaDGA := .T.
						EndIf				
					EndIf
					If lBajaEAI
						If FWHasEAI("FINI087A",.T.,,.T.) 
							SetRotInteg('FINI087A')
							MsgRun ( "Atualizando título"+" "+rTrim(SE1->E1_NUM)+ " " +"a valor presente...","Valor Presente",{||aRetMsg:=FinI087()} )//"Atualizando título" "a valor presente..." Valor Presente									
							If ValType(aRetMSg[1]) <> "U" .And. !aRetMsg[1]
								If ValType(aRetMsg[2]) <> "U" .And. aRetMsg[2] <> Nil .and. !Empty(aRetMsg[2])
									MsgAlert("Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:" + CRLF + aRetMsg[2])//"Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:"
								Else
									MsgAlert("Ocorreu um erro inesperado na tentativa de atualização do título " + " " + Rtrim(SE1->E1_NUM)+". "+"Verifique as configurações da integração  e tente novamente.")//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
								EndIf
							ElseIf Valtype(aRetMSg[1]) == "U"
								MsgAlert("Ocorreu um erro inesperado na tentativa de atualização do título " + " " + Rtrim(SE1->E1_NUM) + ". " + "Verifique as configurações da integração  e tente novamente.")//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
							Endif
							SetRotInteg('FINA087A')
						Else
							MsgAlert("Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL.")//"Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL."
						EndIf	
					EndIf	
				EndIf
			EndIf
			
			If !lBajaEAI .And. !lBajaDGA
				// Anular; El recibo debe estar timbrado (azul)
				If (!Empty(TRB->CANCELADA) .And. !(TRB->CANCELADA=="P")) .Or. !Empty(TRB->PODE) .Or. Empty(TRB->UUID)
					cMsg += IIf( Empty(cMsg), "", ", " + CRLF ) + TRB->SERIE + TRB->NUMERO + STR0116 //" CFDI no generado."
				Else
					FA088ChkCFDI( TRB->SERIE , TRB->NUMERO , @cMsj )
				Endif
			EndIf
		Else
			// Borrar; el recibo debe estar disponible (verde)
			If !Empty(TRB->CANCELADA) .Or. !Empty(TRB->PODE) .Or. !Empty(TRB->UUID)
				cMsg += IIf( Empty(cMsg), "", ", " + CRLF ) + TRB->SERIE + TRB->NUMERO
			Endif
		Endif
	EndIf

	TRB->(DbSkip())
EndDo

TRB->(RestArea(aAreaTrb))

If Len(cMsg + cMsj) > 0

	If !lBorrar
		If !Empty(cMsg)
			cMsg := STR0103 + STR0104 + CRLF + cMsg // #El recibo seleccionado no puede ser# #anulado.# ... #Los siguientes recibos no pueden ser# #anulados:#
		Endif
		cMsg += CRLF + cMsj
		If jData['origin'] ==  "FINA998" 
			AADD(aResponse,{.F.,400,cMsg + " "+ STR0101,""})
		Else
			MsgAlert( cMsg + CRLF + STR0101, STR0102 ) // ... #Solo es posible anular recibos Timbrados# #Anular recibos#
		EndIf
	Else
		cMsg := STR0103 + STR0105 + CRLF + cMsg // #El recibo seleccionado no puede ser# #borrado.# ... #Los siguientes recibos no pueden ser# #borrados:#
		If jData['origin'] ==  "FINA998" 
			AADD(aResponse,{.F.,400,cMsg,""})
		Else
			MsgAlert( cMsg , STR0106 ) // #Borrar recibos#
		EndIf
	EndIf

	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función  ³FA088ChkCFDI³ Autor ³ A. Rodriguez         ³ Data ³ 22/02/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Valida archivo XML del CFDI.						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ FA088CkCFDI( cFile , cRecibo )                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ CFDiRecPag                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FA088ChkCFDI( cSerie, cNumero , cMsj )
Local cDir		:= &(SuperGetmv( "MV_CFDRECP" , .F. , "GetSrvProfString('startpath','')+'\cfd\recPagos\'" ))
Local cFile		:= ""
Local nHandle	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
Local nRegs		:= 0
Local nFor		:= 0
Local cBuffer	:= ""
Local cLine		:= ""
Local lRet		:= .T.

Default cSerie	:= ""
Default cNumero	:= ""

cFile := cDir + "ReciboPago" + AllTrim(cSerie) + AllTrim(cNumero)  + ".xml"

Begin Sequence
	// Validar existencia del CFDI (XML)
	If !File(cFile)
		cMsj += IIf( Empty(cMsj), "", CRLF ) + cSerie + cNumero + STR0112 // # Archivo XML (CFDI) no encontrado.#
		lRet := .F.
		Break
	EndIf

   	nHandle := fOpen(cFile)

	If nHandle <= 0
		cMsj += IIf( Empty(cMsj), "", CRLF ) + cSerie + cNumero + STR0113 // # No fue posible abrir el archivo XML (CFDI).#
		lRet := .F.
		Break
	EndIf

	aInfoFile := Directory(cFile)
	nSize := aInfoFile[ 1 , 2 ]
	nRegs := Int(nSize/2048)

	For nFor := 1 to nRegs
		fRead( nHandle , @cBuffer , 2048 )
		cLine += cBuffer
	Next

	If nSize > nRegs * 2048
		fRead( nHandle , @cBuffer , (nSize - nRegs * 2048) )
		cLine += cBuffer
	Endif

	fClose(nHandle)

	// Corresponda con el recibo y que esté timbrado
	If !('Folio="' + AllTrim(cNumero) + '"') $ cLine .And. IIf(!Empty(cSerie), !('Serie="' + AllTrim(cSerie) + '"') $ cLine, .T.)
		cMsj += IIf( Empty(cMsj), "", CRLF ) + cSerie + cNumero + STR0114 // # El archivo XML (CFDI) no corresponde al recibo.#
		lRet := .F.
	ElseIf !"UUID=" $ cLine
		cMsj += IIf( Empty(cMsj), "", CRLF ) + cSerie + cNumero + STR0115// # El archivo XML (CFDI) no está timbrado.#
		lRet := .F.
	EndIF

End Sequence

Return 	lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³FA088CFDIAnu³ Autor ³A Rodriguez           ³ Data ³20/02/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cancela CFDI con complemento de pago (Recibo electrónico)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                       					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FA088Cancela                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA088CFDIAnu(cMtCanR,cUUIDCanR,aResponse,jData)

Local cNomXML	:= "ReciboPago" + Alltrim(TRB->SERIE) + Alltrim(TRB->NUMERO)  + ".xml"
Local aPagos	:= {}
Local aRecibos	:= {{cNomXML, "", "", aPagos,cMtCanR,cUUIDCanR}}
Local lRet		:= .F.
Default cMtCanR := ""
Default cMtCanR   := ""
Default cUUIDCanR := ""

Private cDir	:= &(SuperGetmv( "MV_CFDRECP" , .F. , "GetSrvProfString('startpath','')+'\cfd\recPagos\'" ))

lRet := CFDiRecPag(aRecibos, .F., aResponse,jData)

If lRet
	F088UPDCAN(TRB->SERIE,TRB->NUMERO)
EndIf
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fa088Imp   ³ Autor ³M. Camargo 		    ³ Data ³05/03/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Re impresión PDF CFDI para Recibos de Cobro                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias: Alias Actual Utilizado tabla Temporal, nReg, nOpcx  ³±±
±±³          ³ nReg : Número de Registro                                   ³±±
±±³          ³ nOpcx: opcion del MenuDef                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Fina088                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fa088Imp(cAlias,nReg,nOpcx)

	Local cSaltoL		:= Chr(10)+ Chr(13)
	Local cCod			:= ""
	Local cMSg			:= "" 
	Local aRegPro		:= {}
	Local nCon			:= 0 
	Local nMark			:= 0 
	Local oMark			:= GetMarkBrow()
	Local cLogRec		:= ""
	Local cURLValCFD	:= AllTrim(SuperGetMV("MV_VERICFD", .F., "")) //Url de Verificación de Comprobantes Fiscales Digitales por Internet.
	Local cMensaje		:= ""
	Local cDirLocal		:= GetTempPath()
	Local nI			:= 0

	Private nContT		:= 0
	Private nRegT		:= 0
	Private aRegTim		:= {}
	
	If cPaisLoc == "MEX" .and. nOpcx == 7 // paRA mx Y OPCIÓN iMPRIMIR
		SEL->(DbSelectArea("SEL"))
		SEL->(DbSetOrder(8))	// EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
		TRB->(DbSelectArea("TRB"))
		TRB->(DbGoTop())
		cCod:= PADR( "RA",TamSx3("EL_TIPODOC")[1]," ")   
		While TRB->(!EOF())			
			If IsMArk("MARK",cMarcaTR,lInverte)	
				If !Empty((cAlias)->UUID) .and. !Empty((cAlias)->FECTIMB)			
					nMark++
						aAdd(aRegPro, {TRB->NUMERO,TRB->SERIE})			
				Else
					If SEL->(ColumnPos("EL_GENCFD")) > 0
						If !Empty(TRB->GENCFD)
							cLogRec += IIf(!Empty(TRB->SERIE), Alltrim(TRB->SERIE) + "-" + TRB->NUMERO + space(1), TRB->NUMERO + space(1))
							cLogRec += STR0132 + space(1)
						Else
							cLogRec += TRB->SERIE + TRB->NUMERO + "-" + STR0125+ space(1) + (chr(13)+chr(10))//"Recibo pendiente de timbrado."
						EndIf
					Else
						cLogRec += TRB->SERIE + TRB->NUMERO + "-" + STR0125+ space(1) + (chr(13)+chr(10))//"Recibo pendiente de timbrado."
					EndIf					
					RecLocK("TRB")
						TRB->MARK := ""
					TRB->(MsUnlock())					
				EndIf
			EndIf			
			TRB->(DbSkip())
			DbSelectArea("TRB")					
		EndDo	
		SEL->(DbCloseArea())
		If !Empty(cLogRec)
			cLogRec += STR0119 //"Solo es posible Imprimir recibos Timbrados."
			MsgAlert(cLogRec,STR0059) // Atención 
		Else
			If nMark > 0
				If Empty(cURLValCFD)
					MsgInfo(STR0129) //"El parámetro MV_VERICFD se encuentra vacío, es necesario informar la url de Verificación de Comprobantes Fiscales Digitales por Internet, la cual es necesario para generar correctamente el Código QR. Informe el parámetro e intente nuevamente."
					Return
				EndIf
			    If MsgYesNo( STR0120 , STR0091  ) //"¿Desea Imprimir PDF del Complemento de Recepción de Pago?"//"Complemento de Recepción de Pagos"
					IIf(!Empty(cMSg),MSGALERT(STR0094 + substr(cMSg,1,Len(cMSg)-2) + cSaltoL + STR0124, STR0083 ),)//"Los Recibos de Anticipo(RA): " // "no serán Impresos" //"Timbrado"
					Processa( {|lEnd| fa088ImpPDF(aRegPro)},STR0092 ,STR0093 , .T. )//"Aguarde..."//"Procesando."
					cMensaje := alltrim(str(nContT)) + space(1) + STR0121	+ space(1) +  Alltrim(str(nRegT))

					If nContT == 0 .Or. Empty(aDoctos)
						MsgInfo( cMensaje, STR0138 ) //"Recibos Impresos de " //"Doctos. Impresos"
					Else
						cMensaje += CRLF + CRLF + STR0137 //"¿Desea visualizar los documentos impresos?"
						If MsgYesNo( cMensaje , STR0138 ) //"Doctos. Impresos"
							//Copiar archivo al cliente a carpeta temporales.
							For nI := 1 to Len(aDoctos)
								If CpyS2T( aDoctos[nI][1] , cDirLocal)
									aDoctos[nI][3] := .T.
								EndIf
							Next nI
							//Abrir documentos que se copiaron a carpeta temporales.
							For nI := 1 to Len(aDoctos)
								If aDoctos[nI][3] == .T.
									ShellExecute("Open",aDoctos[nI][2],"",cDirLocal,1)
								EndIf
							Next nI
						EndIf
					EndIf
					oMark:oBrowse:Refresh()
				EndIf			
			Else	
				MSGALERT(STR0096 , STR0083)//"No hay Recibos seleccionados"//"Timbrado"		
			EndIf
		EndIf
	EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fa088ImpPDF³ Autor ³M. Camargo 		    ³ Data ³05/03/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impresion de PDF.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRegPro: Arreglo con Recibos a Imprimir.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Fina088                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fa088ImpPDF(aRegPro)
	Local aArea	:= GetArea()
	Local nI	:= 0
	Local nReg	:= 0
	
	nReg := Len(aRegPro) 
	ProcRegua(nReg) 
	aDoctos := {}
	
	For nI := 1 to  nReg
		IncProc(STR0123 + aRegPro[nI][1])//"Imprimiendo Recibo: "
		FISA815(aRegPro[nI][1],aRegPro[nI][2],1, @aDoctos) //Solo generación de PDF
	Next nI
	
	TRB->(DbSelectArea("TRB"))
	TRB->(DbSetOrder(1))		//"SERIE+NUMERO"
	SEL->(DbselectArea('SEL'))
	SEL->(DbSetOrder(8))		//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO		
	nRegT := Len(aRegTim) 		// array que contiene los recibos timbrados y no timbrados
	For nI := 1 to  nRegT
		If aRegTim[nI][3]			
			If SEL->(Dbseek(xfilial("SEL")+aRegTim[nI][2]+aRegTim[nI][1]))
				If TRB->(Dbseek(aRegTim[nI][2]+aRegTim[nI][1]))
					RecLock("TRB",.f.)
					TRB->FECTIMB 	:= SEL->EL_FECTIMB
					TRB->UUID 		:= SEL->EL_UUID
					TRB->MARK		:= "  "
					MsUnLock() 
				EndIf
			Endif
			nContT++
		Endif				
	Next nI
	SEL->(DbCloseArea())
	aRegTim := {}
	RestArea(aArea)		
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³IntegDef   ³ Autor ³ Luis E. Enríquez Mata³ Fecha ³22/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Función para integración EAI                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FINA0888                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( cXml, nType, cTypeMsg)  
	Local aRet      := {}	
	Private aRetMsg	:= {}
	  
	If Type("cIntegSeq")=="U"
		Private cIntegSeq := ""
	EndIf
	
	ALTERA := .F.
	
	aRet := FINI087( cXml, nType, cTypeMsg )
	
	If Len(aRet) > 0
		If !aRet[1]
			MsgAlert(aRet[2])
		EndIf		
	EndIf
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³FA088Integ ³ Autor ³ Luis E. Enríquez Mata³ Fecha ³20/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Valida existencia configuración de Adapter p/integración EAI ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FINA088                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA088Integ(lCancel,lMSG)
	Local aSave    := {}
	Local lRet     := .T.
	Local cMensagem:= 'REVERSALOFACCOUNTRECEIVABLEDOCUMENTDISCHARGE'
	Local cRotina  := 'FINA088' 
	Local aXX4     := {}
	
	Default lMSG  := .T.
	
	If !(Alltrim(SE1->E1_TIPO)=="PR")
	 	//Valida que rutina se encuentre configurada como adapter para integración EAI
		If !EMPTY(__lF088EAI := FWHasEAI(cRotina,.T.,,.T.))
			aSave := GetArea()	
			If Len(aXX4:= FwAdapterInfo(cRotina,cMensagem)) > 0
				If !(Alltrim(aXX4[5])=='1')
					If lMSG
						HELP(" ",1,"FA088INTEG",,STR0126,2,0) //"El adapter de Anulación de Baja de Cuentas por Cobrar (FINA088) está configurado como NO SINCRONIZADO en el configurador. Configurar como SINCRONIZADO."						
					EndIf
					lRet := .F.
				EndIf
			EndIf
			RestArea(aSAve)	
		EndIf
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³BajaTitEAI ³ Autor ³ Luis E. Enríquez Mata³ Fecha ³22/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Función para baja de titulos de cxc por integración EAI      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FINA088                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BajaTitEAI(cSerie, cNumero,aResponse,jData)
	Local aArea := GetArea()
	Local lRet := .T.
	
	DbSelectArea("SEL")
	SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	
	//Validación EAI
	If DbSeek(xFilial("SEL") + cSerie + cNumero + 'TB')
			DbSelectArea("SE1")
			SE1->(DbSetOrder(2)) //E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
			If SE1->(DbSeek(xFilial("SE1") + SEL->EL_CLIENTE+SEL->EL_LOJA+SEL->EL_PREFIXO+SEL->EL_NUMERO))
				If Alltrim(SE1->E1_ORIGEM) $ 'FINI055|FINI040'
						SE5->(DbSetOrder(8)) //E5_FILIAL + E5_ORDREC + E5_SERREC
						SE5->(DbSeek(xFilial("SE5") + cNumero + cSerie))					  
						While !SE5->(EoF()) .And. SE5->E5_ORDREC == cNumero .And. SE5->E5_SERREC == cSerie
							If SE5->E5_PREFIXO == SE1->E1_PREFIXO .And. SE5->E5_NUMERO == SE1->E1_NUM .And.  SE5->E5_PARCELA == SE1->E1_PARCELA ;
							  .And. SE5->E5_TIPO == SE1->E1_TIPO .And. SE5->E5_CLIFOR == SE1->E1_CLIENTE .And. SE5->E5_LOJA == SE1->E1_LOJA
								If FWHasEAI("FINA088",.T.,,.T.)
									cIntegSeq:= SE5->E5_SEQ //utilizada na integdef. Nao transformar em local.
									ALTERA := .F.
									aRetInteg := FwIntegDef( 'FINA088' )
									//Se der erro no envio da integração, então faz rollback e apresenta mensagem em tela para o usuário
									If ValType(aRetInteg) == "A" .AND. Len(aRetInteg) >= 2 .AND. !aRetInteg[1]
										If !IsBlind()
											If jData['origin'] ==  "FINA998" 
												AADD(aResponse,{.F.,400,"Error" + ": " + "Ocorreu um erro inesperado na tentativa de atualização do título: Cancelamento da Baixa " + " - " + AllTrim( aRetInteg[2] ),"Verifique se a integração está configurada corretamente."})
											Else
												Help( ,, "FINA088INTEG",, "Error" + ": " + "Ocorreu um erro inesperado na tentativa de atualização do título: Cancelamento da Baixa " + " - " + AllTrim( aRetInteg[2] ), 1, 0,,,,,, {"Verifique se a integração está configurada corretamente."} ) //"Ocorreu um erro inesperado na tentativa de atualização do título: Cancelamento da Baixa ", "Verifique se a integração está configurada corretamente."  
											EndIf  						
										Endif
										DisarmTransaction()
										lRet := .F.
										Return .F.
									Else
										If Alltrim(SE1->E1_TIPO) $ 'DGA'
											lBDGA   := .T.
										EndIf
										lBInteg := .T.
									EndIf  
								EndIf
							EndIf
							SE5->(DbSkip())
				        EndDo
				ElseIf Alltrim(SE1->E1_ORIGEM) $ 'FINA040' .And. Alltrim(SE1->E1_TIPO) $ 'DGA'
					lBDGA := .T.
		        EndIf
			EndIf
	EndIf
	RestArea(aArea)	
Return lRet

/*/{Protheus.doc} PesqKeyCTB
//Busca KEY por el código de asiento en CTL
@author oscar.lopez
@since 09/07/2019
@version 1.0 
@param cCod, char, Codigo asiento
@type function
/*/
Function PesqKeyCTB(cCod)
	Local aKey		:= {}
	Local aTmpCTL	:= GetArea("CTL")
	
	Default cCod	:= ""
	
	If !Empty(cCod)
		DbSelectArea("CTL")
		CTL->(DbSetOrder(1))//CTL_FILIAL+CTL_LP
		If CTL->(MsSeek(xFilial("CTL")+cCod))
			aKey := {CTL->CTL_ALIAS, Alltrim(CTL->CTL_KEY)}
		EndIf
	EndIf
	RestArea(aTmpCTL)
Return aKey

/*/{Protheus.doc} ArmaKeyCTB
//Crea llave para buscar en CT2 y CTK
@author oscar.lopez
@since 09/07/2019
@version 1.0 
@param aKey, array, Llaves a buscar
@type function
/*/
Function ArmaKeyCTB(aKey)
	Local cKey		:= ""
	
	Default aKey := {}
	
	cKey := &(aKey[1] + "->(" + aKey[2] + ")" )
Return cKey

/*/{Protheus.doc} AtuCTBFF
//Actualiza Folio Fiscal en tabla CT2 y CTK
@author oscar.lopez
@since 09/07/2019
@version 1.0 
@param aRegQuery, array, Registros
@param cUUID, char, UUID
@type function
/*/
Function AtuCTBFF(aRegQuery, cUUID)
	Local aTmpCT2	:= GetArea("CT2")
	Local aTmpCTK	:= GetArea("CTK")
	Local cKeyCT2	:= "CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC"
	Local cKeyCTK	:= "CTK_FILIAL+DTOS(CTK_DATA)+CTK_SEQUEN+CTK_LP"
	Local nX		:= 0
	Local cQry		:= ""
	Local cQryCT2	:= ""
	Local cQryCTK	:= ""
	Local aTmpReg	:= {}
	Local cAls		:= GetNextAlias()
	Local cKey		:= ""
	Local nTotal	:= 0
	
	Default aRegQuery	:= {}
	Default cUUID		:= ""
	
	For nX := 1 To Len(aRegQuery)
		cKey := cValToChar(aRegQuery[nX])
		If (aScan(aTmpReg, cKey) == 0)
			aAdd(aTmpReg, cKey)
			cQryCT2 += " CT2_KEY LIKE '" + cKey +"'"
			cQryCTK += " CTK_KEY LIKE '" + cKey +"'"
			If nX < Len(aRegQuery)
				cQryCT2 += " OR"
				cQryCTK += " OR"
			EndIf
		EndIf
	Next Nx
	
	//Actualizacion UUID en tabla CT2
	If !Empty(cQryCT2)
		cQry := " SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_SEQUEN, CT2_ROTINA, CT2_LP,"
		cQry += " CT2_KEY, CT2_UUID, R_E_C_N_O_ "
		cQry += " FROM " + RetSqlName("CT2")
		cQry += " WHERE (" + cQryCT2 + ")"
		cQry += " AND D_E_L_E_T_ <> '*'"
		cQry += " AND CT2_FILIAL = '" + xFilial("CT2") + "'"
		cQry += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC"
		DbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAls , .T. , .F.)
		TcSetField(cAls, 'CT2_DATA', 'D') 
		(cAls)->(DBGotop())
		If (cAls)->(!EOF())
			DbSelectArea("CT2")
			CT2->(DbSetOrder(1)) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
			CT2->(DBGoTo((cAls)->R_E_C_N_O_))
			While CT2->(!Eof()) .And. ( CT2->( &cKeyCT2 ) == (cAls)->( &cKeyCT2 ) )  
				RecLock("CT2",.F.)
				CT2->CT2_UUID := cUUID
				MsUnLock()
				CT2->(DbSkip())
			EndDo
		EndIf
		(cAls)->(DBCloseArea())
	EndIf
	
	//Actualizacion UUID en tabla CTK
	If !Empty(cQryCTK)
		cQry := " SELECT CTK_FILIAL, CTK_DATA, CTK_SEQUEN, CTK_LP, CTK_UUID,"
		cQry += " CTK_KEY, CTK_UUID, R_E_C_N_O_ "
		cQry += " FROM " + RetSqlName("CTK")
		cQry += " WHERE (" + cQryCTK + ")"
		cQry += " AND D_E_L_E_T_ <> '*'"
		cQry += " AND CTK_FILIAL = '" + xFilial("CTK") + "'"
		cQry += " ORDER BY CTK_FILIAL, CTK_DATA, CTK_SEQUEN"
		DbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAls , .T. , .F.)
		TcSetField(cAls, 'CTK_DATA', 'D')  
		(cAls)->(DBGotop())
		If (cAls)->(!EOF())
			DbSelectArea("CTK")
			CTK->(DbSetOrder(3)) //CTK_FILIAL+DTOS(CTK_DATA)+CTK_SEQUEN
			CTK->(DBGoTo((cAls)->R_E_C_N_O_))
			While CTK->(!Eof()) .And. ( CTK->( &cKeyCTK ) == (cAls)->( &cKeyCTK ) )
				RecLock("CTK",.F.)
				CTK->CTK_UUID := cUUID
				MsUnLock()
				CTK->(DbSkip())
			EndDo
		EndIf
		(cAls)->(DBCloseArea())
	EndIf
	RestArea(aTmpCT2)
	RestArea(aTmpCTK)
Return

/*/{Protheus.doc} PesqFFCT5
//Valida si existen asientos estandar sin configuracion de Folio Fiscal en CT5
@author oscar.lopez
@since 11/07/2019
@version 1.0 
@param cCod, char, Codigo asiento
@type function
/*/
Function PesqFFCT5(cCod)
	Local cAls		:= GetNextAlias()
	Local nTotal	:= 0
	Local cQry		:= ""
	Local lRet		:= .T.
	
	Default cCod := ""
	
	If !Empty(cCod)
		cQry := " SELECT CT5_FILIAL, CT5_LANPAD, CT5_SEQUEN, CT5_UUID"
		cQry += " FROM " + RetSqlName("CT5")
		cQry += " WHERE CT5_FILIAL = '" + xFilial("CT5") + "' AND CT5_LANPAD = '" + cCod + "'"
		cQry += " AND CT5_UUID = '' AND CT5_STATUS = '1'  AND D_E_L_E_T_ <> '*'"
		DbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAls , .T. , .F.)
		Count To nTotal
		lRet := IIf (nTotal > 0, .T., .F.)
		(cAls)->(DBCloseArea())
	EndIf
Return lRet

/*/{Protheus.doc} ActBajaSE1
//Após processo de manutenção na movimentação (SE5), atualizar a data da baixa do título.
@author oscar.lopez
@since 15/02/21
@version 1.0 
@param cChaveSE1, char, Llave a buscar en SE1
@type function
/*/
Function ActBajaSE1(cChaveSE1)
	Default cChaveSE1 := ""
	
	// Sel070Baixa() - Preenche a variavel aBaixaSE5 com as possiveis baixas do titulo atual
	If SE1->(MsSeek(cChaveSE1))
		If cPaisLoc $ "PER|MEX|COL"
			SE1->(Sel070Baixa( "VL /V2 /BA /CP /LJ /" + MV_CRNEG,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,,,E1_CLIENTE,E1_LOJA,,,,,,.T.))
		Else
			SE1->(Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,,,E1_CLIENTE,E1_LOJA,,,,,,.T.))
		EndIF
	EndIf
	// Se houver outras baixas mantem, no titulo, a data da última.
	If !Empty(aBaixaSE5)
		RecLock("SE1",.F.)
		E1_BAIXA := Atail(aBaixaSE5)[7]
		SE1->(MSUnLock())
		aBaixaSE5 := {}
	EndIf
Return

/*/{Protheus.doc} fa088Env
Función que prepara el envío de los recibos de cobro por correo.
@type
@author eduardo.manriquez
@since 20/04/2021
@version 1.0
@param cAlias, caracter,Alias Actual Utilizado tabla Temporal
@param nReg, numérico,  Número de Registro
@param nOpcx, numérico, opcion del MenuDef 
@return 
@example
fa088Env(cAlias,nReg,nOpcx)
@see (links_or_references)
/*/
Function fa088Env(cAlias,nReg,nOpcx)
	Local cSaltoL  := Chr(10)+ Chr(13)
	Local cCod	   := ""
	Local cMSg 	   := ""
	Local aRegPro  := {}
	Local nMark    := 0
	Local oMark    := GetMarkBrow()
	Local nImpAuto := SuperGetMv("MV_CFDREC",.T.,0) //Generacion automatica complemneto de pago
	Local cAvisoE  := ""
	Local lHora := SEL->(ColumnPos("EL_HORA")) > 0
	Local cMensaje := ""
	Local nI       := 0
	Local cMsjEnv  := ""
	Local lVldMsj  := .F.

	Private nContT	:= 0
	Private nRegE	:= 0
	Private aRegEnv := {}
	Private nContEnv:= 0
	Private lEnvEmail:= .T.

	If cPaisLoc == "MEX" .and. nOpcx == 8 .and. ValParam() .and. (nImpAuto == 0 .or. nImpAuto == 1 .or. nImpAuto == 3 .or. nImpAuto == 4)
		SEL->(DbSelectArea("SEL"))
		SEL->(DbSetOrder(8))	//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
		TRB->(DbSelectArea("TRB"))
		TRB->(DbGoTop())
		cCod:= PADR( "RA",TamSx3("EL_TIPODOC")[1]," ")
		While TRB->(!EOF())
			If IsMArk("MARK",cMarcaTR,lInverte)
				If !Empty(TRB->UUID) .And. !Empty(TRB->FECTIMB) // Si el recibo no ha sido timbrado , no permite le envío
					nMark++
					If lHora
						aAdd(aRegPro, {TRB->NUMERO,TRB->SERIE,TRB->EMISION,TRB->HORA})
					Else
						aAdd(aRegPro, {TRB->NUMERO,TRB->SERIE})
					EndIf	
				Else
					If Empty(TRB->CANCELADA) .Or. Empty(TRB->PODE) .Or. Empty(TRB->UUID)		
						cAvisoE += IIf(!Empty(TRB->SERIE), Alltrim(TRB->SERIE) + "-" + TRB->NUMERO + space(1), + TRB->NUMERO) + cSaltoL //"Agrega recibo."
					EndIf				
					RecLocK("TRB")
					TRB->MARK := ""
					TRB->(MsUnlock())
				EndIf
			EndIf
			TRB->(DbSkip())
			DbSelectArea("TRB")
		EndDo

		SEL->(DbCloseArea())
		
		If !Empty(cAvisoE)
			cAvisoE := STR0145 + cSaltoL+ STR0146 +cSaltoL+ cAvisoE //Solo es posible enviar recibos timbrados." "Realice el timbrado de los siguientes recibos para poder envíarlos:
			MsgInfo(cAvisoE , STR0059)//"Atención 
		Else
			If nMark > 0
				lEnvEmail := MSGYESNO( STR0140 + CRLF + CRLF+STR0152, STR0139 ) // ¿Desea realizar el envío por correo del Complemento de recepción de pago?" - "Envío del Complemento de recepción de pagos"
				If lEnvEmail
						Processa( {|lEnd| fa088Email(aRegPro)},STR0092 ,STR0093 , .T. )//"Aguarde..."//"Procesando."
						ImprimeLog(aRegEnv)
						aRegEnv := {}
						oMark:oBrowse:Refresh()
				EndIf  
			Else 	
				MSGALERT(STR0096 , STR0143)//"No hay Recibos seleccionados"//"Timbrado"
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} fa088Email
Función que procesa el envío de los recibos de cobro seleccionados.
@type
@author eduardo.manriquez
@since 20/04/2021
@version 1.0
@param aRegPro, array, Recibos diferentes a RA
@return 
@example
fa088Email(aRegPro)
@see (links_or_references)
/*/
Function fa088Email(aRegPro)
	Local nI 	    := 0
	Local nReg	    := 0
	Local aInfoCli  := {}
	Local cEmailCli := ""
	Local cPath		:= GETMV("MV_CFDRECP",.F.,"GetSrvProfString('startpath','')+'\cfd\recPagos\'" )
	Local lEnvOk    := .F.
	Local aFilesEnv := {}
	Local cXML      := ""
	Local cPDF      := ""
	Local lExistXml := .T.
	Local lExistPdf := .T.
	Local cMsjError := ""
	Local cMsjCli	:= ""

	nReg := Len(aRegPro)
	ProcRegua(nReg)

	For nI := 1 to  nReg
		lEnvOk := .F.
		IncProc(STR0151+aRegPro[nI][1])//"Enviando Recibo: "
		cNumero := aRegPro[nI][1]
		cSerie  := aRegPro[nI][2]
		aInfoCli  := ObtClient(cNumero,cSerie)
		cEmailCli := ObtEmail(aInfoCli[1],aInfoCli[2])
		cXML :=OemToAnsi(STR0144) + Alltrim(cSerie) + Alltrim(cNumero)  + ".xml" // ReciboPago 
		cPDF := OemToAnsi(STR0144) + Alltrim(cSerie) + Alltrim(cNumero)  + ".pdf" // ReciboPago
		
		If FILE(&(cPath) + cXML)
			aadd(aFilesEnv,&(cPath) + cXML)
		Else
			cMsjError+= STR0148+space(1) +cXML+space(1) // "Archivo XML" - "no encontrado en directorio:"
			lExistXml := .F.
		Endif
		If FILE(&(cPath) + cPDF)
			aadd(aFilesEnv,&(cPath) + cPDF)
		Else
			cMsjError+= STR0148+space(1) +cPDF+space(1) // "Archivo PDF" - "no encontrado en directorio:"
			lExistPdf := .F.
		Endif

		if Empty(cEmailCli) 
			cMsjCli := STR0153 + space(1)+STR0154
		Endif

		if lExistXml .and. lExistPdf
			if Empty(cMsjCli) 
				lEnvOk := EnvRecMail(cEmailCli,aFilesEnv)		
			EndIf
			If lEnvOk
				nContEnv++
			Endif

		EndIf
		If !Empty(cMsjError) 
			cMsjError := STR0150 +&(cPath)+ space(1)+cMsjError
		Endif
		If !Empty(cMsjCli) 
			cMsjError := cMsjCli + space(1)+cMsjError
		Endif
		AADD(aRegEnv, {cNumero,cSerie, .T.,lEnvOk,cMsjError,aInfoCli[1],aInfoCli[2]})
		lExistPdf := .T.
		lExistXml := .T.
		cMsjError := ""
		cMsjCli   := ""
		aFilesEnv := {}
	Next

Return

/*/{Protheus.doc} ImprimeLog
Función que se encarga de generar archivo log de proceso de envío.
@type
@author eduardo.manriquez
@since 23/04/2021
@version 1.0
@param aRegEnv , Array, Arreglo que contiene los recibos procesados.
@return Nil
@example
ImprimeLog(aRegEnv)
@see (links_or_references)
/*/
Function ImprimeLog(aRegEnv)
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Local cTamanho	:= "G"
	Local cTitulo	:= STR0143	//"Envío por Email."
	Local aLogTitle	:= Array(2)	
	Local aLog	:= {}
	Local nLenDoc	:= Len(SEL->(EL_RECIBO)) + 4
	Local nLenSer   := Len(SEL->(EL_SERIE)) + 4
	Local nLenCte	:= Len(SEL->(EL_CLIENTE)) + 5
	Local nLenTda	:= Len(SEL->(EL_LOJA)) + 6
	Local nI		:= 1

	aLogTitle[1] := PadR(STR0023,nLenSer)+PadR(STR0024,nLenDoc)+PadR(STR0050,nLenCte)+PadR(STR0003,nLenTda)+STR0156	//"Recibo" # "Cliente" # "Mensaje"
	aLogTitle[2] := STR0162	//"Resumen del proceso de envío de Complemento de recepción de pago" 
	
	aAdd( aLog, {})

	For nI := 1 to Len(aRegEnv)
		aAdd( aLog[1],aRegEnv[nI][2] + space(4)+aRegEnv[nI][1] + space(4)+aRegEnv[nI][6]+ space(5)+aRegEnv[nI][7]+ space(4))// "Serie" - "Numero" -"Cliente"-"Tienda"-"Detalles"
		If aRegEnv[nI][4] //Envío exitoso
			aLog[1][Len(aLog[1])] += STR0149 //"Recibo enviado correctamente."
		Else
			If !Empty(aRegEnv[nI][5]) //Validaciones correo cliente o existen archivos XML y PDF.
				aLog[1][Len(aLog[1])] += aRegEnv[nI][5]
			ElseIf aRegEnv[nI][3] //Documento Timbrado
				aLog[1][Len(aLog[1])] += STR0164 //"Verifique configuración de parámetros para envío de correo."
			Else
				aLog[1][Len(aLog[1])] += STR0165 //"Error al timbrar el documento."
			EndIf
		EndIf
		
	Next nI
	aAdd( aLog, {})
	aAdd( aLog[2], "")
	aAdd( aLog[2], STR0163 + Str(Len(aRegEnv),5))	//"Total de documentos procesados: "
	
	/*
		1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
		2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
		3 -	cPerg		//Pergunte a Ser Listado
		4 -	lShowLog	//Se Havera "Display" de Tela
		5 -	cLogName	//Nome Alternativo do Log
		6 -	cTitulo		//Titulo Alternativo do Log
		7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
		8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
		9 -	aRet		//Array com a Mesma Estrutura do aReturn
		10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
	*/
	MsAguarde( { ||fMakeLog( aLog , aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn , .F. )}, STR0155) //"Generando Log de proceso..."	
Return Nil

/*/{Protheus.doc} ValParam
Función que se encarga de validar los parametros requeridos para el envío de correo.
@type
@author eduardo.manriquez
@since 23/04/2021
@version 1.0
@return lógico , Retorna .T. si los parametros de envío de correo estan configurados, de lo contrario retorna .F.
@example
ValParam()
@see (links_or_references)
/*/
FUNCTION ValParam()
	Local cServer		:= GetMV("MV_RELSERV",,"" ) //Nombre de servidor de envio de E-mail utilizado en los informes.
	Local cEmail		:= GetMV("MV_RELACNT",,"" ) //Cuenta a ser utilizada en el envio de E-Mail para los informes
	Local cPassword		:= GetMV("MV_RELPSW",,""  ) //Contrasena de cta. de E-mail para enviar informes
	Local cMsg          := ""

	If Empty(cServer)
		cMsg += STR0157 + STR0158 + CHR(13) + CHR(10) //"Configure parámetro " "MV_RELSERV" 
	EndIf
	If Empty(cEmail)
		cMsg += STR0157 + STR0159 + CHR(13) + CHR(10) //"Configure parámetro " "MV_RELACNT"
	EndIf
	If Empty(cPassword)
		cMsg += STR0157 + STR0160 + CHR(13) + CHR(10) // "Configure parámetro " "MV_RELPSW"
	EndIf

	if !Empty(cMsg)
		ApMsgInfo(cMsg, STR0161) //"Configuración"
		Return .F.
	Endif

Return .T.

/*/{Protheus.doc} LibMetric
Funcion utilizada para validar la fecha de la LIB para ser utilizada en Telemetria.

@type       Function
@author     oscar.lopez
@since      25/11/2021
@version    1.0
@return     lMetric, lógico, Retorna .T. si la LIB puede ser utilizada para Telemetria.
/*/
Static Function LibMetric()
	Local lMetric := .F.

	lMetric := (FindClass('FWCustomMetrics') .And. (FWLibVersion() >= "20210517"))

Return lMetric

/*/{Protheus.doc} F88VisCanc
//Ventana para selección de Motivo de cancelación
@type function
@author luis.enriquez
@since 02/02/2022
@version 1.0
@return aRet, array, Arreglo con motivo de cancelacion y folio que sustituye
/*/
Function F88VisCanc(cSerRec, cNoRec, cUUIDRec, cMtCanR)
	Local aArea		:= GetArea()
	Local aItems	:= {}
	Local cCpoVal	:= "X3_CBOX"
	Local cConVal	:= ""
	Local cIdiom	:= FwRetIdiom()
	Local lRet		:= .F.
	Local oDlg		:= Nil
	Local oSay		:= Nil
	Local cMotCanc	:= TRB->EL_TIPAGRO //Motivo de Cancelación
	Local cFolRec	:= ""

	Default cSerRec := ""
	Default cNoRec := ""
	Default cUUIDRec := ""

	cFolRec	:= Alltrim(cSerRec) + "/" + AllTrim(cNoRec)
	cMtCanR := ""

	If cIdiom $ 'en|ru'
		cCpoVal += "ENG"
	ElseIf cIdiom == 'es'
		cCpoVal += "SPA"
	EndIf

	cConVal	:= GetSX3Cache("EL_TIPAGRO", cCpoVal)
	aItems	:= STRTOKARR(cConVal, ";")

	DEFINE DIALOG oDlg TITLE STR0170 FROM 180,180 TO 353,600 PIXEL //"Motivo de Cancelación"

		@ 010,010 SAY oSay PROMPT STR0171 RIGHT SIZE 065,011 OF oDlg PIXEL //"Folio Recibo"
		@ 010,080 SAY oSay PROMPT cFolRec SIZE 120,011 OF oDlg PIXEL

		@ 025,010 SAY oSay PROMPT STR0172 RIGHT SIZE 065,011 OF oDlg PIXEL //"UUID:"
		@ 025,080 SAY oSay PROMPT AllTrim(cUUIDRec) SIZE 120,011 OF oDlg PIXEL

		@ 041,010 SAY oSay PROMPT STR0173 RIGHT SIZE 065,011 OF oDlg PIXEL //"Motivo cancelación:"
		oCombo1 := TComboBox():New(040,080,{|u| If(PCount()>0,cMotCanc:=u,cMotCanc)},aItems,120,011,oDlg,,;
								Nil,,,,.T.,,,,,,,,,'cMotCanc')

		@ 058,135 BUTTON STR0174 SIZE 030, 011 PIXEL OF oDlg ACTION (lRet := .T., IIf(lRet,oDlg:End(),)) //"Confirmar"
		@ 058,170 BUTTON STR0175 SIZE 030, 011 PIXEL OF oDlg ACTION (lRet := .F., oDlg:End()) //"Salir"

	ACTIVATE DIALOG oDlg CENTERED

	If lRet
		cMtCanR := cMotCanc
		RecLock("SEL", .F.)
		SEL->EL_TIPAGRO	:= cMotCanc
		SEL->(MsUnlock())
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} F088ActTRB
Actualiza estatus en tabla temporal para cancelación
@type function
@author luis.enriquez
@since 23/02/2022
@version 1.0
@param cSerSus, caracter, Serie el Recibo cancelado.
@param cRecSus, caracter, Folio de Recibo cancelado.
/*/
Static Function F088ActTRB(cSerSus,cRecSus)
	Local aTRBArea := TRB->(GetArea())
	Local aSELArea := SEL->(GetArea())

	TRB->(DbSelectArea("TRB"))
	TRB->(DbSetOrder(1)) //"SERIE + NUMERO"
	If TRB->(DbSeek(cSerSus + cRecSus))
		RecLock("TRB",.f.)
		TRB->CANCELADA 	:= "Si"
		TRB->(MsUnLock())
	EndIf

	DbSelectArea("SEL")
	SEL->(DbSetOrder(8))//EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If SEL->(DbSeek(xFilial("SEL")+ cSerSus + cRecSus))
		RecLock("SEL",.F.)				
		SEL->EL_RETGAN := ""
		SEL->(MsUnLock())	
	EndIf
	RestArea(aTRBArea)
	RestArea(aSELArea)
Return Nil

/*/{Protheus.doc} F088TIMBRE
Obtiene motivo de Cancelación del Cobro Diverso
@type function
@author luis.enriquez
@since 23/02/2022
@version 1.0
@param cSerSus, caracter, Serie el Recibo cancelado.
@param cRecSus, caracter, Folio de Recibo cancelado.
@param lSerRec, lógico, .T. se utiliza serie para recibo en caso contrario .F..
@param cRecTimb, caracter, Serie el Recibo que Sustituye.
@param UUIDRec, caracter, Folio de Recibo que Sustituye.
/*/
Function F088TIMBRE(cSerSEL, cRecSEL, lSerRec, cRecTimb, UUIDRec)
	Local cAliasSEL := getNextAlias()
	Local nCount    := 0
	Local lExiste   := .F.

	Default cSerSEL  := ""
	Default cRecSEL  := ""
	Default lSerRec  := .F.
	Default cRecTimb := ""
	Default UUIDRec  := ""

	BeginSql alias cAliasSEL
		SELECT EL_SERIE, EL_RECIBO, EL_UUID
		FROM %table:SEL% SEL
		WHERE SEL.EL_FILIAL = %xFilial:SEL% 
		AND EL_SERSUS = %exp:cSerSEL% 
		AND EL_RECSUS = %exp:cRecSEL% 
		AND EL_UUID <> ''
		AND EL_FECTIMB <> ''
		AND SEL.%notDel%
	EndSql

	count to nCount

	If nCount > 0
		lExiste := .T.
		dbSelectArea(cAliasSEL)
		(cAliasSEL)->(dbGoTop())

		While (cAliasSEL)->(!Eof())
			cRecTimb := IIf(lSerRec,Alltrim((cAliasSEL)->EL_SERIE) + "-","") + Alltrim((cAliasSEL)->EL_RECIBO)
			UUIDRec := Alltrim((cAliasSEL)->EL_UUID)
			(cAliasSEL)->(dBSkip())
		EndDo
	EndIf

	If Select(cAliasSEL) > 0
		(cAliasSEL)->(dbCloseArea())
	EndIf
Return lExiste

/*/{Protheus.doc} F088UPDCAN
Función que actualiza estatus de recibo al realizar la cancelación SEL->EL_RETGAN vacío
@type function
@author luis.enriquez
@since 25/03/2022
@version 1.0
@param cSerSus, caracter, Serie el Recibo cancelado.
@param cRecSus, caracter, Folio de Recibo cancelado.
/*/
Static Function F088UPDCAN(cSerSus,cRecSus)
	Local aSELArea := SEL->(GetArea())
	Local cFilSEL  := xFilial("SEL")
	
	Default cSerSus := ""
	Default cRecSus := ""

	DbSelectArea("SEL")
	SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	SEL->(DbSeek(xFilial("SEL") + cSerSus + cRecSus))
	While !(SEL->(EOF())) .And. SEL->(EL_FILIAL + EL_SERIE + EL_RECIBO) == (cFilSEL + cSerSus + cRecSus)
		RecLock("SEL",.F.)
		SEL->EL_RETGAN := ""
		SEL->(MsUnLock())
		SEL->(DbSkip())
	EndDo
	RestArea(aSELArea)
Return Nil


/*/{Protheus.doc} ExpRot088
	Apresenta uma tela informando que a rotina sera descontinuada
	@type  Function
	@author josé Gonzalez
	@since 30/03/2022
	@version 1.0
	@param cExpirFunc, caracter, nombre de la rutina a interrumpir
	@param cDescrFunc, caracter, descricaod a rotina e nome da rotina que substitui a rotina descontinuada
	@param cExpiraData, caracter, La fecha de la experiencia para ser informado debe estar en formato AAAAMMDD
	@param cEndWeb, caracter, dirección http que hace referencia a la rutina que se está descontinuando
/*/
Static Function ExpRot088(cExpirFunc as character, cDescrFunc as character, cEndWeb as character, cExpiraData as character, nPauseDays as numeric, cBlocData as character)
Local dDate      as date
Local oProfile   as object
Local aLoad      as array
Local cShow      as character
Local lCheck     as logical


//Fecha de caducidad de rutina
DEFAULT cExpiraData := "20230701"

// número de días que el mensaje puede ser deshabilitado
DEFAULT nPauseDays := 30

//Fecha a partir de la cual se bloquea la rutina
Default cBlocData := '20230701'

dDate := dDataBase
oProfile := FwProFile():New()
oProfile:SetTask("ESTExpired") //nombre de la sesión
oProfile:SetType(cExpirFunc) //Valor
aLoad := oProfile:Load()
If Empty(aLoad)
	cShow := "00000000"
Else
	cShow := aLoad[1]
Endif

// restablece el control de nPauseDays días y vuelve a mostrar la pantalla de advertencia
If cShow <> "00000000" .and. STOD(cShow) + nPauseDays <= dDate
	cShow := "00000000"
	oProfile:SetProfile({cShow})
	oProfile:Save()
ENDIF

If cShow == "00000000"
	lCheck := DlgExp088(cExpiraData, nPauseDays, cDescrFunc, cEndWeb, cBlocData)

	If lCheck
		cShow := dtos(dDataBase)	
		oProfile:SetProfile({cShow})
		oProfile:Save()
	EndIf

EndIf

oProfile:Destroy()
oProfile := nil
aLoad := aSize(aLoad,0)
aLoad := nil

RETURN


/*/{Protheus.doc} DlgExp088
	Presenta la pantalla de una rutina que será descontinuada
	@type  Function
	@author Jose Gonzalez
	@since 17/03/2022
	@version 1.0
	@param cExpiraData, caracter, La fecha de la experiencia para ser informado debe estar en formato AAAAMMDD
	@param nPauseDays, numeric, número de días que se puede ocultar el mensaje
	@param cDescrFunc, caracter, descripción de la rutina y nombre de la rutina que reemplaza a la rutina descontinuada
	@param cEndWeb, caracter, dirección http que hace referencia a la rutina que se está descontinuando
	@return lCheck, logico, Verdadero si elige deshabilitar el mensaje durante 30 días
/*/
Static Function DlgExp088(cExpiraData as character, nPauseDays as numeric, cDescrFunc as character, cEndWeb as character, cBlocData as character)
local oSay1    as object
local oSay2    as object
local oSay3    as object
local oSay4    as object
local oCheck1  as object
local oModal   as object
Local cMsg1    as character
Local cMsg2    as character
Local cMsg3    as character
Local cMsg4    as character

Local cRelease as character
Local lCheck   as logical

cRelease := GetRPORelease() 

oModal := FWDialogModal():New()
oModal:SetCloseButton( .F. )
oModal:SetEscClose( .F. )
oModal:setTitle(STR0179) //"Comunicado Ciclo de Vida de Sofware - TOTVS Linha Protheus"

//establece la altura y el ancho de la ventana en píxeles
oModal:setSize(180, 250)

oModal:createDialog()

oModal:AddButton( STR0174, {||oModal:DeActivate()}, STR0174, , .T., .F., .T., ) //"Confirmar"

oContainer := TPanel():New( ,,, oModal:getPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT
If DToS(dDataBase) < cExpiraData
	cMsg1 := i18n(STR0180 ,{cValToChar(stod(cExpiraData))}) // ""Esta rutina se descontinuará el #1[01/07/2023]#.
EndIf

cMsg2 := i18n(STR0181, {cDescrFunc} ) //"La rutina que la sustituirá es la de TOTVS Recibo (FINA998), ya disponible en nuestro producto desde la versión 12.1.2210."
cMsg4 :=  STR0182//"Para más información, por favor entre en contacto con el administrador del sistema o su ESN TOTVS."

oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

oSay2 := TSay():New( 30,10,{||cMsg2 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

cMsg3 := Alltrim(STR0183 )+space(01) //"Para conocer más sobre la convergencia entre estas rutinas,"
If ! Empty(cEndWeb)
	cMsg3 += "<b><a target='_blank' href='"+cEndWeb+"'> "
	cMsg3 += Alltrim(STR0184) // "haga clic aquí"
	cMsg3 += " </a></b>."
	cMsg3 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
	oSay3 := TSay():New(50,10,{||cMsg3},oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
	oSay3:bLClicked := {|| MsgRun( STR0185, "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } // "Abriendo el enlace... Espere..."
EndIf
oSay4 := TSay():New( 70,10,{||cMsg4 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

lCheck := .F.
oCheck1 := TCheckBox():New(90,10,i18n( STR0186 ,{strzero(nPauseDays,2)}) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,21,,,,,,,,.T.,,,) // "No presentar este mensaje en los próximos #1[30]# días."

oModal:Activate()

Return lCheck
