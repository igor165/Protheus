#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "FATA500.CH"
#INCLUDE 'FWMVCDEF.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATA500   ºAutor  ³Vendas Clientes     º Data ³  22/11/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina usada para realizar manuetenção na tabela CC3.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FATA500                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FATA500(aCC3Master,nOperation)

Local oBrowse	:= Nil
Local oModel	:= Nil
Local aAutoRot	:= {}

Private cCadastro	:= STR0001	//"Manutencao  - CNAE" 

Default aCC3Master	:= {}
Default nOperation	:= MODEL_OPERATION_INSERT

If Empty( aCC3Master ) 
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('CC3')                                       
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()
Else
	oModel := ModelDef()
	aAdd(aAutoRot,{"CC3MASTER",aCC3Master})
	FwMvcRotAuto(oModel,'CC3',nOperation,aAutoRot,/*lSeek*/,.T.) 
EndIf

Return .T.       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Vendas CRM          º Data ³  22/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina usada para realizar manuetenção na tabela CC3       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  SIGAFAT                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
				  
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FATA500'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FATA500'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FATA500'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA500'	OPERATION 5	ACCESS 0				
					
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ModelDef  ºAutor  ³Vendas CRM          º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define o modelo de dados do grupo de atendimento (MVC)      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FATA500                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()

Local oModel	:= Nil
Local oStruCC3	:= FWFormStruct(1,'CC3', /*bAvalCampo*/,/*lViewUsado*/ )
Local bPosValid	:= {| oModel | FT500PValid( oModel ) }		//Gravacao dos dados

oModel := MPFormModel():New('FATA500', /*bPreValidacao*/,bPosValid,/*bCommit*/,/*bCancel*/)
oModel:AddFields('CC3MASTER',/*cOwner*/,oStruCC3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey({'CC3_FILIAL'},{'CC3_COD'})
oModel:SetDescription(STR0001)

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   ºAutor  ³Vendas CRM          º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define a interface para cadastro de grupo de atendimento em º±±
±±º          ³MVC.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FATA500                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()   

Local oView	  	:= Nil
Local oModel	:= FWLoadModel('FATA500')
Local oStruCC3	:= FWFormStruct( 2,'CC3')  
   
oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_CC3',oStruCC3,'CC3MASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_CC3','TELA') 
  
Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FT500PValid º Autor  ³Vendas CRM         º Data ³  21/09/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Bloco executado na validacao dos dados do formulario.		  ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FATA500                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FT500PValid( oModel )

Local lRetorno 		:= .T.
Local aArea			:= GetArea()
Local nOperation	:= oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE
	lRetorno := FT500VdDel("CC3", CC3->( Recno() ), nOperation)
EndIf

RestArea( aArea )

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FT500VdDel ºAutor  ³Vendas Clientes     º Data ³  22/11/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina usada para valida a exclusao de registros do CNAE.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFAT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FT500VdDel(cAlias, nReg, nOpc)

Local cTemp		:= GetNextAlias()
Local lDeleta	:= .T.
Local aArea		:= GetArea()
Local cCodCNAE	:= CC3->CC3_COD
Local aRelac	:= {}
Local nX		:= 0
Local cQuery	:= "" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta lista de campos e tabelas que se relacionam com o³
//³CNAE, onde:                                            ³
//³[1] = Alias                                            ³
//³[2] = Campo que referencia o codigo do cnae            ³
//³[3] = Indice pelo campo do CNAE, quando houver (so DBF)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aRelac,{"ACH", "ACH_CNAE"	, Nil}) 
AAdd(aRelac,{"SUS", "US_CNAE"	, Nil})
AAdd(aRelac,{"SA1", "A1_CNAE"	, Nil})

For nX := 1 To Len( aRelac )
	If lDeleta .And. (aRelac[nX][1])->(FieldPos(aRelac[nX][2])) > 0
		cQuery	:= "SELECT COUNT (*) AS TOTAL FROM " + RetSqlName(aRelac[nX][1])
		cQuery	+= " WHERE D_E_L_E_T_ = '' AND " + aRelac[nX][2] + " = '" + cCodCNAE + "'" 
		cQuery := ChangeQuery( cQuery )
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cTemp,.T.,.T.)
		
		If (cTemp)->TOTAL > 0
			lDeleta := .F.
		EndIf
		
		(cTemp)->( DBCloseArea() )
	EndIf
Next nX 

If !lDeleta
	Help(" ",1,"NODELETA",,STR0007 + CRLF + STR0008,2,0)//"Este registro está associado a algum outro"###" cadastro"
EndIf

Return( lDeleta )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft500Psq  ºAutor  ³Vendas Clientes     º Data ³  22/11/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tela para que seja informada a palavra a ser         º±±
±±º          ³ pesquisada.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFAT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ft500Psq()

