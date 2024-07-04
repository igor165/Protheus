#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'

/*/{Protheus.doc} EECDU010()
   (long_description)
   @type  Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return returno,return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/

Function EK5SXB(cNCM)

Local aRotOld     := aClone(aRotina)
Local bValid      := {|| xEK5Valid() }
Local bInit   		:= {|| xMarkinit() }
Local bMark       := {|| xBMark() }

Private oMarkBrow,oDlgMrk,oDU010
Private cTitulo     := OemToAnsi("Destaques NCM - " + cNCM)
Public __xcRet  := ""

aRotina   := MenuDef()

   aAlias 		:= DU010QRY(cNCM)	
   cAliasMrk	:= aAlias[1]
   aColumns 	:= aAlias[2]

If !(cAliasMrk)->(Eof())

  oSize:= FWDefSize():New(.T.)
  oSize:lLateral := .T. 
  oSize:AddObject( "mark1" , 100, 100, .T., .T. )
  oSize:Process()
  
   DEFINE MSDIALOG oDlgMrk TITLE cTitulo FROM oSize:aWindSize[2], oSize:aWindSize[1] ;
							TO oSize:aWindSize[3] / 2, oSize:aWindSize[4] / 2 ;
							OF oMainWnd PIXEL
	
		oMarkBrow:= FWMarkBrowse():New()
		oMarkBrow:SetOwner(oDlgMrk)
		oMarkBrow:SetDescription( cTitulo )
		oMarkBrow:SetAlias( cAliasMrk )
		oMarkBrow:SetFieldMark( "EK5_OK" )
		oMarkBrow:SetMark( "W1" , cAliasMrk , "EK5_OK" )
		oMarkBrow:SetTemporary(.T.)
		oMarkBrow:SetColumns(aColumns)
		oMarkBrow:SetWalkThru(.F.)
		oMarkBrow:SetAmbiente(.F.) 
		oMarkBrow:DisableReport(.T.)
		oMarkBrow:ForceQuitButton(.T.)
		oMarkBrow:SetAllMark(bMark)
		oMarkBrow:SetValid(bValid)
		oMarkBrow:SetIniWindow( bInit )
		oMarkBrow:Refresh(.T.)
		oMarkBrow:Activate()
		xMarkinit()

   ACTIVATE MSDIALOG oDlgMrk CENTERED
Else
   Help(" ",1,"RECNO")
EndIf

If oDU010 <> Nil
	oDU010:Delete()
	oDU010 := Nil
Endif

aRotina := aClone(aRotOld)

Return !empty(__xcRet)

/*---------------------------------------------------------------------*
 | Func:  xMarkinit                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Seleciona os processos com status 2 - aguardando geração e   |
 | monta tabela temporária a ser usada no mark browse                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function xMarkinit()
Local cDestaq		:= M->EYJ_DESEXP
Local cAliasEK5	:= oMarkBrow:Alias()
Local aAux		:= {}
Local lSai		:= .F.

While ! lSai 

	if ! Empty(cDestaq)
		aadd( aAux , {substr( cDestaq , 1 , 3 )} )
		cDestaq := substr( cDestaq , 4 , len(cDestaq)  )
	Else
		lSai := .T.
	EndIf

EndDo

lSai		:= .F.
oMarkBrow:GoBottom()
cLast := (cAliasEK5)->EK5_FILIAL + (cAliasEK5)->EK5_NCM + (cAliasEK5)->EK5_DESTAQ
oMarkBrow:GoTop()

While ! lSai
	
	If aScan( aAux , { |x| x[1] == (cAliasEK5)->EK5_DESTAQ } ) > 0
	   oMarkBrow:MarkRec()
	EndIf    
	if cLast == (cAliasEK5)->EK5_FILIAL + (cAliasEK5)->EK5_NCM + (cAliasEK5)->EK5_DESTAQ
	   lSai := .T.
	End
	oMarkBrow:GoDown(1)

EndDo

oMarkBrow:Refresh(.T.)

Return
/*---------------------------------------------------------------------*
 | Func:  xBMark                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Seleciona os processos com status 2 - aguardando geração e   |
 | monta tabela temporária a ser usada no mark browse                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function xBMark()
Local cAliasEK5 := oMarkBrow:Alias()
Local lSai := .F.
Local lMarca := ! oMarkBrow:IsMark()

oMarkBrow:GoBottom()
cLast := (cAliasEK5)->EK5_FILIAL + (cAliasEK5)->EK5_NCM + (cAliasEK5)->EK5_DESTAQ
oMarkBrow:GoTop()

While ! lSai
	if lMarca .and. ! oMarkBrow:IsMark()
		oMarkBrow:MarkRec()
	elseif  ! lMarca .and. oMarkBrow:IsMark()
		oMarkBrow:MarkRec()
	EndIf   
	if cLast == (cAliasEK5)->EK5_FILIAL + (cAliasEK5)->EK5_NCM + (cAliasEK5)->EK5_DESTAQ
	   lSai := .T.
	End
oMarkBrow:GoDown(1)
EndDo

oMarkBrow:Refresh(.T.)

Return
/*---------------------------------------------------------------------*
 | Func:  xEK5Valid                                                    |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Seleciona os processos com status 2 - aguardando geração e   |
 | monta tabela temporária a ser usada no mark browse                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function xEK5Valid()

Local lRet  := .T.
Local cAliasEK5 := oMarkBrow:Alias()
Local nK := 0
Local nRecno   := (cAliasEK5)->( recno() )

(cAliasEK5)->( dbgotop() )
(cAliasEK5)->( DBEval( {|| iif( ! empty( (cAliasEK5)->EK5_OK ) , nK++ , ) } ) )
(cAliasEK5)->( dbgoto(nRecno) )

If empty( (cAliasEK5)->EK5_OK )
   if nK = 10
		lRet := .F.
   Endif
Endif

Return lRet
/*---------------------------------------------------------------------*
 | Func:  DU010QRY                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Seleciona os processos com status 2 - aguardando geração e   |
 | monta tabela temporária a ser usada no mark browse                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function DU010QRY(cNCM)
Local aArea			:= GetArea()			
Local aStru			:= EK5->(DBSTRUCT())	//Estrutura da Tabela
Local aColumns		:= {}					   //Array com as colunas a serem apresentadas

Local nX			:= 0					
Local cArqTrab		:= ""					
Local cQuery		:= ""

cQuery += "SELECT * "
cQuery += ", R_E_C_N_O_ RECNO "
cQuery += " FROM "+	RetSqlName("EK5") + " 
cQuery += " WHERE EK5_FILIAL = '"+xFilial("EK5")+"' "
if cModulo $ "EEC"
	cQuery += " AND EK5_TIPO <> '1' "
elseif cModulo $ "EIC"
	cQuery += " AND EK5_TIPO <> '2' "
Endif
cQuery += " AND EK5_NCM = '"+cNCM+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY "+ SqlOrder(EK5->(IndexKey()))

Aadd(aStru, {"EK5_OK","C",2,0})
Aadd(aStru, {"RECNO","N",10,0})

If oDU010 <> Nil
	oDU010:Delete()
	oDU010 := Nil
Endif

//------------------
//Criação da tabela temporaria
//------------------
cArqTrab := GetNextAlias()
oDU010 := FWTemporaryTable():New( cArqTrab )  
oDU010:SetFields(aStru) 
oDU010:AddIndex("1", { "EK5_FILIAL","EK5_NCM","EK5_DESTAQ" })
oDU010:Create()  

// Cria arquivo temporario
Processa({||SqlToTrb(cQuery, aStru, cArqTrab)})
DbSetOrder(0) // Fica na ordem da query

//Define as colunas a serem apresentadas na markbrowse
For nX := 1 To Len(aStru)
	If	! aStru[nX][1] $ "EK5_FILIAL|EK5_OK|EK5_NCM|RECNO"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1])) 
		aColumns[Len(aColumns)]:SetSize(aStru[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
	   aColumns[Len(aColumns)]:SetPicture(PesqPict("EK5",aStru[nX][1]))
	EndIf 	
Next nX 

RestArea(aArea)

Return({cArqTrab,aColumns})
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Menu com as rotinas                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
    Local aRot := {}

    ADD OPTION aRot TITLE 'Gravar Destaques' ACTION 'GrvEK5()' OPERATION MODEL_OPERATION_INSERT ACCESS 0

Return aRot
/*---------------------------------------------------------------------*
 | Func:  GrvEK5                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Menu com as rotinas                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function GrvEK5()

Local cAliasEK5   := oMarkBrow:Alias()
Local nRecno      := (cAliasEK5)->( recno() )
Local nK          := 0
Local cRet        := ""
Local aRegs       := {}

(cAliasEK5)->( dbgotop() )
(cAliasEK5)->( DBEval( {|| iif( ! empty( (cAliasEK5)->EK5_OK ) , aadd( aRegs , { (cAliasEK5)->( recno() ) } ) , ) } ) )

if len(aRegs) > 0
	For nK := 1 to len(aRegs)
		(cAliasEK5)->( dbgoto(aRegs[nK][1]) )
		cRet += (cAliasEK5)->EK5_DESTAQ
	Next
	__xcRet := cRet
	oDlgMrk:End()
EndIf

Return
/*---------------------------------------------------------------------*
 | Func:  GrvEK5                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Menu com as rotinas                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function VldDesExp()
Local cDestaq	:= M->EYJ_DESEXP
Local cNCM		:= SB1->B1_POSIPI
Local cMsg		:= ""
Local aAux		:= {}
Local lSai		:= .F.
Local lRet		:= .T.
Local nX			:= 0

iF !empty(cDestaq) .and. !empty(cNCM)
	While ! lSai 
		if ! Empty(cDestaq)
			aadd( aAux , {substr( cDestaq , 1 , 3 )} )
			cDestaq := substr( cDestaq , 4 , len(cDestaq)  )
		Else
			lSai := .T.
		EndIf
	EndDo

	For nX := 1 to len(aAux)
		if ! EK5->( dbsetorder(1) , DbSeek( xFilial("EK5") + cNCM + aAux[nX][1] ) )
			if empty(cMsg)
				cMsg += "NCM - " + cNCM + CRLF
			Endif
			cMsg += "Destaque " +aAux[nX][1]+ " não existe para a NCM." + CRLF
		EndIf
	Next
	if ! empty(cMsg)
		cMsg += "Favor verificar o cadastro Destaque NCM."
	Endif
Endif

If ! empty(cMsg)
	MsgAlert( cMsg , "Destaque NCM" )
	lRet := .F.
Endif

Return lRet