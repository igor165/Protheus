# include "VDFM020.CH"
# INCLUDE "PROTHEUS.CH"
# INCLUDE "FWMBROWSE.CH"
# INCLUDE "FWMVCDEF.CH"
# INCLUDE "TOTVS.CH"

Static lTipMark 	:= .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VDFM020    ³ Autor ³ Totvs                    ³ Data ³ 19/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina para seleção dos atos.                                      ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivia F.      ³19/11/13³PRJ. M_RH001     ³-GSP- Rotina para seleção dos atos.         ³±± 
±±³              ³        ³REQ. 001851      ³                               	         ³±±
±±³Marcos .      ³26/02/14³PRJ. M_RH001     ³Ajuste da gravação do historico na tabela   ³±± 
±±³              ³        ³REQ. 001851      ³RI6 e REY.                     	         ³±±
±±³Tania Bronzeri³30/04/14³PRJ. M_RH001     ³-GSP- Rotina de envio de aviso para calculo ³±± 
±±³              ³        ³Gap.002094-16    ³quando publicação for de rescisão.          ³±±
±±³Marcos Pereira³15/10/14³PRJ. M_RH001     ³Alteracao no titulo da janela de reserva,   ³±± 
±±³              ³        ³                 ³pois estava apresentando como cancelamento  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFM020
Rotina para seleção dos atos.
@sample 	VDFM020()
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFM020()
Private oMark
Private _Doc
Private _Ano
Private lSubsTp 	:= "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

Private cDir       	:= SUBSTR(GetTempPath(),1,3)
Private cLogo      	:= GetMV( "MV_VDFLOGO" ) 
Private cDiretorio 	:= cDir+GetMV( "MV_VDFPAST" )