Local aArea		:= GetArea()
Local cPesquisa	:= Space(100)
Local cQualCnae	:= Space(9)
Local lRet		:= .F.
Local oDlg		:= Nil

DEFINE MSDIALOG oDlg TITLE STR0009 From 000,000 TO 100,380 OF oMainWnd PIXEL //"CNAE - Pesquisa Avançada"

@ 004,002 TO 030,190 TITLE STR0010 //"Informe a palavra a ser pesquisada:"

@ 012,004 Get cPesquisa Picture "@!" Size 184,10 Of Odlg Pixel 
	
@ 035,075 Button STR0011 Size 50,10 OF oDlg PIXEL Action Ft500Pesq(cPesquisa,@cQualCnae,@oDlg) //"&Confirma"
@ 035,135 Button STR0012 Size 50,10 OF oDlg PIXEL Action oDlg:End() //"Cance&la"
	
ACTIVATE MSDIALOG oDlg CENTER

RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o CC3 para que a pesquisa do SXB recupere o³
//³registro localizado pelo usuario                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cQualCnae)
	CC3->(DbSetOrder(1))
	If CC3->(DbSeek(xFilial("CC3")+cQualCnae))
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft500Pesq ºAutor  ³Vendas Clientes     º Data ³  22/11/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria query para que seja feita a pesquisa com a palavra    º±±
±±º          ³ informada e caso retorno seja verdadeiro mostra as         º±±
±±º          ³ ocorrencias encontrdas.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFAT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ft500Pesq(cPesquisa,cQualCnae,oDlg)

Local cTemp			:= GetNextAlias()
Local aCnae			:=	{}
Local nCnae			:=	1
Local oCnae			:= Nil	
Local nOcorrencia	:=	0
Local lRetorno 		:= .T.

cQuery := "SELECT CC3_COD,CC3_DESC FROM " + RetSqlName("CC3")
cQuery += " WHERE"
cQuery += " CC3_FILIAL = '" + xFilial("CC3") + "' AND"
cQuery += " D_E_L_E_T_ = ''"   

If !("DB2" $ TCGetDB())
	cQuery += " AND LOWER(CC3_DESC) LIKE '%"+AllTrim(RetSqlAce(cPesquisa))+"%'"
Else 
	cQuery += " AND UPPER(CC3_DESC) LIKE '%"+AllTrim(UPPER(cPesquisa))+"%'"
EndIf

cQuery := ChangeQuery( cQuery )

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cTemp,.T.,.T.)

While (cTemp)->( !Eof() )

	If !Empty(CC3_COD)
		Aadd(aCnae,{CC3_COD,CC3_DESC})
		nOcorrencia++
	Endif		

	(cTemp)->( DbSkip() )

EndDo

(cTemp)->( DbCloseArea() )

If	Len(aCnae)==0
    MsgAlert(STR0013,STR0014) //"Nenhuma Ocorrência encontrada com a palavra digitada."###
    lRetorno := .F.
Endif 

If lRetorno

	DEFINE MSDIALOG oDlgRe TITLE STR0015 From 200,001 TO 422,600 OF oMainWnd PIXEL //"Resultado da Pesquisa"
	
	@ 006,002 ListBox oCnae VAR nCnae Fields Header STR0016,STR0017 Size 295,080 PIXEL OF oDlgRe On dblClick(cQualCnae:=aCnae[oCnae:nAt][1],(oDlgRe:End()),Close(oDlg)) //"Código"###"Descrição"
	oCnae:SetArray(aCnae)
	oCnae:bLine :={|| {aCnae[oCnae:nAt][1],aCnae[oCnae:nAt][2]}}
	
	@ 098,040 SAY StrZero(nOcorrencia,6) + STR0018//" Ocorrência(s) encontrada(s)" 
	
	@ 096,180 Button STR0011 Size 50,10 Action (cQualCnae:=aCnae[oCnae:nAt][1],oDlgRe:End(),oDlg:End()) //"&Confirma"
	@ 096,240 Button STR0019 Size 50,10 Action (Close(oDlgRe),DbCloseArea()) //"&Retonar"
	
	ACTIVATE Dialog oDlgRe CENTERED

EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft500FOk     ºAutor  ³Vendas Clientes  º Data ³  21/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria pesquisa no SXB                                        º±±
±±º          |                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFAT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ft500FOk()
 
Local nPCod  := aScan(aHeader,{|x|AllTrim(x[2])=="CCG_DIVISA"})
Local nPDesc := aScan(aHeader,{|x|AllTrim(x[2])=="CCG_DESC"})
Local cDescri:= ""
 
