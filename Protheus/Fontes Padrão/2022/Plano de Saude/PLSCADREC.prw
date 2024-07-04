#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "PLSCADREC.CH"
		
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSCADREC   บAutor  ณMicrosiga           บ Data ณ  09/18/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de receitas						                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE VERSAO 11.5                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function PLSCADREC(cMatric)
Local oBrowse
default cMatric := ""

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B4F' )
oBrowse:SetDescription(STR0001) //'Cadastro de Receitas'
if(!empty(cMatric))
	//FILTRA PELO CำDIGO DA FAMILIA
	oBrowse:SetFilterDefault( "B4F_CODFAM == '" + cMatric + "' " )
endIf
oBrowse:setMainProc("PLSCADREC")
oBrowse:Activate()

Return( NIL )

//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

aAdd( aRotina, { STR0002 /*'Pesquisar'*/ , 				'PesqBrw'         , 0, 1, 0, .T. } )
aAdd( aRotina, { STR0003 /*'Visualizar'*/, 				'VIEWDEF.PLSCADREC', 0, 2, 0, NIL } )
aAdd( aRotina, { STR0004 /*'Incluir'*/   , 				'VIEWDEF.PLSCADREC', 0, 3, 0, NIL } ) 
aAdd( aRotina, { STR0005 /*'Alterar'*/   , 				'VIEWDEF.PLSCADREC', 0, 4, 0, NIL } ) 
aAdd( aRotina, { STR0006 /*'Excluir'*/   , 				'VIEWDEF.PLSCADREC', 0, 5, 0, NIL } )
aAdd( aRotina, { STR0007 /*'Imprimir'*/  , 				'VIEWDEF.PLSCADREC', 0, 8, 0, NIL } )

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

STATIC oModelRec

// Cria o objeto do Modelo de Dados

Local oStrB4F := FWFormStruct(1,'B4F')
Local oStrB7D := FWFormStruct(1,'B7D')
Local bWhen := NIL 