Private aFldRot 	:= {'RA_NOME','RA_NOMECMP'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F. 
Private lOfuscaCmp 	:= .F. 
Private aFldOfusca 	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOMECMP" } ) > 0
		lOfuscaCmp := FwProtectedDataUtil():IsFieldInList( "RA_NOMECMP" )
	ENDIF
EndIf

If Empty(cLogo) .or. Empty(cDiretorio)
   MsgInfo(STR0037,STR0038) //"Preencha os parametros: MV_VDFPAST e MV_VDFLOGO" // "Atenção"
   Return()
Endif

VDF_Direct( cDiretorio, cDir, .T. ) //Rotina para criar pasta.

If 	!File(cDir+'LibreOffice\program\swriter.exe')
   	MsgInfo(STR0043) //'LibreOffice não esta gravado na pasta \LibreOffice\program\.'
   	Return()
Endif

oMark:= FWMarkBrowse():New()
oMark:SetDescription( STR0095 ) //'Documentos já gerados'
oMark:SetAlias('RI5')
oMark:SetSemaphore(.T.)
oMark:SetFieldMark( 'RI5_OK' )
oMark:SetAllMark( { || oMark:AllMark() } )
oMark:AddLegend( "RI5_STATUS=='1'", "GREEN"  	, STR0044)  //"Automatico"
oMark:AddLegend( "RI5_STATUS=='2'", "Blue" 		, STR0045)  //"Manual"
oMark:AddLegend( "RI5_STATUS=='3'", "YELLOW"   	, STR0046)  //"Reservado"
oMark:AddLegend( "RI5_STATUS=='4'", "Red"    	, STR0047)  //"Cancelado"
oMark:AddButton( STR0028,{ || VD020ITEM('   ',.T.), oMark:Refresh(.T.) },,,, .F., 3 ) 	//'Gerar Novo Documento'
oMark:AddButton( STR0027,{ || VD020GDOC() },,,, .F., 2 ) 								// 'Abrir Documento'
oMark:AddButton( STR0029,{ || VD020Resv() , oMark:Refresh(.T.) },,,, .F., 4 )			//'Reservar número'
oMark:AddButton( STR0030,{ || VD020CmpR() , oMark:Refresh(.T.) },,,, .F., 5 )			//'Complementar Reserva'
oMark:AddButton( STR0061,{ || VD020Publc(), oMark:Refresh(.T.) },,,, .F., 7 )			//'Atualiza Data Publicação'
oMark:AddButton( STR0031,{ || VD020Canc() , oMark:Refresh(.T.) },,,, .F., 6 )			//'Cancelar documento'      
oMark:Activate()

Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Incluindo opção no Menu do browse.
@sample 	MenuDef()
@return	aRotina
@author	Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0098 ACTION 'PesqBrw'          	OPERATION 1 ACCESS 0 //"Pesquisar"

Return aRotina


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020Canc
Cancelar o Ato/Item
@sample 	VD020Canc()
@return	Nil
@author	Nivia Ferreira
@since		29/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020Canc()
Local aArea   	:= GetArea()
Local cMarca  	:= oMark:Mark()
Local cCont 	:= 0, lRet := .F.
Local bOk   	:= {||lRet:=.t.,oDlg:End()}
Local bCancel	:= {||oDlg:End()}, oDlg

RI5->( dbGoTop() )
While !RI5->( EOF() )
	
	If oMark:IsMark(cMarca)
		If RI5->RI5_STATUS =='3'
            MsgInfo(STR0001, '')		//'Ato não pode ser cancelado, tipo do documento foi reservado.'
		ElseIf RI5->RI5_STATUS =='4'
            MsgInfo(STR0002, '')		//'Ato já foi cancelado.'
		Else

			lRet := .F.
			Begin Sequence
			M->RI5_MOTCAN := Space(Len(RI5->RI5_MOTCAN))

			DEFINE MSDIALOG oDlg TITLE STR0048 + ' - [' +  RI5->RI5_ANO+'/' + RI5->RI5_NUMDOC + ']' FROM 0,0 TO 16,78 OF oMainWnd//'Cancelamento do Documento'

			@ 045,005 SAY STR0089 PIXEL  //'Motivo" 
			@ 060,005 MSGET M->RI5_MOTCAN Picture "@!" OF oDlg Pixel 	     	  

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

			End Sequence
		
			If 	lRet
				Begin Transaction
				VDF020RI6()
					
				dbSelectArea("RI6")
				DbSetOrder(2)
				RI6->(DbSeek(FWXFILIAL("RI6")+RI5->RI5_ANO+RI5->RI5_NUMDOC+RI5->RI5_TIPDOC))
				While !RI6->( EOF() ) .AND. RI5->RI5_ANO=RI6->RI6_ANO .AND. RI5->RI5_NUMDOC=RI6->RI6_NUMDOC .AND. RI5->RI5_TIPDOC=RI6->RI6_TIPDOC
					If RI6->RI6_STATUS<>'4' 
						cCont++
					EndIf
					RI6->( dbSkip() )
				End
			
				If	cCont == 0 
					RecLock("RI5",.F.)
					RI5->RI5_STATUS := '4'
					RI5->RI5_DTCANC := date()
					RI5->RI5_MOTCAN := M->RI5_MOTCAN 
					RI5->RI5_OK      := ''
					RI5->(MsUnlock())
				Endif			
				End Transaction
			Endif
		Endif
	Endif
	
	RI5->( dbSkip() )
End

RestArea( aArea )
Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF020RI6
Monta a MarkBrowse da tabela RI6 para cancelar
@sample 	VDF020RI6()
@author	Nivia Ferreira
@since		27/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF020RI6()
Local aArea		:= GetArea()
Local oMark1   

DbSelectArea("RI6")
RI6->(dbSetOrder(5))

oMark1 := FWMarkBrowse():New()
oMark1:SetAlias('RI6')
oMark1:SetOnlyFields( { 'RI6_MAT','RI6_NOME','RI6_CPF','RI6_CLASTP','RI6_DESCLA' } )
oMark1:SetSemaphore(.T.)
oMark1:AddLegend( "RI6_STATUS=='1'", "GREEN"  , STR0044)  //"Automatico"
oMark1:AddLegend( "RI6_STATUS=='2'", "YELLOW" , STR0045)  //"Manual"
oMark1:AddLegend( "RI6_STATUS=='3'", "Blue"   , STR0046)  //"Reservado"
oMark1:AddLegend( "RI6_STATUS=='4'", "Red"    , STR0047)  //"Cancelado"
oMark1:SetDescription(STR0049 +RI5->RI5_NUMDOC +'/'+ RI5->RI5_ANO) //Doc/Ano:
oMark1:SetFieldMark( 'RI6_OK' )
oMark1:SetAllMark( { || oMark1:AllMark() } )
oMark1:SetFilterDefault( "RI6->RI6_STATUS <> '4' .And. RI5->RI5_ANO=RI6->RI6_ANO .AND. RI5->RI5_NUMDOC=RI6->RI6_NUMDOC .AND. RI5->RI5_TIPDOC=RI6->RI6_TIPDOC")
oMark1:AddButton(STR0050 , { || VD020EXCL(oMark1),oMark1:Refresh(.T.)},,,, .F., 7 ) //"Confirma"
oMark1:Activate()

RestArea( aArea )

Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020EXCL
Cancela RI6 e RI5.
@sample 	VD210EDIT()
@return	Nil
@author	Nivia Ferreira
@since		28/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020EXCL(oMark1)
Local aArea     := GetArea()
Local cMarca   := oMark1:Mark()
Static cUserL	 := __cUserID

RI6->( dbGoTop() )
While !RI6->( EOF() )
	
	If oMark1:IsMark(cMarca)
		RecLock("RI6",.F.)
		RI6_STATUS := '4'
		RI6_DTCANC := date()
		RI6_USCANC := cUserL
		RI6_OK     := ' '
		RI6->(MsUnlock())
	Endif
	
	RI6->( dbSkip() )
End
				
RestArea( aArea ) 
oMark1:Refresh(.T.)
Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020GDOC
Gera arquivo .doc
@sample 	VD020GDOC()
@return	Nil
@author	Nivia Ferreira
@since		29/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020GDOC()
Local aArea    := GetArea()
Local cMarca   := oMark:Mark()
Local cTexto   := ''

RI5->( dbGoTop() )
While !RI5->( EOF() )
	
	If RI5->RI5_STATUS <> '4'
		If oMark:IsMark(cMarca)
			
			dbSelectArea("RI6")
			DbSetOrder(2)
			DbSeek(FWXFILIAL("RI6")+RI5->RI5_ANO+RI5->RI5_NUMDOC+RI5->RI5_TIPDOC)
			
			While !RI6->(EOF()) .AND. RI5->RI5_ANO=RI6->RI6_ANO .AND. RI5->RI5_NUMDOC=RI6->RI6_NUMDOC .AND. RI5->RI5_TIPDOC=RI6->RI6_TIPDOC
				If !Empty(RI6->RI6_TXTITE)
					cTexto := cTexto+ RI6->RI6_TXTITE
				Else
					cTexto := cTexto+ RI6->RI6_TXTHIS
				Endif	
				RI6->( dbSkip() )
			End
			
			VD020GeraDc(RI5->RI5_TXTCAB,cTexto,RI5->RI5_TXTROD,Alltrim(RI5->RI5_NUMDOC),RI5->RI5_ANO,RI5->RI5_TIPDOC)
			RecLock("RI5",.F.)
			RI5_OK     := ''
			RI5->(MsUnlock())

		Endif
	Endif

	RI5->( dbSkip() )
End

RestArea( aArea ) 
oMark:Refresh(.T.)
Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020Resv
Gera do ato tipo reservado
@sample 	VD020Resv()
@return	Nil
@author	Nivia Ferreira
@since		01/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020Resv()
Local aArea  	:= GetArea()
Local lRet   	:= .F.
Local bOk     	:= {||lRet:=.t.,oDlg:End()}
Local bCancel 	:= {||oDlg:End()}
Local oDlg  
Local oGet1
Local cDepto	:= Space(TAMSX3("QB_DEPTO")[1])
Local dDataAtu	:= date()

Private cTpdoc 	:= Space(03)
Private cFonte 	:= ""

Begin Sequence

DEFINE MSDIALOG oDlg TITLE STR0032  FROM 9,0 TO 20,90 OF oMainWnd//'Reserva de número de documento para posterior publicação'

@ 40,010 SAY STR0051 PIXEL  //"Tipo Doc:" 
@ 40,042 MSGET oGet1 VAR cTpdoc   PICTURE "@!" Valid (VDFTPDOC({cFonte,cTpdoc})) F3 "S100" SIZE 45,8 OF oDlg PIXEL HASBUTTON                                                   
@ 40,090 MSGET Alltrim(fDescRCC("S100",cTpdoc,1,3,34,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F. 	     	  
@ 60,010 SAY STR0097 PIXEL  //"Departamento:" 
@ 60,052 MSGET oGet1 VAR cDepto   PICTURE "@!" Valid (ExistCPO("SQB",cDepto)) F3 "SQB" SIZE 100,8 OF oDlg PIXEL HASBUTTON                                                   
@ 60,150 MSGET FDesc("SQB", cDepto, "QB_DESCRIC") VALID {|| ,oDlg:Refresh()} SIZE 200,8  OF oDlg Pixel WHEN .F. 	     	  

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

If lRet
	//Acha ultimo nr do documento
	cQuery  := "SELECT MAX(RI5_NUMDOC) NR_DOC,RI5_TIPDOC "
	cQuery  += " FROM " + RetSqlName( 'RI5' )
	cQuery  += " WHERE D_E_L_E_T_ = ' ' "
	cQuery  += " AND  RI5_TIPDOC='"+cTpdoc+"'"    
    If fDescRCC("S100",cTpdoc,1,3,59,01) == '1'	
		cQuery  += " AND  RI5_ANO='" + Alltrim(STR(YEAR(dDataAtu))) +"'"
	Endif
	cQuery += " GROUP BY RI5_TIPDOC"
	
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
	dbSelectArea("TRB")
	nNundoc := Strzero((val(TRB->NR_DOC)+1),4)
	TRB->( dbCloseArea() )
	
	//Grava tabela RI5-Documento
	Begin Transaction
	RecLock("RI5",.T.)
	RI5->RI5_FILIAL 	:= FWxFilial("RI5")
	RI5->RI5_ANO  		:= Alltrim(STR(YEAR(dDataAtu)))
	RI5->RI5_NUMDOC 	:= nNundoc
	RI5->RI5_TIPDOC 	:= cTpdoc
	RI5->RI5_DTATPO 	:= dDataAtu
	RI5->RI5_TXTCAB 	:= ''
	RI5->RI5_TXTROD 	:= ''
	RI5->RI5_STATUS 	:= '3'
	RI5->RI5_SOLRES		:= if(!empty(cDepto),cDepto,'')
	RI5->(MsUnLock())
	End Transaction
    MsgInfo(STR0004+nNundoc+'/'+Alltrim(STR(YEAR(dDataAtu)))+'.', '')																				//'Foi RESERVADO documento '
	
Endif

RestArea( aArea )
Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020CmpR
Compplementa o tipo reserva
@sample 	VD020CmpR()
@return	Nil
@author	Nivia Ferreira
@since		05/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020CmpR()
Local aArea   	:= GetArea()
Local cMarca  	:= oMark:Mark()
Local cNumDoc 	:= ''
Local nCont   	:= 0


DbSelectArea("RI5")
RI5->(DbGoTop())

While RI5->(!Eof())
	
	If oMark:IsMark(cMarca)
		If RI5_STATUS <> '3'
			MsgInfo(STR0005, '')		//'Ato/Portaria não foi reservado.'
			Return()
		Endif
		cNumDoc:= RI5->RI5_TIPDOC
		_Ano  	:= RI5->RI5_ANO
		_Doc   := RI5->RI5_NUMDOC
		nCont++
	EndIf
	
	RI5->(DbSkip())
Enddo

If (nCont > 1) .Or. (nCont = 0)
	MsgInfo(STR0006, '')			//'Selecione apenas um Ato/Portaria.'
	Return()
Endif


VD020ITEM(cNumDoc,.F.,.t.)

RestArea( aArea )
Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020Publc
Atualiza a data de publicação/documento
@sample 	VD020Publc()
/*/
//------------------------------------------------------------------------------
Function VD020Publc()
Local aArea  	:= GetArea()
Local lRet   	:= .F.
Local lResc		:= .F.
Local bOk     	:= {||lRet := f20ValResc(RI5->RI5_ANO,RI5->RI5_NUMDOC,RI5->RI5_TIPDOC,dPublic),,oDlg:End()}
Local bCancel 	:= {||oDlg:End()}
Local oDlg  
Local oData
Local oDocum	
Local dPublic 	:= RI5->RI5_DTAPUB
Local dDtato  	:= RI5->RI5_DTATPO
Local cDocumen	:= RI5->RI5_NUMDOC + "/" + RI5->RI5_ANO

Begin Sequence

DEFINE MSDIALOG oDlg TITLE STR0058  FROM 9,0 TO 25,62 OF oMainWnd//'Atualiza data de publicação/documento'
      
	@ 20,030 SAY OemToAnsi(STR0063) PIXEL  	//"Documento Publicado:"
	@ 20,100 MSGET oDocum VAR cDocumen PICTURE "@!" Valid F3 SIZE 50,8 OF oDlg PIXEL HASBUTTON WHEN (.F.)

	@ 40,030 SAY STR0060  PIXEL  //"Data Documento:" 
	@ 40,100 MSGET oData  VAR dDtato   PICTURE "@D" Valid F3 SIZE 45,8 OF oDlg PIXEL HASBUTTON 
	
	@ 60,030 SAY STR0059  PIXEL  //"Data Publicação:" 
	@ 60,100 MSGET oData  VAR dPublic  PICTURE "@D" Valid F3 SIZE 45,8 OF oDlg PIXEL HASBUTTON                                                 
  	  

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

If lRet
	//Grava tabela RI5-Documento
	Begin Transaction
		IF RI5->(MsRLock())
			RecLock("RI5",.F.)
			RI5->RI5_DTATPO 	:= dDtato
			RI5->RI5_DTAPUB 	:= dPublic	
			RI5->RI5_OK    		:= ''	
			RI5->(MsUnLock())

			dbSelectArea("RI6")
			DbSetOrder(2)
			RI6->(DbSeek(FWXFILIAL("RI6") +RI5->RI5_ANO + RI5->RI5_NUMDOC + RI5->RI5_TIPDOC  ))
			While !RI6->( EOF() ) .And. RI5->RI5_ANO==RI6->RI6_ANO .And. RI5->RI5_NUMDOC==RI6->RI6_NUMDOC .And. RI5->RI5_TIPDOC==RI6->RI6_TIPDOC 
				IF RI6->(MsRLock())
					RecLock("RI6",.F.)
					RI6_DTATPO	:= dDtato
					RI6->(MsUnlock())
				ENDIF
				RI6->( dbSkip() )	
			End 
			Aviso(OemToAnsi(STR0038), OemToAnsi(STR0064), {"OK"})		//"Atenção! ### "Processo concluído com sucesso!"
		ELSE
			Aviso(OemToAnsi(STR0038),OemToAnsi(STR0101)) // Erro de processamento
		ENDIF
	End Transaction
Endif

RestArea( aArea )
Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020ITEM
Geracao de Atos/Portarias
Rotina para seleção do documento.
@sample 	VDFM020()
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020ITEM(cNumDoc,cHabili,lComplRes)

Local cRet    		:= ''
Local cAlias  		:= GetNextAlias()
Local aSize			:= FWGetDialogSize( oMainWnd )
Local oGet1
Local oDlg  
Local oComb1   
Local cComb1        := space(20)    
Local aComb1  		:= {STR0013,STR0033}//Lista ,Paragrafo

Private aRotina  	:= MenuDef()	// Monta menu da Browse
Private cCadastro	:= STR0007		//"Geração de novo documento"
Private oMark    	:= Nil
Private cTpdoc   	:= cNumDoc
Private aQrytmp		:= {}
Private cFonte
Private oRA_FILIAL

Default lComplRes 	:= .f.  //Complemento de reserva

PtSetAcento(.T.)                                                                                                                                                                                              

aQrytmp 		:= VD020Qry(cTpdoc)
M->RA_FILIAL	:= cFilAnt	
M->RA_PROCUR	:= M->RA_PROC_O  := Space(Len(SRA->RA_MAT))
M->RA_PROC_N	:= Space(50)
M->M0_NOMECOM 	:= SM0->M0_NOMECOM
M->Q3_DESCS_P	:= M->Q3_P_DESCS := Space(TAMSX3("Q3_DESCSUM")[1])
cSXB_SRACAT   	:= "SRA->RA_FILIAL == M->RA_FILIAL"

If lComplRes
	aComb1  		:= {STR0033}		//Paragrafo  --> quando for complemento de reserva, so pode permitir PARAGRAFO
	M->RA_FILIAL	:= PadR(vGetMv(cFilAnt, "TM_VD" + cTpDoc + "SF", Space(len(cFilAnt))) , Len(cFilAnt)) 
	M->RA_PROCUR	:= PadR(vGetMv(cFilAnt, "TM_VD" + cTpDoc + "SM", Space(TAMSX3("RA_MAT")[1])), TAMSX3("RA_MAT")[1])
	M->Q3_DESCS_P	:= PadR(vGetMv(cFilAnt, "TM_VD" + cTpDoc + "SC", Space(TAMSX3("Q3_DESCSUM")[1])), TAMSX3("Q3_DESCSUM")[1])
	M->RA_PROC_O	:= M->RA_PROCUR
	VALSRA()	
Else
	aComb1  		:= {STR0013,STR0033}//Lista ,Paragrafo
Endif

//--------------------------------------------------------------
// Monta tela 
//--------------------------------------------------------------
oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , , , , , oMainWnd, .T. )

oLayer := FWLayer():New()
oLayer:Init( oDialog, .F.)

oLayer:AddLine( 'Linha', 100)
oLayer:AddColumn( 'Coluna', 100, .T., 'Linha' )
oLayer:AddWindow( 'Coluna', 'oDlgManut', cCadastro, 100, .F., .F., {||}, 'Linha' )
oDlgManut := oLayer:GetWinPanel( 'Coluna', 'oDlgManut', 'Linha' )

//----------------------------------------------------------
// Objetos para permitir selecionar um período de filtro
//----------------------------------------------------------
oPanelTop 	:= TPanel():New( 0, 0, '', oDlgManut,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.16 )
oPanelTop:Align := CONTROL_ALIGN_TOP

oSayDoc:= TSay():New( 06, 02, { || STR0008 }, oPanelTop,,,,,,.T.,,, 50, 10 )		//'Tipo do Documento:'
@ 22,60 MSGET oGet1 VAR cTpdoc  PICTURE "999" VALID VDF020TELA() F3 "S1001" SIZE 30,8 OF oDlg PIXEL WHEN cHabili
@ 22,100 MSGET Alltrim(fDescRCC("S100",cTpdoc,1,3,34,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.
      
oSayLis:= TSay():New( 06, 265, { || STR0009 }, oPanelTop,,,,,,.T.,,, 80, 10 )		//'Publica Lista ou Parágrafo:'
@ 22,340 MSCOMBOBOX oComb1 VAR cComb1 ITEMS aComb1 SIZE 90,8 OF oDlg PIXEL 

oSayFil:= TSay():New( 22, 02, { || STR0080 }, oPanelTop,,,,,,.T.,,, 50, 10 )		//'Filial Assinatura:'	
@ 37,060 MSGET oRA_FILIAL VAR M->RA_FILIAL F3 "SM0" Valid ValSM0() OF oDlg PIXEL
@ 37,115 MSGET M->M0_NOMECOM OF oDlg Pixel WHEN .F.

oSayMat:= TSay():New( 37, 02, { || STR0081 }, oPanelTop,,,,,,.T.,,, 80, 10 )		//'Matricula Assinatura:'	
@ 52,060 MSGET M->RA_PROCUR F3 "SRACAT" Valid ValSRA() OF oDlg PIXEL
@ 52,100 MSGET M->RA_PROC_N OF oDlg Pixel WHEN .F.

oSayCar:= TSay():New( 37, 400, { || STR0082 }, oPanelTop,,,,,,.T.,,, 50, 10 )		// 'Cargo:'	
@ 52,425 MSGET oQ3_DESCS_P VAR M->Q3_DESCS_P OF oDlg PIXEL 

oPanelBot 	:= TPanel():New( 0, 0, '', oDlgManut,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.84 )
oPanelBot:Align := CONTROL_ALIGN_BOTTOM

oMark:= FWFormBrowse():New()
oMark:SetOwner( oPanelBot )
oMark:AddMarkColumns( { || IIf( (cAlias)->RI6_OK == 1, "LBOK", "LBNO" ) })
oMark:SetDataQuery(.T.)
oMark:SetDescription( STR0096 ) //'Classificações que possuem itens disponíveis para publicação:'
oMark:SetQuery( aQrytmp[1] )
oMark:SetAlias( cAlias )
oMark:SetColumns( aQrytmp[2] )
oMark:SetUseFilter( .T. )
oMark:DisableConfig()
oMark:DisableReport()
oMark:DisableDetails()
oMark:AddButton( STR0052, { || VD020PROC(oMark,cAlias,cComb1)},,,, .F., 2 ) //"Confirmar a seleção"
oMark:AddButton( STR0053, { || oDialog:End() },,,, .F., 2 )	//'Voltar'
oMark:aColumns[1]:bHeaderClick := {|| VD020MkAll( oMark ) }
oMark:SetDoubleClick( {|| VD020MkOne( oMark ) } )
oMark:Activate()

oDialog:Activate( ,,,.T.,,, )

PtSetAcento(.F.)

Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF020TELA
Seleciona todos os itens
@sample 	VDF020TELA()
@return	Nil
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF020TELA()
Local xRet := .T.

If xRet := VD020VLDTD(cTpdoc)
	aQrytmp := VD020Qry(cTpdoc  )
	VD020Atual( oMark, aQrytmp[1] )
	
	M->RA_FILIAL	:= PadR(vGetMv(cFilAnt, "TM_VD" + cTpDoc + "SF", Space(len(cFilAnt))), Len(cFilAnt)) 
	M->RA_PROCUR	:= PadR(vGetMv(cFilAnt, "TM_VD" + cTpDoc + "SM", Space(TAMSX3("RA_MAT")[1])),TAMSX3("RA_MAT")[1])
	M->RA_PROC_N	:= Space(50)
	M->Q3_DESCS_P	:= Space(TAMSX3("Q3_DESCSUM")[1])	
	If ! Empty(M->RA_PROCUR)
		ValSRA()
	EndIf
	ValSM0()
	M->Q3_DESCS_P	:= PadR( alltrim(vGetMv(cFilAnt, "TM_VD" + cTpDoc + "SC", M->Q3_DESCS_P)) , TAMSX3("Q3_DESCSUM")[1] )	
	M->Q3_P_DESCS 	:= M->Q3_DESCS_P
	M->RA_PROC_O	:= M->RA_PROCUR 

Endif
oRA_FILIAL:SetFocus()	

Return(xRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} VALSM0
Valida o código da Filial
@return	lOk = Indica se a filial informada é valida
@author	Wagner Mobile Costa
@since		23/06/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ValSM0()

Local aArea := SM0->(GetArea())

If Empty(M->RA_FILIAL)
	Return .T.
EndIf

DbSelectArea("SM0")
Set Filter to M0_CODIGO == cEmpAnt .And. M0_CODFIL == Left(M->RA_FILIAL + Space(Len(SM0->M0_CODFIL)), Len(SM0->M0_CODFIL))
DbGoTop()
If Eof()
	Alert(STR0083)	//'Atenção. A filial informada não existe !'
	Set Filter To
	M->M0_NOMECOM := Space(Len(SM0->M0_NOMECOM))
	RestArea(aArea)
	Return .F.
EndIf

nRecno := Recno()
Set Filter To
DbGoto(nRecno)
M->M0_NOMECOM := SM0->M0_NOMECOM

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} VALSRA
Valida a matricula a ser utilizada para assinatura
@return	lOk = Indica se a filial informada é valida
@author	Wagner Mobile Costa
@since		23/06/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ValSRA()

Local aArea := SRA->(GetArea()), lRet := .T.

If Empty(M->RA_PROCUR)
	Return .T.
EndIf

DbSelectArea("SRA")
DbSetOrder(1)
lRet := DbSeek(M->RA_FILIAL + M->RA_PROCUR)
If ! lRet
	Alert(STR0084)		// 'Atenção. A matricula informada não existe !'
EndIf

if !Empty(SRA->RA_NOMECMP)
	If lOfuscaCMP
		M->RA_PROC_N := Replicate('*',15)
	else
		M->RA_PROC_N := left(SRA->RA_NOMECMP, 50)
	ENDIF
else
	If lOfuscaNom
		M->RA_PROC_N := Replicate('*',15)
	else
		M->RA_PROC_N := left(SRA->RA_NOME, 50)
	ENDIF
ENDIF

If lRet .And. M->RA_PROC_O <> M->RA_PROCUR
	SQ3->(DbSetOrder(1))
	SQ3->(DbSeek(xFilial() + SRA->RA_CARGO))
	 
	M->Q3_DESCS_P := SQ3->Q3_DESCSUM
EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020MkOne
Marca os registros da tabela temporária quando ocorrer o clique no header do
campo de flag
@sample 	VD020MkOne( oObjMark )
@param		oObjMark 	Objeto da classe FwFormBrowse para identificação do Alias e
Atualização da interface
@return	Nil
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020MkOne( oObjMark )

Local cMarkTMP   := ''
Default oObjMark := Nil

If oObjMark <> Nil 
	cMarkTMP := oObjMark:cAlias
	
	If (cMarkTMP)->( !EOF() )
		If (cMarkTMP)->RI6_OK == 1
			(cMarkTMP)->RI6_OK := 0
		Else
			(cMarkTMP)->RI6_OK := 1
		Endif	
	Endif
EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020MkAll
Marca os registros da tabela temporária quando ocorrer o clique no header do
campo de flag
@sample 	VD020MkAll( oObjMark )
@param	    oObjMark 	Objeto da classe FwFormBrowse para identificação do Alias e
Atualização da interface
@return	Nil
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020MkAll( oObjMark )

Local cMark    := ''
Local nTipMark := If( lTipMark, 1, 0 )

Default oObjMark := Nil

If oObjMark <> Nil
	cMark := oObjMark:cAlias
	
	(cMark)->( DbGoTop() )
	
	While (cMark)->( !EOF() )
		RecLock(cMark)
		(cMark)->RI6_OK := nTipMark
		(cMark)->(MsUnLock())
		(cMark)->( DbSkip() )
	End
	
	(cMark)->( DbGoTop() )
	
	lTipMark := !lTipMark
EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020QRY
Função para montar a consulta a Classificação do Tipo do Documento.
@sample 	VD020QRY(cTpdoc)
@param	    cTpdoc	Tipo de documento selecionado.
@return	aRet 	Consulta e campos retornados.
			[1] cQuery  - Consulta no padrao SQL
			[2] aCampos - Estrutura dos campos da consulta
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020QRY(cTpdoc)
Local aArea  	:= GetArea()
Local nJ      := 0
Local nI      := 0
Local aRet	   	:= {}
Local aCampos := {}
Local aColumns:= {}
Local cQuery  := ''

cQuery  += " SELECT COUNT(RI6.RI6_CLASTP) AS TOTAL, "
If lSubsTp
	cQuery  += " SUBSTRING(RCC.RCC_CONTEU,03,30) AS DESC_TP, 0 AS RI6_OK,RI6_CLASTP "
Else
	cQuery  += " SUBSTR(RCC.RCC_CONTEU,03,30) AS DESC_TP, 0 AS RI6_OK,RI6_CLASTP "
EndIf
cQuery  += " FROM "+ RetSqlName( 'RI6' ) + " RI6, " + RetSqlName( 'RCC' ) + " RCC "
cQuery  += " WHERE RI6.D_E_L_E_T_ = ' ' "
cQuery  += " AND RCC.D_E_L_E_T_ = ' ' "
cQuery  += " AND RI6.RI6_FILIAL='" + FWxFilial("RI6") +"'"
cQuery  += " AND RCC.RCC_FILIAL='" + FWxFilial("RCC") +"'"
cQuery  += " AND RCC.RCC_CODIGO='S101' "
If lSubsTp
	cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,01,02) =RI6_CLASTP"
Else
	cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,01,02) =RI6_CLASTP"
EndIf
cQuery  += " AND RI6.RI6_DTATPO =' ' "
cQuery  += " AND RI6.RI6_ANO = ' ' "
cQuery  += " AND RI6.RI6_STATUS <> '4' "

If empty(cTpdoc)
	cQuery  += " AND RI6_TIPDOC = ' ' "
Else
	cQuery  += " AND RI6_TIPDOC = '"+ cTpdoc +"'"
Endif
cQuery  += " GROUP BY RCC_CONTEU,RI6_CLASTP"
cQuery  += " ORDER BY RCC_CONTEU"

aCampos:={;
			{STR0086,"RI6_CLASTP" , 02,0, "@!"},;			// 'Codigo'
			{STR0087,"DESC_TP"    , 30,0, "@!"},;			// 'Classificação'
			{STR0088,"TOTAL"      , 07,0, "@E 9999999" }}	// 'Total'

nJ := 1
For nI := 1 To Len(aCampos)
	
	AAdd( aColumns, FWBrwColumn():New() )
	aColumns[nJ]:SetData( &("{||" + aCampos[nI][2] + "}") )
	aColumns[nJ]:SetTitle( aCampos[nI][1] )
	aColumns[nJ]:SetSize( aCampos[nI][3] )
	aColumns[nJ]:SetDecimal( aCampos[nI][4] )
	aColumns[nJ]:SetPicture( aCampos[nI][5] )
	
	nJ++
Next nI

AAdd( aRet, cQuery )
AAdd( aRet, aColumns )

RestArea(aArea)
Return (aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020Atual
Atualiza o objeto Browse com a Query recebida.
@sample 	VD020Atual( oBrowse, cQuery )
@param		oBrowse	Objeto do tipo FWBrowse.
			cQuery	Consulta SQL para atualizar a Browse.
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020Atual( oBrowse, cQuery )
Local lRet	:= .T.

oBrowse:Data():DeActivate()
oBrowse:SetQuery( cQuery )
oBrowse:Data():Activate()
oBrowse:UpdateBrowse(.T.)
oBrowse:GoBottom()
oBrowse:GoTo(1, .T.)
oBrowse:Refresh(.T.)

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020PROC
Valida se há itens marcados na lista.
Monta a MarkBrowse da tabela RI6.
@sample 	VD020PROC(oBrowse, cAlias, cQuery)
@param	    oBrowse	Objeto do tipo FWBrowse.
			cAlias      Alias da tabela temporaria.  
			cCombo      Nao - seleciona apenas 1 tipo de documento
            			 Sim - pode selecionar tipos diferentes, mas o doc sera gerado no formato paragrafo.
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020PROC(oBrowse, cAlias, cCombo)
Local aArea	:= GetArea()
Local aAreaTmp:= (cAlias)->(GetArea())
Local lRet		:= .F.
Local cClass  := ''

Private oMark01   
Private cItem := cCombo

If Empty(M->RA_PROCUR)
	Alert(STR0085)		// 'Atenção. É obrigatório selecionar o responsável pela assinatura do documento !'
	Return .F.	
EndIf

//-- Grava a filial do responsavel pela assinatura
vPutMv( M->RA_FILIAL, ;
		"TM_VD" + cTpDoc + "SF", "C",;
		{ 	STR0090, STR0091, STR0092 + cTpDoc},;   //"Parametro temporario do modulo SIGAVDF para ","guardar a filial do responsavel pela assinatura ","pela classificacao do documento "
		M->RA_FILIAL)

//-- Matricula do responsável pela assinatura 
vPutMv( M->RA_FILIAL, ;
		"TM_VD" + cTpDoc + "SM", "C",;
		{ 	STR0090, STR0093, STR0092 + cTpDoc},;   //"Parametro temporario do modulo SIGAVDF para ","guardar a matrícula do responsavel pela assinatura ","pela classificacao do documento "
		M->RA_PROCUR)

//-- Cargo do responsável pela assinatura 
vPutMv(	M->RA_FILIAL, ;
		"TM_VD" + cTpDoc + "SC", "C",;
		{ 	STR0090, STR0094, STR0092 + cTpDoc},;   //"Parametro temporario do modulo SIGAVDF para ","guardar o cargo do responsavel pela assinatura ","pela classificacao do documento "
		M->Q3_DESCS_P)
			
DbSelectArea(cAlias)
(cAlias)->(DbGoTop())

RI6->(dbSetOrder(5))                         

If cItem == STR0010//'1-Lista'
	While ( (cAlias)->(!Eof()) )
	
		If ( (cAlias)->RI6_OK == 1 )
			oMark01 := FWMarkBrowse():New()
			oMark01:SetAlias('RI6')
			oMark01:SetOnlyFields( { 'RI6_CLASTP', 'RI6_DESCLA', 'RI6_CPF','RI6_NOME', 'RI6_DTEFEI', 'RI6_FILMAT', 'RI6_MAT' } )
			oMark01:SetSemaphore(.T.)
			oMark01:SetDescription(STR0011)//'Itens disponíveis para publicação: '
			oMark01:SetFieldMark( 'RI6_OK' )
			oMark01:SetAllMark( { || oMark01:AllMark() } )
			oMark01:SetFilterDefault( "RI6_CLASTP $'"+ (cAlias)->RI6_CLASTP+ "' .And. RI6_DTATPO==' ' .And. RI6_ANO==' ' .And. RI6_STATUS <> '4' " )
			oMark01:AddButton( STR0050, { || VD020EDIT(oMark01),oMark01:Refresh(.T.)},,,, .F., 7 ) //"Confirmar"
			oMark01:Activate()
			lRet := .T.
		EndIf
	
		(cAlias)->(DbSkip())
	
	EndDo

Else

	While ( (cAlias)->(!Eof()) )
		If ( (cAlias)->RI6_OK == 1 )
		   cClass := cClass +'/'+ (cAlias)->RI6_CLASTP
		EndIf
		(cAlias)->(DbSkip())
	EndDo

    If !Empty(cClass)
		oMark01 := FWMarkBrowse():New()
		oMark01:SetAlias('RI6')
		oMark01:SetOnlyFields( { 'RI6_CLASTP', 'RI6_DESCLA', 'RI6_CPF','RI6_NOME', 'RI6_DTEFEI', 'RI6_FILMAT', 'RI6_MAT' } )
		oMark01:SetSemaphore(.T.)
		oMark01:SetDescription(STR0011)//'Itens disponíveis para publicação: '
		oMark01:SetFieldMark( 'RI6_OK' )
		oMark01:SetAllMark( { || oMark01:AllMark() } )
		oMark01:SetFilterDefault( "RI6_CLASTP $'"+ cClass+ "' .And. RI6_DTATPO==' ' .And. RI6_ANO==' ' .And. RI6_STATUS <> '4' " )
		oMark01:AddButton( STR0050, { || VD020EDIT(oMark01),oMark01:Refresh(.T.)},,,, .F., 7 ) //"Confirmar"
		oMark01:Activate()
		lRet := .T.
    Endif
Endif    


RestArea( aAreaTmp )
RestArea( aArea )

If 	lRet == .T.
	VD020Atual( oBrowse, aQrytmp[1] )
	oMark:Refresh()
Endif

Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020EDIT
Valida se há itens marcados na lista.
@sample 	VD020EDIT(oMark01)
@param	    oMark01	Objeto do tipo FWBrowse - RI6.
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020EDIT(oMark01)
Local aArea    := GetArea()
Local aAprov   := {}
Local cCLASTP  := ''
Local cMarca   := oMark01:Mark()

RI6->( dbGoTop() )
While !RI6->( EOF() )
	If oMark01:IsMark(cMarca)
		cCLASTP := RI6->RI6_CLASTP
		AADD(aAprov,{RI6->RI6_CPF,RI6->RI6_CLASTP,RI6->RI6_TIPDOC,RI6->RI6_ANO,cItem,'',RI6->RI6_TABORI,RI6->RI6_CHAVE,RI6->(recno())})
	Endif
	RI6->( dbSkip() )
End

If !EMPTY(aAprov)
	VD020Texto(aAprov) //Monta Editor de Texto
Endif

RestArea( aArea )
Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020Texto
Geracao de Atos/Portarias pelo editor de texto.
@sample 	VD020Texto(aAprov)
@param		aAprov		Dados selecionados no FWBrowse - RI6. 
            aAprov[1]	 
@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function  VD020Texto(aAprov)
Local aArea		:= GetArea()  
Local aAreaRI5	:= RI5->( GetArea() )
Local aAreaRI6	:= RI6->( GetArea() )
Local aAreaREY	:= REY->( GetArea() )
Local nI       	:= 0
Local lRet   	:= .F.
Local nOpc   	:= 0
Local nChave  	:= ''
Local bOk      	:= {||lRet:=.T.,cCabec:=oTSmpEdit1:GetText(),cRodape:=oTSmpEdit3:GetText(),cTextoArq:=oTSmpEdit2:GetText(),oDlg:End()}
Local bCancel	:= {||oDlg:End()}
Local oDlg
Local oTSmpEdit1
Local oTSmpEdit2
Local oTSmpEdit3

Local aSize	  		:= {}    
Local aTab       	:= {}
Local cTextoArq  	:= ''
Local cCabec     	:= ''
Local cRodape    	:= ''
Local cTexto1    	:= ''
Local cTexto2    	:= ''
Local cTexto3    	:= ''
Local cQuery     	:= ''
Local cCmd       	:= ''
Local nNundoc    	:= 0 
Local dDataAtu		:= date()
Local cAno       	:= Alltrim(STR(YEAR(dDataAtu)))

Local cFileOpen1 	:= ""
Local cFileOpen2 	:= ""
Local cArqTemp   	:= ""
Local cArquivoC  	:= "\inicializadores\S101_CAB_"+ aAprov[1,2] +".INI"         //arquivo cabecario
Local cArquivoR  	:= "\inicializadores\S101_ROD_"+ aAprov[1,2] +".INI"         //arquivo rodape
Local cArquivoRP 	:= "\inicializadores\S101_ROD_P.INI"                         //arquivo rodape padrao
Local cLogoMP       := "\inicializadores\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "01.PNG" //arquivo logo cabeçalho
Local cLogoMP2      := "\inicializadores\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "02.PNG" //arquivo logo rodapé

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords    := {}

//Copia o logo do \system para c:
IF FILE(cLogoMP)
	Delete File(cDiretorio + "\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "01.PNG")
	CPYS2T(cLogoMP,cDiretorio,.F.)
ENDIF

IF FILE(cLogoMP2)
	Delete File(cDiretorio + "\" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "02.PNG")
	CPYS2T(cLogoMP2,cDiretorio,.F.)
ENDIF

If File(cDiretorio + "\MODELO.TXT")
	Delete File(cDiretorio + "\MODELO.TXT")
Endif

If File(cDiretorio + "\MODELOP.TXT")
	Delete File(cDiretorio + "\MODELOP.TXT")
Endif

//Arquivo Cabec
cFileOpen1 :=cArquivoC
If !File(cFileOpen1)
	MsgInfo(STR0054 + cArquivoC + STR0055, cArquivoC)//"Arquivo ", " não localizado"
	Return
Endif

//Arquivo Rodape
cFileOpen2 := cArquivoR
If !File(cFileOpen2)
    cFileOpen2 :=cArquivoRP
	If !File(cFileOpen2)
		MsgInfo(STR0054+ cArquivoRP + STR0055, cArquivoRP) //"Arquivo ", " não localizado"
		Return
	Endif	
Endif

//Monta os Itens
For nI:=1 TO Len(aAprov)

	dbSelectArea("RI6")
	dbGoTo(aAprov[nI,9])

	If aAprov[nI,5] == STR0013//'1-Lista'
	   cTexto2   		:= cTexto2 + Alltrim(RI6_TXTITE)
	   cTextoArq 		:= cTextoArq + VDFMBRAN(RI6_TXTITE,'H') //Converte alguns caracteres 
  	   aAprov[nI][06]	:= VDFMBRAN(RI6_TXTITE,'H')
	Else
	   cTexto2   		:= cTexto2 + RI6_TXTHIS                    
	   cTextoArq 		:= cTextoArq + RI6_TXTHIS   	   
   	   aAprov[nI][06]	:= VDFMBRAN(RI6_TXTHIS, 'P')             //Converte alguns caracteres 
	Endif   	   
	
Next

aTab  	 := {{'S10003',Alltrim(fDescRCC("S100",aAprov[1,3],1,3,34,20))},{'S10004',Alltrim(fDescRCC("S100",aAprov[1,3],1,3,54,5))}} 
cTexto1 := VD210CBCRD(cFileOpen1,'',aTab)                                                      
cTexto3 := VD210CBCRD(cFileOpen2,'',aTab)
cTexto2 := cTexto2

//Abre os editores de texto
Begin Sequence

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
DEFINE MSDIALOG oDlg TITLE STR0034 FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL//"Geração de Atos/Portarias "

oTPanel1:= TPanel():New(10,10,"",oDlg,,,,,,050,100)
oTPanel1:Align := CONTROL_ALIGN_TOP

oTPanel2:= TPanel():New(10,10,"",oDlg,,,,,,050,050)
oTPanel2:Align := CONTROL_ALIGN_ALLCLIENT

oTPanel3:= TPanel():New(10,10,"",oDlg,,,,,,050,100)
oTPanel3:Align := CONTROL_ALIGN_BOTTOM

//nTop, nLeft, nHeight, nWidth , cTitle, cText, nFormat, lShowOkButton, lShowCancelButton, oOwner
oTSmpEdit1 := tSimpEdit():New( , , , , "",  @cTexto1, 1, .F., .F.,oTPanel1)
oTSmpEdit2 := tSimpEdit():New( , , , , "",  @cTexto2, 1, .F., .F.,oTPanel2)
oTSmpEdit2:oSimpEdit:lReadonly := .T.
oTSmpEdit3 := tSimpEdit():New( , , , , "",  @cTexto3, 1, .F., .F.,oTPanel3)


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

//Se clicar no Botao Confirmar
If lRet
	
	If Empty(_Ano) .And. Empty(_Doc)
		Begin Transaction           
		//Acha ultimo nr do documento
		
   		cQuery  := "SELECT MAX(RI5_NUMDOC) NR_DOC,RI5_TIPDOC "
		cQuery  += " FROM " + RetSqlName( 'RI5' )
		cQuery  += " WHERE D_E_L_E_T_ = ' ' "
		cQuery  += " AND  RI5_TIPDOC='"+aAprov[1,3]+"'"
	    If fDescRCC("S100",aAprov[1,3],1,3,59,01) == '1'
			cQuery  += " AND  RI5_ANO='" + cAno +"'"
		Endif
		cQuery += " GROUP BY RI5_TIPDOC"
		
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
		dbSelectArea("TRB")
		nNundoc := Strzero((val(TRB->NR_DOC)+1),4)  
		TRB->( dbCloseArea() )
		
        //faz substituicao cabec - doc/ano
		aTab:= {{'{*[XDOC]*}',nNundoc},{'{*[XANO]*}',cAno}} 	                               
		cCabec:= VD210CBCRD('',cCabec,aTab)

		//Grava tabela RI5-Documento
		RecLock("RI5",.T.)
		RI5->RI5_FILIAL := FWxFilial("RI5")
		RI5->RI5_ANO    := cAno
		RI5->RI5_NUMDOC := nNundoc
		RI5->RI5_TIPDOC := aAprov[1,3]
		RI5->RI5_DTATPO := dDataAtu
		If Substr(aAprov[1,5],1,1) == '1'
  		   RI5->RI5_TXTCAB := VDFMBRAN(cCabec,'C')		
  		   RI5->RI5_TXTROD := VDFMBRAN(cRodape, 'R')
		Else
		   RI5->RI5_TXTCAB := cCabec		
		   RI5->RI5_TXTROD := cRodape		   
		Endif
		RI5->RI5_TPARQ  := Substr(aAprov[1,5],1,1)		
		RI5->RI5_STATUS := '1'
		RI5->(MsUnLock())
		
		//Atualiza Tabela RI6-Itens do Documento
		For nI:=1 TO Len(aAprov)
		
				dbSelectArea("RI6")
				RI6->(DbGoto(aAprov[nI,9]))
				If !RI6->( EOF() ) .and. RI6->(recno()) == aAprov[nI,9] .and. RI6->RI6_TIPDOC == aAprov[nI,3] .AND. RI6->RI6_CLASTP == aAprov[nI,2] .AND.;
				   Empty(RI6->RI6_ANO) .AND. Empty(RI6->RI6_NUMDOC) .AND. RI6->RI6_CPF == aAprov[nI,1]
					RecLock("RI6",.F.)
					RI6_DTATPO	:= dDataAtu
					RI6_ANO 	:= cAno
					RI6_NUMDOC	:= nNundoc
					RI6_TXTITE	:= aAprov[nI,6]
					RI6->(MsUnlock())
				Endif

				If  aAprov[nI,2] = '01' //Nomeação
					DbSelectArea("REY")
					DbSetOrder(4) //REY_FILIAL+REY_CPF+REY_CODCON+REY_FILFUN+REY_CODFUN                                                                                                             
					If (REY->(DbSeek(FWXFILIAL("REY")+RI6->RI6_CHAVE)))
						RecLock("REY",.F.)			
						REY_ANODOC := cAno					
						REY_NUMDOC := nNundoc
						REY_DTATPO := dDataAtu
						REY_TIPDOC := aAprov[nI,3]
						REY->(MsUnLock())
					Endif	
				EndIf		
			
		Next                             
		End Transaction

	Else                                                           

		Begin Transaction           
		DbSelectArea("RI5")
		DbSetOrder(1)
		If  (RI5->(DbSeek(FWXFILIAL("RI5")+_Ano+_Doc+aAprov[1,3]))) .And. (RI5_STATUS=='3')
			RecLock("RI5",.F.)
			RI5_STATUS := '1'  
			RI5_TXTCAB := cCabec
			RI5_TXTROD := cRodape
			RI5->(MsUnlock())
                                
			For nI:=1 TO Len(aAprov)
			
				dbSelectArea("RI6")
				RI6->(DbGoto(aAprov[nI,9]))
				If !RI6->( EOF() ) .and. RI6->(recno()) == aAprov[nI,9] .and. RI6->RI6_TIPDOC == aAprov[nI,3] .AND. RI6->RI6_CLASTP == aAprov[nI,2] .AND.;
				   Empty(RI6->RI6_ANO) .AND. Empty(RI6->RI6_NUMDOC) .AND. RI6->RI6_CPF == aAprov[nI,1]
					RecLock("RI6",.F.)
					RI6_DTATPO	:= dDataAtu
					RI6_ANO 	:= _Ano
					RI6_NUMDOC	:= _Doc
					RI6->(MsUnlock())
				Endif

				nNundoc := _Doc
				cAno    := _Ano
	
				If  aAprov[nI,2] = '01' //Nomeação
					DbSelectArea("REY")
					DbSetOrder(4) //REY_FILIAL+REY_CPF+REY_CODCON+REY_FILFUN+REY_CODFUN                                                                                                             
					If (REY->(DbSeek(FWXFILIAL("REY")+RI6->RI6_CHAVE)))
						RecLock("REY",.F.)			
						REY_ANODOC := cAno					
						REY_NUMDOC := nNundoc
						REY_DTATPO := dDataAtu
						REY_TIPDOC := aAprov[nI,3]
						REY->(MsUnLock())
					Endif	
				EndIf		
	
	        Next

		Endif	
		End Transaction		  
		
	Endif
	
	If MsgYesNo(STR0056 + nNundoc+"/"+cAno+ STR0057) //"Foi gerado o documento ", ". Deseja gerar o arquivo DOC ?"
		VD020GeraDc(RI5->RI5_TXTCAB,cTextoArq,RI5->RI5_TXTROD,nNundoc,cAno,aAprov[1,3])
	Endif
Endif

RestArea( aAreaRI5 )
RestArea( aAreaRI6 )
RestArea( aAreaREY )
RestArea( aArea )
Return()



//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020GeraDc
Monta arquivo em html com logo.
@sample 	VD020GeraDc(cTexto1,cTexto2,cTexto3,nNundoc,cTpdoc)
@param		cTexto1 Cabeçario do texto.
			cTexto2 Itens do texto.
			cTexto3 Rodape do texto.
			nNundoc Numero do documento.
			cAno	 Ano da geracao do documento.
			cTpdoc	 Tipo do documento.
@return	cLayout Texto com logo.
@author	Nivia Ferreira
@since		23/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function  VD020GeraDc(cTexto1,cTexto2,cTexto3,nNundoc,cAno,cTpdoc)
Local aArea	 	:= GetArea()
Local nHandle    	:= FCREATE(cDiretorio+"\MODELO.TXT")
Local nHandleP   	:= FCREATE(cDiretorio+"\MODELOP.TXT")
Local nEsperaI	:= 0
Local nRetT      	:= 0
Local cArquivo   	:= cTpdoc+"_"+nNundoc+"_"+cAno

If File(cDiretorio +"\"+ cArquivo +".DOC")
	Delete File(cDiretorio+"\"+ cArquivo +".DOC")
Endif

If File(cDiretorio +"\"+ cArquivo +"_PUBL.DOC")
	Delete File(cDiretorio +"\"+ cArquivo +"_PUBL.DOC")
Endif

cTexto1 := VD020Ajust(cTexto1)
cTexto2 := VD020Ajust(cTexto2)
cTexto3 := VD020Ajust(cTexto3)

//Texto para impressão
cTexto := VD020AbreD(cTexto1,VDFMBRAN(cTexto2,""),VDFMBRAN(cTexto3,""),"T")
cTexto := AcentHtml(cTexto)
FT_FUSE()
If nHandle <> -1
	FWrite(nHandle, cTexto + CRLF)
	FClose(nHandle)
Endif

//Texto para publicacação                       
cTexto := VD020AbreD(cTexto1,VDFMBRAN(cTexto2),VDFMBRAN(cTexto3),"P")

//Compacta o texto para publicação no diário oficial
cTexto := StrTran( cTexto , '<br />', '')

cTexto := AcentHtml(cTexto)
FT_FUSE()
If nHandleP <> -1
	FWrite(nHandleP, cTexto + CRLF)
	FClose(nHandleP)
Endif                                        
                        
If !ExistDir(cDir+ GetMV("MV_VDFPAST"))                                                               
	MsgInfo(STR0035+cDir+STR0014)//'Não foi possivel abrir o documento, pasta '+//'Atos_Portarias não foi criada.'
Else 
	If MsgYesNo(STR0036)//"Deseja visualizar o arquivo no LibreOffice ?")

		Frename(cDiretorio+"\MODELO.TXT",cDiretorio+'\'+cArquivo+".HTML")
	    nRetT:=Winexec("\LibreOffice\program\swriter.exe  --invisible --convert-to doc "+cDiretorio+'\'+cArquivo+".HTML --outdir "+cDiretorio)
	    
        If nRetT == 0

			//Espera que o Arquivo de Resposta Seja Criado
			For nEsperaI := 1 To 50000
				If File(cDiretorio+'\'+cArquivo+".DOC")
					exit
				ElseIf nEsperaI == 50000
					If !MsgYesNo(STR0062) //"A abertura está demorando mais do que o esperado. Deseja continuar aguardando ?"
				        exit
				 	Endif
				 	nEsperaI := 1
				Endif
			Next nEsperaI

			//Texto para publicacação                       
			cTexto:= VD020AbreD(cTexto1,VDFMBRAN(cTexto2),VDFMBRAN(cTexto3),"P")
			FT_FUSE()
			If nHandleP <> -1
				FWrite(nHandleP, cTexto + CRLF)
				FClose(nHandleP)
			Endif                                        
                                                                     
			Frename(cDiretorio+"\MODELOP.TXT",cDiretorio+'\'+cArquivo+"_Publ.HTML")
  			Winexec("\LibreOffice\program\swriter.exe  --invisible --convert-to doc "+cDiretorio+'\'+cArquivo+"_Publ.HTML --outdir "+cDiretorio)
                                                 
			Frename(cDiretorio+"\MODELO.TXT",cDiretorio+'\'+cArquivo+".HTML")
		    Winexec("\LibreOffice\program\swriter.exe  --invisible --convert-to doc "+cDiretorio+'\'+cArquivo+".HTML --outdir "+cDiretorio)
                                                 
			//Espera que o Arquivo de Resposta Seja Criado*/
			For nEsperaI := 1 To 50000
				If File(cDiretorio+'\'+cArquivo+"_Publ.DOC")
					exit
				ElseIf nEsperaI == 50000
					If !MsgYesNo(STR0062) //"A abertura está demorando mais do que o esperado. Deseja continuar aguardando ?"
				        exit
				 	Endif
				 	nEsperaI := 1
				Endif
			Next nEsperaI
                                      
			shellExecute( "Open", "\LibreOffice\program\soffice.exe", cDiretorio+'\'+cArquivo+".DOC" , cDiretorio, 1 )
			shellExecute( "Open", "\LibreOffice\program\soffice.exe", cDiretorio+'\'+cArquivo+"_Publ.DOC" , cDiretorio, 1 )	
		Endif	
	Else
		Frename(cDiretorio+"\MODELO.TXT", cDiretorio+'\'+cArquivo+".DOC")	     
		Frename(cDiretorio+"\MODELOP.TXT",cDiretorio+'\'+cArquivo+"_Publ.Doc")	
	Endif	                                     
	
Endif

//Ecluindo arquivo
If File(cDiretorio + "\MODELO.TXT")
	Delete File(cDiretorio + "\MODELO.TXT")
Endif

If File(cDiretorio + "\MODELOP.TXT")
	Delete File(cDiretorio + "\MODELOP.TXT")
Endif

If File(cDiretorio + "\"+cArquivo +".HTML")
	Delete File(cDiretorio +"\"+ cArquivo +".HTML")
Endif

If File(cDiretorio +"\"+ cArquivo +"_PUBL.HTML")
	Delete File(cDiretorio +"\"+ cArquivo +"_PUBL.HTML")
Endif


RestArea( aArea )
Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020AbreD
Monta arquivo em html com logo.
@sample 	VD020AbreD(cTexto1,cTexto2,cTexto3,cTipo,lArray)
@param		Texto1	Cabeçario
			Texto2  Itens
			Texto3	Rodape
			cTipo T=tudo - P=publicar
			aArray  Formato em array
@return		cLayout	Texto com logo.
@author	    Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function  VD020AbreD(Texto1,Texto2,Texto3,cTipo,lArray)
Local cLayout  := ''
Local aRetorno := {}
Local nA       := 0

DEFAULT lArray := .F.

cLayout := "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0 Transitional//EN'>" + CRLF
cLayout += "<HTML>" + CRLF
cLayout += "	<HEAD>" + CRLF
cLayout += "		<TITLE></TITLE>" + CRLF
cLayout += "	</HEAD>" + CRLF
cLayout += "	<BODY LANG='pt-BR' DIR='LTR'>" + CRLF

If cTipo == 'T'
	cLayout += "		<p align='center'>" + CRLF
	cLayout += "			<img src='" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "01.PNG' name='Figura1' align='middle' width='643' height='77' border='0'/>" + CRLF
	cLayout += "		</p>" + CRLF
	cLayout += "		<DIV TYPE=HEADER>" + CRLF
	cLayout += "			<P STYLE='margin-bottom: 2.0cm'><BR>" + CRLF
	cLayout += "			</P>" + CRLF
	cLayout += "		</DIV>" + CRLF
	cLayout += "		<DIV TYPE=FOOTER>" + CRLF
	cLayout += "			<P STYLE='margin-top: 2.0cm; margin-bottom: 0cm'><BR>" + CRLF
	cLayout += "			</P>"   + CRLF
	cLayout += "		</DIV>" + CRLF
EndIf

If lArray
	aadd(aRetorno,cLayout)
	For nA := 1 to len(Texto1)
		aadd(aRetorno,Texto1[nA]+CRLF)
	Next nA
	For nA := 1 to len(Texto2)
		aadd(aRetorno,Texto2[nA]+CRLF)
	Next nA
	For nA := 1 to len(Texto3)
		aadd(aRetorno,Texto3[nA]+CRLF)
	Next nA
	aadd(aRetorno,"</BODY></HTML>"+CRLF)
Else
	cLayout += Texto1 + CRLF
	cLayout += Texto2 + CRLF
	cLayout += Texto3 + CRLF

	If cTipo == 'T'
		cLayout += "		<br><br><br>"
		cLayout += "		<p align='center' style='margin-bottom: 0cm'>" + CRLF
		cLayout += "			<img src='" + StrTran(StrTran(cLogo,".png",""),".PNG","") + "02.PNG' name='Figura2' align='bottom' width='648' height='80' border='0'/>" + CRLF
		cLayout += "		</p>" + CRLF
	EndIf

	cLayout += "	</BODY>" + CRLF
	cLayout += "</HTML>" + CRLF
EndIf

Return(if(lArray,aRetorno,cLayout))


/*/{Protheus.doc} VD020Ajust
Ajusta o texto para o documento
@param		cTexto	Texto para ser ajustado.
@return		cTexto	Texto compactado.
@author	    Nivia Ferreira
@since		01/07/2013
@version	2.0
/*/
FUNCTION VD020Ajust(cTexto)

cTexto := STRTRAN ( cTexto , '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">','', , )   
cTexto := STRTRAN ( cTexto , '<html><head>','', , )
cTexto := STRTRAN ( cTexto , '<meta name="qrichtext" content="1" />', '', , )
cTexto := STRTRAN ( cTexto , '<style type="text/css">','', , )
cTexto := STRTRAN ( cTexto , 'p, li { white-space: pre-wrap; }', '', , )
cTexto := STRTRAN ( cTexto , '</style></head>', '', , )
cTexto := STRTRAN ( cTexto , '<body ', '<DIV ', , )              
cTexto := STRTRAN ( cTexto , '</body></html>', '', , )   
cTexto += '</DIV>'            

RETURN cTexto


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFS1001
Monta Consulta Padrao - S100
@sample 	VDFS1001()
@param
@return		xRet	.F. ou .F.
@author	    Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function  VDFS1001()

Local aArea     := GetArea()
Local bFilterPEK:= { || .T. }
Local cFilter   := ""
Local cCons 	:= ""
Local cCpoRet 	:= ""
Local cConteud 	:= ""
Local nCPn      := 0                        //variavel utilizada quando é aberta mais de uma getdados ao mesmo tempo
Local cQuery    := ''                 		// Variavel da query
Local xRet

If lSubsTp
	cQuery  += "SELECT DISTINCT(SUBSTRING(RCC.RCC_CONTEU,1,3))CODIGO,"
	cQuery  += " SUBSTRING(RCC.RCC_CONTEU,4,30) DESCRI "
Else
	cQuery  += "SELECT DISTINCT(SUBSTR(RCC.RCC_CONTEU,1,3))CODIGO,"
	cQuery  += " SUBSTR(RCC.RCC_CONTEU,4,30) DESCRI "
EndIf
cQuery  += " FROM " + RetSqlName( 'RI6' ) + " RI6," + RetSqlName( 'RCC' ) + " RCC "
cQuery  += " LEFT JOIN " + RetSqlName( 'RCC' ) + " RCC1 ON RCC1.D_E_L_E_T_ = ' '"
cQuery  += " AND RCC1.RCC_CODIGO='S101' "
cQuery  += " WHERE RCC.RCC_CODIGO='S100' "
cQuery  += " AND RCC.D_E_L_E_T_= ' ' "
cQuery  += " AND RI6.D_E_L_E_T_= ' ' "
cQuery  += " AND RI6_ANO = ' ' AND RI6_NUMDOC= ' '"
cQuery  += " AND RI6_FILIAL= '" + FWxFilial("RI6") +"'"
If lSubsTp
	cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,1,3) = SUBSTRING(RCC1.RCC_CONTEU,33,3) "
	cQuery  += " AND RI6_TIPDOC =SUBSTRING(RCC.RCC_CONTEU,1,3)"
Else
	cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,1,3) = SUBSTR(RCC1.RCC_CONTEU,33,3) "
	cQuery  += " AND RI6_TIPDOC =SUBSTR(RCC.RCC_CONTEU,1,3)"
Endif
cQuery  += " Order By CODIGO "
dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
dbSelectArea("TRB")

While TRB->(!EOF())
	cConteud := cConteud + (TRB->codigo+';')
	TRB->(DBSKIP())
EndDo
TRB->( dbCloseArea() )

cCpoRet := "BR1_S10001"
cCons   := "S100"
cFilter := "{ || Substr(RCC->RCC_CONTEU,1,3) $  '" + cConteud + "' }"
bFilterPEK := &cFilter

// n - variável de posicionamento do objeto GetDados
// o trecho abaixo controla para que não haja conflito entre 2 GetDados, caso seja
// disparada uma consulta F3 entre 2 tabelas. Ex.: S008 faz consulta em S016
If Type('n') =="N"
	nCpn := n
EndIf

xRet := Gp310SXB(cCons, cCpoRet, bFilterPEK )

If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
	VAR_IXB := &__READVAR
Endif

If nCpn > 0
	n := nCpn
EndIf

If ValType(xRet) <> "L"
	xRet := .F.
EndIf

RestArea( aArea )
Return xRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD020VLDTD
Valida tipo de documento
@sample 	VD020VLDTD()
@param		cTpdoc - tipo do documento
@return	T ou F
@author	Nivia Ferreira
@since		02/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD020VLDTD(cTpdoc)
Local cRet  	:= .T.
Local aArea 	:= GetArea()
Local cQuery	:= ''                 		// Variavel da query

If lSubsTp
	cQuery  += "SELECT DISTINCT(SUBSTRING(RCC.RCC_CONTEU,1,3))CODIGO,"
	cQuery  += " SUBSTRING(RCC.RCC_CONTEU,4,30) DESCRI "
Else
	cQuery  += "SELECT DISTINCT(SUBSTR(RCC.RCC_CONTEU,1,3))CODIGO,"
	cQuery  += " SUBSTR(RCC.RCC_CONTEU,4,30) DESCRI "
EndIf
cQuery  += " FROM " + RetSqlName( 'RI6' ) + " RI6," + RetSqlName( 'RCC' ) + " RCC "
cQuery  += " LEFT JOIN " + RetSqlName( 'RCC' ) + " RCC1 ON RCC1.D_E_L_E_T_ = ' '"
cQuery  += " AND RCC1.RCC_CODIGO='S101' "
cQuery  += " WHERE RCC.RCC_CODIGO='S100' "
cQuery  += " AND RCC.D_E_L_E_T_ = ' ' "
cQuery  += " AND RI6.D_E_L_E_T_ = ' ' "
cQuery  += " AND RI6_FILIAL= '" + FWxFilial("RI6") +"'"
If lSubsTp
	cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,1,3) = SUBSTRING(RCC1.RCC_CONTEU,33,3) "
	cQuery  += " AND RI6_TIPDOC =SUBSTRING(RCC.RCC_CONTEU,1,3)"
	cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,1,3)='" +cTpdoc +"'"	
Else
	cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,1,3) = SUBSTR(RCC1.RCC_CONTEU,33,3) "
	cQuery  += " AND RI6_TIPDOC =SUBSTR(RCC.RCC_CONTEU,1,3)"
    cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,1,3)='" +cTpdoc +"'"		
Endif
cQuery  += " Order By CODIGO "
dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
dbSelectArea("TRB")

If TRB->(EOF())                                              
	MsgInfo(STR0015, '')//'Tipo de documento invalido.'
	cRet  := .F.
Endif
TRB->( dbCloseArea() )

RestArea( aArea )
Return(cRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFMBRAN
Inclui linha em branco
@sample 	VDFMBRAN(cTexto)
@param		cTexto 	Texto para incluir linha em branco.  
            cTipo   T-texto ou P-publicacao
@return		cTexto  Texto com linha em branco.
@author	    Nivia Ferreira
@since		17/06/2013
@version	P11.8
/*/                
//------------------------------------------------------------------------------
FUNCTION VDFMBRAN(cTexto,cTipo)
       
Local cTextoF := ''
Local cCentro := '<p align="center" dir="ltr"></p>'
Local cJustif := '<p align="justify" dir="ltr">'
Local cDireito:= '<p align="right" dir="ltr">'
Local cEsquerd:= '<p align="left" dir="ltr">'
Local cOutro  := '<p dir="ltr"></p>'
Local cReplace:= '<br>'
Local cQuebra := '<meta name="qrichtext" content="1" />'
Local cHtabI  := '<tr><td>'
Local cRtabI  := '<tr>' 

Local cHtabF  := '</table>'
Local cRtabF  := '</tr>' 
 
Local cRtab1  := '</p>'
Local cRtab2  := '</body></html>'              
Local cRtab3  := '<html><body style="font-size:-1pt;font-family:Arial">'
Local cRtab4  := '<p dir="ltr"><table border=1 bordercolor=BLACK cellspacing=0 >'  
  
Local cRtab5  := '<p dir='
Local cHtab5  := '<td ><p dir'    
Local cRtab6  := '</td><td>'
Local cHtab6  := '</p></td>' 
Local cRtab7  := '<p align='
Local cHtab7  := '<td ><p align=' 
Local cRtab8  := "'"
Local cHtab8  := '"' 

Local cCab1   := '</table>'
Local cCab2   := '</p>'
Local cCab3   := '</body></html>'
Local cCab4   := '<tr><td>'
Local cCab41  := '<tr>'
Local cTodos  := 'HTML: <META NAME="qrichtext" CONTENT="1">'
                                 
If cTipo=='H' //Historico no formato de Itens
   cTexto := STRTRAN ( cTexto , cHtabI  , cRtabI , , )
   cTexto := STRTRAN ( cTexto , cHtabF  , cRtabF , , )  
   cTexto := STRTRAN ( cTexto , cRtab1  , ''     , , )  
   cTexto := STRTRAN ( cTexto , cRtab2  , ''     , , )        
   cTexto := STRTRAN ( cTexto , cRtab3  , ''     , , )        
   cTexto := STRTRAN ( cTexto , cRtab4  , ''     , , )             
   cTexto := STRTRAN ( cTexto , cRtab5  , cHtab5 , , )             
   cTexto := STRTRAN ( cTexto , cRtab6  , cHtab6 , , )                   
   cTexto := STRTRAN ( cTexto , cRtab7  , cHtab7 , , ) 
   cTexto := STRTRAN ( cTexto , cRtab8  , cHtab8 , , )
   cTexto := STRTRAN ( cTexto , cTodos  , ''      , , )
ElseIf cTipo=='C'  //Cabeçalho
   	   cTexto := STRTRAN ( cTexto , cCab1  , '</tr>' ,  , )
       cTexto := STRTRAN ( cTexto , cCab2  , '' ,  , )  
       cTexto := STRTRAN ( cTexto , cCab3  , '' ,  , )  
       cTexto := STRTRAN ( cTexto , cCab4  , cCab41 , , )               
       cTexto := STRTRAN ( cTexto , cRtab5 , cHtab5 , , )                          
       cTexto := STRTRAN ( cTexto , cRtab6 , cHtab6 , , )                                 
       cTexto := STRTRAN ( cTexto , cRtab7 , cHtab7 , , )
ElseIf cTipo=='R'  //Rodape
       cTexto := STRTRAN ( cTexto , cTodos  , ''      , , )
   	   cTextoF:= cCab1+cCab2+cCab3+cTexto
       cTexto := cTextoF
Else
	If cTipo=='P'
	   cTexto := STRTRAN ( cTexto , cCentro  , cReplace , , )
	   cTexto := STRTRAN ( cTexto , cJustif  , cReplace , , )
	   cTexto := STRTRAN ( cTexto , cDireito , cReplace , , )
	   cTexto := STRTRAN ( cTexto , cEsquerd , cReplace , , )
	   cTexto := STRTRAN ( cTexto , cOutro   , cReplace , , )
	   cTexto := STRTRAN ( cTexto , cRtab8   , cHtab8   , , )
       cTexto := STRTRAN ( cTexto , cTodos   , ''       , , )	   
	Endif
Endif

cTexto := STRTRAN ( cTexto , cQuebra  , '' , , )	

RETURN(cTexto)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD210CBCRD
Tratamento do arquivo cabeçalho e rodape.
@sample 	VD210CBCRD(cFileOpen,aS100)
@param		cFileOpen	Nome do arquivo texto. 
            cTexto     texto para ser substituido
			aTab		array com as substituições
@return	cRetorno  	Texto com as devidas alterações.
@author	Nivia Ferreira
@since		07/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD210CBCRD(cFileOpen,cTexto,aTab)
Local cbuffer	:= ""
Local cData 	:= ""
Local aMes   	:= {}
Local dDataAtu 	:= date()                                                     
                           
aMes := {{'01',STR0016}, {'02',STR0017},{'03',STR0018},  {'04','Abril'},;//'Janeiro'//'Fevereiro'//'Março'
         {'05',STR0022},    {'06',STR0021},    {'07',STR0020},   {'08',STR0019},;//'Agosto'//'Julho'//'Junho'//'Maio'
         {'09',STR0024},{'10',STR0023}  ,{'11',STR0025},{'12',STR0026}}    //'Outubro'//'Setembro'//'Novembro'//'Dezembro'
         
cData:= Alltrim(STR(DAY(dDataAtu))+' de '+ aMes[MONTH(dDataAtu),2]+' de '+ Alltrim(STR(YEAR(dDataAtu)))+'.')          
                             
If !Empty(cFileOpen)
	FT_FUSE(cFileOpen)         //ABRIR
	FT_FGOTOP()                //PONTO NO TOPO    

	While !FT_FEOF()
		IncProc()
		cbuffer  := cbuffer+ FT_FREADLN()
		FT_FSKIP()
	endDo
	FT_FUSE()
	cbuffer := STRTRAN ( cbuffer , "{*[S10003]*}" 	, aTab[1,2] , , )
	cbuffer := STRTRAN ( cbuffer , "{*[S10004]*}" 	, aTab[2,2] , , )	
	cbuffer := STRTRAN ( cbuffer , "{*[data]*}"   	, cData     , ,)	
	cbuffer := STRTRAN ( cbuffer , "{*[assinatura]*}", AllTrim(M->RA_PROC_N), ,)	
	cbuffer := STRTRAN ( cbuffer , "{*[assinatura_cargo]*}", AllTrim(M->Q3_DESCS_P), ,)	
	
	cbuffer := VD210Macro(cBuffer)
Else                      
	cbuffer := cTexto
	cbuffer := STRTRAN ( cbuffer , "{*[XDOC]*}"   , aTab[1,2] , , ) 
	cbuffer := STRTRAN ( cbuffer , "{*[XANO]*}"   , aTab[2,2] , , )	      
Endif	
                                                                     
Return(cbuffer)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF_Direct
Veririfca se existe pasta, se nao vai criar.
@sample 	VDF_Direct( cPath, lDrive, lMSg )
@return	 lRet .t. ou .f.
/*/
//------------------------------------------------------------------------------
Function VDF_Direct( cPath, lDrive, lMSg )
Local aDir
Local lRet	 := .T.
Default lMSg := .T.
 
If Empty(cPath)
	Return lRet
EndIf
 
lDrive := If(lDrive == Nil, .T., lDrive)
 
cPath := Alltrim(cPath)
If Subst(cPath,2,2) <> ":" .AND. lDrive
	MsgInfo(STR0039) //Unidade de drive não especificada
	lRet:=.F.
Else
	cPath := If(Right(cPath,1) == "", Left(cPath,Len(cPath)-1), cPath)
	aDir  := Directory(cPath,"D")
	If Len(aDir) = 0
		If lMSg
			If MsgYesNo(STR0040 +cPath+ STR0041) //Diretorio  -  nao encontrado, deseja cria-lo
				If MakeDir(cPath) <> 0
				   MsgInfo(STR0042)
					lRet := .F.
				EndIf
			EndIf
		Else
			If MakeDir(cPath) <> 0
				MsgInfo(STR0042)
				lRet := .F.
			EndIf
		EndIF
	EndIf
EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} AcentHtml
Troca acentuacao no html
@sample 	AcentHtml(cTxt)
@return	 cTxt
/*/
//------------------------------------------------------------------------------
Function AcentHtml(cTxt)

Local nT := 0
Local aAcentos := {}

aadd(aAcentos,{"Á","&Aacute;"})
aadd(aAcentos,{"á","&aacute;"})
aadd(aAcentos,{"Â","&Acirc;"})
aadd(aAcentos,{"â","&acirc;"})
aadd(aAcentos,{"À","&Agrave;"})
aadd(aAcentos,{"à","&agrave;"})
aadd(aAcentos,{"Å","&Aring;"})
aadd(aAcentos,{"å","&aring;"})
aadd(aAcentos,{"Ã","&Atilde;"})
aadd(aAcentos,{"ã","&atilde;"})
aadd(aAcentos,{"Ä","&Auml;"})
aadd(aAcentos,{"ä","&auml;"})
aadd(aAcentos,{"Æ","&AElig;"})
aadd(aAcentos,{"æ","&aelig;"})
aadd(aAcentos,{"É","&Eacute;"})
aadd(aAcentos,{"é","&eacute;"})
aadd(aAcentos,{"Ê","&Ecirc;"})
aadd(aAcentos,{"ê","&ecirc;"})
aadd(aAcentos,{"È","&Egrave;"})
aadd(aAcentos,{"è","&egrave;"})
aadd(aAcentos,{"Ë","&Euml;"})
aadd(aAcentos,{"ë","&euml;"})
aadd(aAcentos,{"Ð","&ETH;"})
aadd(aAcentos,{"ð","&eth;"})
aadd(aAcentos,{"Í","&Iacute;"})
aadd(aAcentos,{"í","&iacute;"})
aadd(aAcentos,{"Î","&Icirc;"})
aadd(aAcentos,{"î","&icirc;"})
aadd(aAcentos,{"Ì","&Igrave;"})
aadd(aAcentos,{"ì","&igrave;"})
aadd(aAcentos,{"Ï","&Iuml;"})
aadd(aAcentos,{"ï","&iuml;"})
aadd(aAcentos,{"Ó","&Oacute;"})
aadd(aAcentos,{"ó","&oacute;"})
aadd(aAcentos,{"Ô","&Ocirc;"})
aadd(aAcentos,{"ô","&ocirc;"})
aadd(aAcentos,{"Ò","&Ograve;"})
aadd(aAcentos,{"ò","&ograve;"})
aadd(aAcentos,{"Ø","&Oslash;"})
aadd(aAcentos,{"ø","&oslash;"})
aadd(aAcentos,{"Õ","&Otilde;"})
aadd(aAcentos,{"õ","&otilde;"})
aadd(aAcentos,{"Ö","&Ouml;"})
aadd(aAcentos,{"ö","&ouml;"})
aadd(aAcentos,{"Ú","&Uacute;"})
aadd(aAcentos,{"ú","&uacute;"})
aadd(aAcentos,{"Û","&Ucirc;"})
aadd(aAcentos,{"û","&ucirc;"})
aadd(aAcentos,{"Ù","&Ugrave;"})
aadd(aAcentos,{"ù","&ugrave;"})
aadd(aAcentos,{"Ü","&Uuml;"})
aadd(aAcentos,{"ü","&uuml;"})
aadd(aAcentos,{"Ç","&Ccedil;"})
aadd(aAcentos,{"ç","&ccedil;"})
aadd(aAcentos,{"Ñ","&Ntilde;"})
aadd(aAcentos,{"ñ","&ntilde;"})
aadd(aAcentos,{"®","&reg;"})
aadd(aAcentos,{"©","&copy;"})
aadd(aAcentos,{"Ý","&Yacute;"})
aadd(aAcentos,{"ý","&yacute;"})
aadd(aAcentos,{"Þ","&THORN;"})
aadd(aAcentos,{"þ","&thorn;"})
aadd(aAcentos,{"ß","&szlig;"})
aadd(aAcentos,{"°","&deg;"})
aadd(aAcentos,{"º","&ordm;"})
aadd(aAcentos,{"ª","&ordf;"})
aadd(aAcentos,{"§","&sect;"})

For nT := 1 to len(aAcentos)
	cTxt := STRTRAN ( cTxt , aAcentos[nT,1],aAcentos[nT,2], , )   
Next nT

Return(cTxt)


//------------------------------------------------------------------------------
/*/{Protheus.doc} f20ValResc
Verificação se a publicação é de Rescisão Contratual.
Utilização na Rotina de Rescisão Contratual, para publicação 
	antecipada de Rescisão Contratual futura.
@sample 	f20ValResc(cAno,cNumDoc,cTipDoc,dPublic)
@param		cAno	- Ano da publicação
            cNumDoc	- Número do Documento RI5 x RI6
			cTipDoc - Tipo do Documento para publicação 
			dPublic - Data da Publicação
@return		lRet
@author		Tânia Bronzeri
@since		30/04/2014
@version	P. 11.90
/*/
//------------------------------------------------------------------------------
Function f20ValResc(cAno,cNumDoc,cTipDoc,dPublic)
Local aAreaRcc		:= RCC->(GetArea())
Local aAreaRI5		:= RI5->(GetArea())
Local aAreaRI6		:= RI6->(GetArea())
Local cAliasRcc		:= GetNextAlias()
Local cSubstr		:= Iif(lSubsTp,"%Substring%","%Substr%")
Local cS100			:= "%'S100'%"
Local cS101			:= "%'S101'%" 
Local cGpem040		:= "%'%GPEM040%'%" 
Local cQTpDoc		:= "%'" + cTipDoc + "'%"
Local cQAno			:= "%'" + cAno    + "'%" 
Local cQNumDoc		:= "%'" + cNumDoc + "'%"  
Local cAssunto		:= OemToAnsi(STR0065)	//"Liberação de Membro/Servidor para Cálculo de Rescisão Contratual"
Local cRespDgp		:= SuperGetMv("MV_VDFDGP" )
Local cMsgRet     	:= ""
Local cMens	    	:= ""
Local aErro			:= {}
Local lRet			:= .T.
Local nX			:= 0                                 

Default dPublic	:= CtoD("  /  /  ")

BeginSql alias cAliasRcc
	Column RA_DEMISSA as Date
	Column RA_APOSENT as Date
	Column RI6_DTEFEI as Date
	Select 	RI5.RI5_FILIAL, RI5.RI5_ANO   , RI5.RI5_NUMDOC, RI5.RI5_TIPDOC, RI6.RI6_FILMAT, RI6.RI6_MAT
		  , SRA.RA_NOME   , RI6.RI6_DTEFEI, RI6.RI6_DTCANC, RI6.RI6_STATUS, RI6.R_E_C_N_O_ RegRi6 
	From %table:RI5% RI5 
		Inner Join %table:RI6% RI6 On (RI5.%notDel% And RI6.%notDel% 
			And RI5.RI5_FILIAL = RI6.RI6_FILIAL
			And RI5.RI5_ANO    = RI6.RI6_ANO
			And RI5.RI5_NUMDOC = RI6.RI6_NUMDOC
			And RI5.RI5_TIPDOC = RI6.RI6_TIPDOC
			And RI6.RI6_STATUS != '4')
		Inner Join (
			Select distinct %exp:cSubstr%(RCC1.RCC_CONTEU,1,2) CLASSIF
			From %table:RCC% RCC                                               
				Left Join %table:RCC% RCC1 On RCC1.%notDel% And RCC.%notDel%
					And RCC1.RCC_CONTEU Like %exp:cGpem040% 
					And RCC1.RCC_CODIGO = %exp:cS101%
			Where RCC.RCC_CODIGO = %exp:cS100% 
					And %exp:cSubstr%(RCC.RCC_CONTEU,1,3) =  %exp:cQTpDoc%) PUBL
			On RI6.RI6_CLASTP = PUBL.CLASSIF 
		Inner Join %table:SRA% SRA On SRA.%notDel% And RI6.RI6_FILMAT = SRA.RA_FILIAL
			And RI6.RI6_MAT = SRA.RA_MAT
	Where RI6.RI6_TIPDOC = %exp:cQTpDoc% 
		And RI6.RI6_ANO = %exp:cQAno%
		And RI6.RI6_NUMDOC = %exp:cQNumDoc%
	Order by RI5.RI5_NUMDOC
EndSql	

(cAliasRcc)->(DbGoTop())
If (cAliasRcc)->(!Eof()) 
	cMens	:= fVd20Email(	(cAliasRcc)->RI6_FILMAT	,;	//Filial do Membro/Servidor
							(cAliasRcc)->RI6_MAT	,;	//Matrícula do Membro/Servidor
			   				(cAliasRcc)->RA_NOME	,;	//Nome do Membro/Servidor
							(cAliasRcc)->RI6_DTEFEI	,;	//Data de Rescisão ou Aposentadoria
							dPublic					,;	//Data da Publicação da Rescisão Contratual
							(cAliasRcc)->RI5_ANO	,;	//Ano da Publicação			
							(cAliasRcc)->RI5_NUMDOC	,;	//Numero do Documento
							(cAliasRcc)->RI5_TIPDOC	 ;	//Tipo do Documento
							)	

    //Envia email para a área de Gestão de Pessoal
    aErro   := Vdf_EMail(cRespDgp, cAssunto, cMens, /*server*/, /*account*/, /*password*/, /*cAttach*/ ,cRespDgp)
    
    If len(aErro) > 0
       	cMsgRet := "" 
		For nX := 1 to len(aErro)
			cMsgRet +=  aErro[nX] + chr(13) + chr(10)
		Next nX
	   	MsgAlert(cMsgRet) 
        lRet := .F.
    EndIf

EndIf

RestArea(aAreaRI6)
RestArea(aAreaRI5) 
RestArea(aAreaRcc)

Return lRet   


//------------------------------------------------------------------------------
/*/{Protheus.doc} fVd20Email
Montagem do texto do e-mail ao DP para processamento da Rescisão.
Utilização na Rotina de Rescisão Contratual, para acionar  
	cálculo de Rescisão Contratual.
@sample 	fVd20Email(cFilMat, cMatric, cNome, dRescis, dPublic, cAno, cNumDoc, cTipDoc)
@param		cFilMat	- Filial do Membro/Servidor que está se desligando
			cMatric	- Matrícula do Membro/Servidor que está se desligando
			cNome	- Nome do Membro/Servidor que está se desligando
            dRescis	- Data da Rescisão para Cálculo
            dPublic	- Data de Publicação da Rescisão Contratual
            cAno	- Ano da Publicação
            cNumDoc	- Número do Documento da Publicação
            cTipDoc	- Tipo do Documento da Publicação
@return		cHtml

@author		Tânia Bronzeri
@since		30/04/2014
@version	P. 11.90
/*/
//------------------------------------------------------------------------------
Function fVd20Email(cFilMat, cMatric, cNome, dRescis, dPublic, cAno, cNumDoc, cTipDoc) 
Local cHtml		:= ""
Local cDesTip	:= fDescRcc("S100",cTipDoc,1,3,4,30)

cHtml	+= '<html>'
cHtml	+= '<head>'
cHtml	+= '<meta http-equiv=Content-Type content="text/html; charset=unicode">'
cHtml	+= '</head>'
cHtml	+= '<body>'
cHtml	+= '<br>'
cHtml	+= '<p><span style="font-size:20.0pt"><b>' + OemToAnsi(STR0099) + '</b></span></p>'	//"Liberação para cálculo de Rescisão"
cHtml	+= '<br>'
cHtml	+= '<table style="border:2px solid black;">'
cHtml	+= '<tr>'
cHtml	+= '<td style="border:1px solid black;padding: 10px"><b>' + OemToAnsi(STR0100) + '</b></td>'	//"Nome"
cHtml	+= '<td style="border:1px solid black;padding: 10px">' + AllTrim(OemToAnsi(cNome)) + '</td>'
cHtml	+= '</tr>'
cHtml	+= '<tr>'
cHtml	+= '<td style="border:1px solid black;padding: 10px"><b>' + OemToAnsi(STR0068) + '</b></td>'	//"Matrícula"
cHtml	+= '<td style="border:1px solid black;padding: 10px">' + AllTrim(OemToAnsi(cMatric)) + '</td>'
cHtml	+= '</tr>'
cHtml	+= '<tr>'
cHtml	+= '<td style="border:1px solid black;padding: 10px"><b>' + OemToAnsi(STR0069) + '</b></td>'	//"Data de Rescisão"
cHtml	+= '<td style="border:1px solid black;padding: 10px">' + OemToAnsi(DtoC(dRescis)) + '</td>'
cHtml	+= '</tr>'
cHtml	+= '<tr>'
cHtml	+= '<td style="border:1px solid black;padding: 10px"><b>' + OemToAnsi(STR0070) + '</b></td>'	//"Data da Publicação"
cHtml	+= '<td style="border:1px solid black;padding: 10px">' + OemToAnsi(DtoC(dPublic)) + '</td>'
cHtml	+= '</tr>'
cHtml	+= '<tr>'
cHtml	+= '<td style="border:1px solid black;padding: 10px"><b>' + OemToAnsi(STR0071) + '</b></td>'	//"Doc. de Publicação"
cHtml	+= '<td style="border:1px solid black;padding: 10px">' + cDesTip + "/" + cNumDoc + "/" + cAno + '</td>'
cHtml	+= '</tr>'
cHtml	+= '</table>'
cHtml	+= '</body>'
cHtml	+= '</html>'
cHtml := AcentHtml(cHtml)
Return cHtml


//------------------------------------------------------------------------------
/*/{Protheus.doc} vGETMV
Retorno de parametros por filial
@return	Null
@author	Wagner Mobile Costa
@since		24/06/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function vGetMV(cX6_FIL, cX6_VAR, cX6_CONTEUD)

Local aArea := GetArea()

DbSelectArea("SX6")
DbSetOrder(1)
If DbSeek(cX6_FIL + cX6_VAR)
	cX6_CONTEUD := SX6->X6_CONTEUD 
EndIf

RestArea(aArea)

Return cX6_CONTEUD


//------------------------------------------------------------------------------
/*/{Protheus.doc} vPUTMV
Atualização de parametro por filial
@return	Null
@author	Wagner Mobile Costa
@since		24/06/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function vPutMv(cX6_FIL, cX6_VAR, cX6_TIPO, aX6_DESCRIC, cX6_CONTEUD)

Local aArea := GetArea()

DbSelectArea("SX6")
DbSetOrder(1)
If DbSeek(cX6_FIL + cX6_VAR)
	PutMV("cX6_VAR",cX6_CONTEUD)
EndIf

RestArea(aArea)

Return