If AllTrim(ReadVar()) == "M->CCG_DIVISA
    cDescri := Posicione("CDI",1,xFilial("CDI")+M->CCG_DIVISA,"CDI_DESCRI")
    If Empty(cDescri)
    	Aviso( STR0014, STR0021, { STR0022 }, 2 )    //"ATENCAO"###"Codigo de Divisão CNAE Inexistente"###"Ok"
    	aCols[n][nPCod]  := Space(TamSX3("CCG_DIVISA")[1])
    	aCols[n][nPDesc] := Space(TamSX3("CCG_DESC")[1])
        Return .F.
     Else
        aCols[n][nPDesc] := cDescri
    Endif
EndIf
 
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft500Cod     ºAutor  ³Vendas Clientes  º Data ³  21/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os campo de descricao                              º±±
±±º          |                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFAT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ft500Cod(cCod)

Local lRet		:= .T.
Local cCDIVIS	:=	""
Local cCGRUPO	:=	""
Local cCCLASS	:=	""
Local aArea     := CC3 ->(GetArea())
Local oMdl      := Nil
Local oMdlCC3   := Nil

DbselectArea("CCG")
DbSetOrder(1)

If Inclui
	oMdl    := FWModelActive()
	If oMdl <> Nil
		oMdlCC3 := oMdl:GetModel('CC3MASTER')
	EndIf
	If oMdlCC3 <> Nil
		cCDIVIS	:= Substr(cCod,1,2)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)))
		If DbSeek(xFilial("CCG")+cCDIVIS)
		  	oMdlCC3:SetValue("CC3_CDIVIS",Alltrim(CCG->CCG_COD))
		   oMdlCC3:SetValue("CC3_DDIVIS",CCG->CCG_DESC)
		EndIf
	
		cCGRUPO	:=Substr(cCod,1,2)+Substr(cCod,3,1)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)+Substr(cCod,2,1)))
		If DbSeek(xFilial("CCG")+cCGRUPO)
		   oMdlCC3:SetValue("CC3_CGRUPO",Alltrim(CCG->CCG_COD))
		   oMdlCC3:SetValue("CC3_DGRUPO",CCG->CCG_DESC)
		EndIf
	
		cCCLASS	:=Substr(cCod,1,2)+Substr(cCod,3,2)+Substr(cCod,6,1)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)+Substr(cCod,2,2)+Substr(cCod,6,1)))
		If DbSeek(xFilial("CCG")+cCCLASS)
		   oMdlCC3:SetValue("CC3_CCLASS",Alltrim(CCG->CCG_COD))
		   oMdlCC3:SetValue("CC3_DCLASS",CCG->CCG_DESC)
		EndIf
	Else
		//Se estiver incluindo um CNAE pelo Cadastro de Cliente via consulta F3.
		cCDIVIS	:= Substr(cCod,1,2)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)))
		If DbSeek(xFilial("CCG")+cCDIVIS)
		   M->CC3_CDIVIS    :=CCG->CCG_COD
		   M->CC3_DDIVIS	:=CCG->CCG_DESC
		EndIf
	
		cCGRUPO	:=Substr(cCod,1,2)+Substr(cCod,3,1)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)+Substr(cCod,2,1)))
		If DbSeek(xFilial("CCG")+cCGRUPO)
		   M->CC3_CGRUPO	:=CCG->CCG_COD
		   M->CC3_DGRUPO	:=CCG->CCG_DESC
		EndIf
	
		cCCLASS	:=Substr(cCod,1,2)+Substr(cCod,3,2)+Substr(cCod,6,1)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)+Substr(cCod,2,2)+Substr(cCod,6,1)))
		If DbSeek(xFilial("CCG")+cCCLASS)
		   M->CC3_CCLASS	:=CCG->CCG_COD
		   M->CC3_DCLASS	:=CCG->CCG_DESC
		EndIf
	EndIf
Endif

RestArea(aArea) 

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft500Gth     ºAutor  ³Vendas Clientes  º Data ³  21/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os campo de descricao                              º±±
±±º          |                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFAT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ft500Gth(cCod,ctipo)

Local lRet	:= .T.            
Local aArea := GetArea()

cCod:= cCod+SPACE(TamSX3("CCG_COD")[1]-Len(cCod))

DbselectArea("CCG")
DbSetOrder(1)

If DbSeek(xFilial("CCG")+cCod+ctipo)
   If 		ctipo = "1"
      M->CC3_DSECAO	:=CCG->CCG_DESC
   ElseIf 	ctipo = "2"   
      M->CC3_DDIVIS	:=CCG->CCG_DESC
   ElseIf 	ctipo = "3"   
      M->CC3_DGRUPO	:=CCG->CCG_DESC
   ElseIf 	ctipo = "4"   
      M->CC3_DCLASS	:=CCG->CCG_DESC
   Endif
Endif

RestArea(aArea)

Return lRet