oModelRec := MPFormModel():New( 'PLSCADREMD', , {|oModel|RelB1NB4F(oModel)}/*bPosValidacao*/, {|oModel| PLSANXREC(oModel)}/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModelRec:AddFields( 'B4FMASTER', NIL, oStrB4F )
oModelRec:SetPrimaryKey( { "B4F_FILIAL", "B4F_CODREC" } )

// Faz relaciomaneto entre os compomentes do model
oModelRec:addGrid('B7DDETAIL','B4FMASTER',oStrB7D,,{ || ValInterDt()})
oModelRec:SetRelation('B7DDETAIL', { { 'B7D_FILIAL', 'xFilial( "B7D" )'  }, { 'B7D_CODREC', 'B4F_CODREC' } }, B7D->(IndexKey(3)) )

// Adiciona a descricao do Modelo de Dados
oModelRec:SetDescription( STR0001 /*'Cadastro de Receitas'*/ )

// Adiciona a descricao do Componente do Modelo de Dados
oModelRec:GetModel( 'B4FMASTER' ):SetDescription( STR0001 /*'Cadastro de Receitas'*/ )
oModelRec:GetModel( 'B7DDETAIL' ):SetDescription( STR0009 /*'Medicamentos'*/ ) 

//Valida se existem codigos duplicados no aCols
oModelRec:GetModel('B7DDETAIL'):SetUniqueLine( {'B7D_CODPAD','B7D_CODMED','B7D_DTVINI'} )

B1N->(DbSetOrder(4)) 
If B1N->(MsSeek(xFilial("B1N") + B4F->B4F_CODREC))
	
	bWhen := FWBuildFeature( STRUCT_FEATURE_WHEN, "INCLUI" )
	
	oStrB4F:SetProperty( 'B4F_DESCRI' , MODEL_FIELD_WHEN, bWhen)
	oStrB4F:SetProperty( 'B4F_MATRIC' , MODEL_FIELD_WHEN, bWhen)
	oStrB4F:SetProperty( 'B4F_DATINI' , MODEL_FIELD_WHEN, bWhen)
	oStrB4F:SetProperty( 'B4F_DATFIN' , MODEL_FIELD_WHEN, bWhen)

EndIf 

Return oModelRec

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStrB7D := FWFormStruct( 2, 'B7D' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSCADREC' )
Local oStruB4F := FWFormStruct(2, 'B4F')
Local oView    := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado

oView:SetModel( oModel )
oView:AddField('B4F' , oStruB4F,'B4FMASTER' )
oView:AddGrid('VIEW_B7D' , oStrB7D,'B7DDETAIL')

oView:CreateHorizontalBox( 'BOX1', 50)
oView:CreateVerticalBox( 'FORMB4F', 100, 'BOX1')
oView:CreateHorizontalBox( 'BOX4', 50)
oView:CreateFolder( 'FOLDER5', 'BOX4')

oView:AddSheet('FOLDER5','B7DDETAIL',STR0009 /*'Medicamentos'*/)

oView:CreateHorizontalBox( 'FORMB7D', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'B7DDETAIL')

oView:SetOwnerView('B4F','FORMB4F')
oView:SetOwnerView('VIEW_B7D','FORMB7D')

// Define campos que terao Auto Incremento
oView:AddIncrementField('VIEW_B7D', 'B7D_SEQUEN' )

//REMOVE O CAMPO DA TELA

oStrB7D:RemoveField('B7D_CODREC')
oStrB7D:RemoveField('B7D_BENEFI')
oStruB4F:RemoveField('B4F_CODFAM')

//Adiciona botใo de conhecimento
oView:AddUserButton("Anexos", "CLIPS", {|| PLSANRCTANEXO(oModel)  } )//"Anexos"

Return oView

/*ษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetCodPad()   บAutor  ณThiago Guilherme   บ Data ณ  28/05/15บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o codPad para a consulta padrใo CODMED             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION RetCodPad()

oModelRec := FwModelActive()
cRet := oModelRec:GetValue( 'B7DDETAIL', 'B7D_CODPAD' )

Return cRet

/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetDesMed()   บAutor  ณThiago Guilherme   บ Data ณ  28/05/15บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza descri็ใo do medicamento quando o c๓digo ้ digitadoบฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION RetDesMed()

oModelRec := FwModelActive()
cCodTbPrc := xFilial("BR8") + oModelRec:GetValue( 'B7DDETAIL', 'B7D_CODPAD' ) + oModelRec:GetValue( 'B7DDETAIL', 'B7D_CODMED' )		
oModelRec:SetValue( 'B7DDETAIL', 'B7D_DESMED', ALLTRIM(Posicione("BR8",1,cCodTbPrc,"BR8_DESCRI")) )	

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} RetMatric
Faz o gatilho do beneficiario nos campos do Grid e no campo de 
codigo da familia
@author TOTVS
@since 17/07/2020
@version P12
@history
	Vinicius.Queiros 17/07/2020
		Valida se o Beneficiario esta ativo
/*/
//-----------------------------------------------------------------

Function RetMatric()

	Local nLin 			:=  0
	Local oModelRec 	:= FwModelActive()
	Local oModelGrid	:= oModelRec:GetModel( "B7DDETAIL" )
	Local cMatricula	:= oModelRec:GetValue( "B4FMASTER" , "B4F_MATRIC" )
	Local nTotLin 		:= oModelGrid:Length( .F. )
	Local lRet			:= .F.

	// Valida se o beneficiario estแ Ativo
	BA1->(DbSetOrder(2))
	If BA1->(Dbseek(xFilial("BA1") + cMatricula))
		If Empty(BA1->BA1_MOTBLO) .Or. BA1->BA1_DATBLO > dDataBase

			For nLin := 1 To nTotLin 
				oModelGrid:SetLine( nLin )
				oModelRec:SetValue( 'B7DDETAIL', 'B7D_BENEFI', cMatricula )			
			Next nLin
			oModelRec:SetValue( 'B4FMASTER', 'B4F_CODFAM', SUBSTR(cMatricula,1,14) )
			oModelRec:SetValue( 'B4FMASTER', 'B4F_MATRIC', BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )
			oModelRec:SetValue( 'B4FMASTER', 'B4F_NOMBEN', BA1->BA1_NOMUSR )


			lRet := .T. // Beneficiแrio Valido
		Else
			Help(,,'Help',, STR0015 , 1, 0 ) // "Beneficiแrio Bloqueado"
		EndIf
	EndIf

	If !lRet

		BA1->(DbSetOrder(5))
		If BA1->(Dbseek(xFilial("BA1") + cMatricula))
			If Empty(BA1->BA1_MOTBLO) .Or. BA1->BA1_DATBLO > dDataBase

				For nLin := 1 To nTotLin 
					oModelGrid:SetLine( nLin )
					oModelRec:SetValue( 'B7DDETAIL', 'B7D_BENEFI', cMatricula )			
				Next nLin
				oModelRec:SetValue( 'B4FMASTER', 'B4F_CODFAM', SUBSTR(cMatricula,1,14) )
				oModelRec:SetValue( 'B4FMASTER', 'B4F_MATRIC', BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )
				oModelRec:SetValue( 'B4FMASTER', 'B4F_NOMBEN', BA1->BA1_NOMUSR )

				lRet := .T. // Beneficiแrio Valido
			Else
				Help(,,'Help',, STR0015 , 1, 0 ) // "Beneficiแrio Bloqueado"
			EndIf
		EndIf

	Endif



Return lRet

/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRelB1NB4F()   บAutor  ณThiago Guilherme   บ Data ณ  28/05/15บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Nใo permite excluir receitas vinculadas a protocolos		  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION RelB1NB4F(oModel)

lRet := .T.

If oModel:GetOperation() == MODEL_OPERATION_DELETE		
	dbSelectArea("B1N")		
	dbSetOrder(4)
	
	If B1N->(dbSeek(xfilial("B1N") + B4F->B4F_CODREC))
		lRet := .F.
		Help( ,, 'Help',, STR0010 /*"Nใo serแ possํvel excluir esta receita, pois esta vinculada a um ou mais protocolos."*/, 1, 0 )
	EndIf
EndIf 

Return lRet

/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValdDtVal()   บAutor  ณThiago Guilherme   บ Data ณ  28/05/15บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo dos campos de validade do medicamento		  บฑฑ
nCpoDt: 1 - data inicial|| 2 - Data final
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION ValdDtVal(nCpoDt)

Local lRet    := .F.
Local dDtIni  := oModelRec:GetValue( 'B7DDETAIL', 'B7D_DTVINI' )
Local dDtFin  := oModelRec:GetValue( 'B7DDETAIL', 'B7D_DTFVAL' )
		
if nCpoDt == 1
	                                                         
	If EMPTY(dDtFin) .OR. dDtIni <= dDtFin
		lRet := .T.
	EndIf
ElseIf nCpoDt == 2

	If EMPTY(dDtIni) .OR. dDtIni <= dDtFin
		lRet := .T.
	EndIf
EndIf

if !lRet
	Help( ,, 'Help',, STR0014, 1, 0 )
endif

Return lRet


/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValInterDt()   บAutor  ณRoberto Arruda   บ Data ณ  22 /05/15บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo dos campos de data do medicamento		  		  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ValInterDt()

	Local oB7D	  := oModelRec:GetModel('B7DDETAIL')
	Local nLinhaAtual := oB7D:GetLine()
	Local lRet := .T.
	Local nI
	Local nTamB7D := oB7D:Length()
	Local cCodPad
	Local cCodPro 
	Local dDtIni
	Local dDtFim
	
	if oModelRec <> nil
		//Armazenando os valores que estใo sendo inseridos
		cCodPad  := oB7D:GetValue("B7D_CODPAD")
		cCodPro  := oB7D:GetValue("B7D_CODMED") 
		dDtIni   := oB7D:GetValue("B7D_DTVINI")
		dDtFim   := oB7D:GetValue("B7D_DTFVAL")
		
		for nI := 1 to nTamB7D
			if nI <> nLinhaAtual .and. lRet
			
				oB7D:GoLine(nI)
				
				if alltrim(oB7D:GetValue("B7D_CODPAD")) = alltrim(cCodPad) .and. alltrim(oB7D:GetValue("B7D_CODMED")) = alltrim(cCodPro)
					if oB7D:GetValue("B7D_DTVINI") <= dDtIni .and. dDtIni <= oB7D:GetValue("B7D_DTFVAL") // Validando data Inicial
						Help( ,, 'Help',, STR0012/*"O perํodo informado cont้m dias em conflito com o registro na "*/ + cvaltochar(nI) + STR0013/*"บ linha."*/, 1, 0 )
						lRet := .F.
					elseif dDtIni <= oB7D:GetValue("B7D_DTVINI") .and. dDtFim >= oB7D:GetValue("B7D_DTVINI")
						Help( ,, 'Help',, STR0012/*"O perํodo informado cont้m dias em conflito com o registro na "*/ + cvaltochar(nI) + STR0013/*"บ linha."*/, 1, 0 )
						lRet := .F.
					elseif dDtFim >= oB7D:GetValue("B7D_DTVINI") .and. dDtFim <= oB7D:GetValue("B7D_DTFVAL")
						Help( ,, 'Help',, STR0012/*"O perํodo informado cont้m dias em conflito com o registro na "*/ + cvaltochar(nI) + STR0013/*"บ linha."*/, 1, 0 )
						lRet := .F. 
					endif
				endif				
			endif			
		next
				
		oB7D:GoLine(nLinhaAtual) //Posicionando na Linha Atual 
	endif
return lRet

/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLimpCmp   บAutor  ณThiago Guilherme   บ Data ณ  28/05/15บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Limpa campos 
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION LimpCmp()

M->B4F_REGSOL := ""
M->B4F_NOMSOL := ""
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLCOREC260
Abre rotina de receitas que foi chamada pela rotina de Grupo/Familiar ou pelo protocolo de reembolso
@author Karine Riquena Limp
@since 25/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLCOREC260(oModel, cMatric)

Local oBrwInd

oBrwInd := FWMBrowse():New()
oBrwInd:SetAlias('B4F')
oBrwInd:SetDescription("Receitas")//Indica็๕es
oBrwInd:SetMenuDef('PLSCADREC') //Define o MenuDef
oBrwInd:SetFilterDefault( "B4F_MATRIC == '" + cMatric + "' " )
oBrwInd:Activate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSANXREC
Abre uma pergunta se o usuแrio deseja incluir o anexo na inclusใo de um cadastro de receita
@author Oscar Zanin
@since 23/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Static function PLSANXREC(oModel)
Local lRet := .T.

FWFormCommit( oModel )

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	If MsgYesno(OemtoAnsi("Deseja Anexar os arquivos agora?")) 
		PLSANRCTANEXO(oModel)
	EndIf
EndIF

Return lRet
