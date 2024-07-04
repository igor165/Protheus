#INCLUDE "PLSA731.ch"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA731   ºAutor  ³Microsiga           º Data ³  24/03/2015º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de RDA x Contrato        				           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SEGMENTO SAUDE VERSAO 12                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSA731()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B2G' )
oBrowse:SetDescription(STR0001) //'Documentos'
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { STR0002,'PesqBrw'         , 0, 1, 0, .T. } )//'Pesquisar'
aAdd( aRotina, { STR0003,'VIEWDEF.PLSA731', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0004,'VIEWDEF.PLSA731', 0, 3, 0, NIL } ) //'Incluir'
aAdd( aRotina, { STR0005,'VIEWDEF.PLSA731', 0, 4, 0, NIL } ) //'Alterar'
aAdd( aRotina, { STR0006,'VIEWDEF.PLSA731', 0, 5, 0, NIL } ) //'Excluir'
aAdd( aRotina, { STR0007,'VIEWDEF.PLSA731', 0, 8, 0, NIL } ) //'Imprimir'
aAdd( aRotina, { STR0008,'VIEWDEF.PLSA731', 0, 9, 0, NIL } ) //'Copiar'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

Local oStruB2G := FWFormStruct( 1, 'B2G', , )
Local oStruB2H := FWFormStruct( 1, 'B2H', , )

Public oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA731MD', /*bPreValidacao*/,{|| PL731ValDOC(oModel) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'B2GMASTER', NIL, oStruB2G )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'B2HDETAIL', 'B2GMASTER', oStruB2H, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


oModel:SetPrimaryKey({"B2G_FILIAL","B2G_CODINT","B2G_RDA"})


// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B2HDETAIL', { { 'B2H_FILIAL', 'xFilial( "B2G" ) ' } ,;
	                                { 'B2H_RDA', 'B2G_RDA' } } ,  "B2H_FILIAL+B2H_RDA" )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'B2HDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B2GMASTER' ):SetDescription( STR0001 ) //'Documentos

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0001) //'Documentos

//Valida se existem codigos duplicados no aCols
oModel:GetModel('B2HDETAIL'):SetUniqueLine({'B2H_DOC','B2H_REV', 'B2H_TIPO'}, {||PlsVlDB2H(oModel:GetValue('B2HDETAIL','B2H_TIPO' ))})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStruB2H := FWFormStruct( 2, 'B2H' )
Local oStruB2G := FWFormStruct( 2, 'B2G' )

Local oModel   := FWLoadModel( 'PLSA731' )
Local oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B2G' , oStruB2G, 'B2GMASTER'   )     

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B2H' , oStruB2H, 'B2HDETAIL'   )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 50 )
oView:CreateHorizontalBox( 'GRID', 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B2G' , 'GERAL'  )
oView:SetOwnerView( 'VIEW_B2H' , 'GRID'  )

oView:EnableTitleView( 'VIEW_B2H' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_B2H', 'B2H_SEQ' )   

//Imprime o contrato
oView:AddUserButton( STR0019, 'CLIPS', {|oView| PL731Imprime()} )

//Solicitação da tabela de Valores
oView:AddUserButton( 'Gerar tabelas contratuais', 'CLIPS', {|| PlsEscFrRPP (oModel:GetValue('B2GMASTER', 'B2G_RDA' ))} )
	
//Cria botão do banco de conhecimento
oView:AddUserButton( STR0018,		"", {|oView| PLSBAN731()})

Return oView  

//-------------------------------------------------------------------
//Retorna o tipo de documento
Function PL731Tipo(cTp) 
Local cTipo  := ""
Default cTp := ""

If Empty(cTp)
	dbSelectArea("B2L")
	dbSetOrder(1)	// filial + codigo
	If B2L->(MSSEEK(xFilial("B2L")+B2H->B2H_DOC+B2H->B2H_REV))
		If B2L->B2L_TIPO == "1"
			cTipo := STR0009//"Contrato"
		Elseif B2L->B2L_TIPO == "2"
			cTipo := STR0010//"Aditivo" 
		Else
			cTipo := STR0024//"Tabela Contratual"
		Endif	 
	Endif
Else
	If cTp == "1"
		cTipo := STR0009//"Contrato"
	ElseIf cTp == "2"
		cTipo := STR0010//"Aditivo"
	Else 
		cTipo := STR0024//"Tabela Contratual"	
	Endif
Endif
Return cTipo                                                                       

//-------------------------------------------------------------------
//Imprime o documento solicitado
Function PL731Imprime()
Local cDoc := oModel:GetValue("B2HDETAIL" , "B2H_DOC")
Local cRev := oModel:GetValue("B2HDETAIL" , "B2H_REV")
Local cTipo:= oModel:GetValue("B2HDETAIL" , "B2H_TIPO")
Local oMeter 

If ( Upper(Alltrim((cTipo))) $ ("CONTRATO,ADITIVO,1,2") )

	DEFINE FONT oFont NAME "Arial" BOLD SIZE 9,14
	
	DEFINE DIALOG oDlg TITLE STR0011 FROM 180,180 TO 250,700 PIXEL//"Impressão do Documento" 
	
	oPnlCentro := TPanel():New(01,01,,oDlg,,,,,,5,15,.F.,.F.)
	
	oPnlCentro:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 05,20 SAY STR0012 OF oPnlCentro PIXEL SIZE 150,9 FONT oFont COLOR CLR_BLUE  //"Processando.... Aguarde!"
	
	oDlg:bStart := {|| CursorWait(),PL729GeraDoc(B2G->B2G_RDA,cDoc,cRev),CursorArrow(),oDlg:End()}
	
	ACTIVATE DIALOG oDlg CENTERED

Else
	MsgAlert (STR0027)  //Este documento não pode ser gerado, pois não corresponde a um Contrato ou Aditivo.
EndIf


Return Nil       


//-------------------------------------------------------------------
//Valida se todos os documentos informados são validos
Function PL731ValDoc(oModel)
Local nOpc 		:= oModel:GetOperation()
Local lRet    	:= .T. 
Local oModel 		:= FwModelActive()
Local oModelB2H 	:= oModel:GetModel('B2HDETAIL')
Local aEntidades  := {} 
Local nX         := 0
Local nY         := 0
Local aArea     := GetArea()

aAdd(aEntidades,{oModelB2H,"B2H_DOC","B2H_REV"})

For nX := 1 To Len(aEntidades)
	For nY := 1 To aEntidades[nX][1]:Length()
		aEntidades[nX][1]:GoLine(nY)
	
		If aEntidades[1][1]:IsDeleted(nY) == .F. //Não valida linhas deletadas 
			If !B2L->(MSSEEK(xFilial("B2L")+aEntidades[nX][1]:GetValue(aEntidades[nX][2])+aEntidades[nX][1]:GetValue(aEntidades[nX][3])))
				Help(,,"Atenção",,STR0013+aEntidades[nX][1]:GetValue(aEntidades[nX][2])+STR0014+aEntidades[nX][1]:GetValue(aEntidades[nX][3])+STR0015,1,0)//"O documento "##" rev. "##" não existe, favor verificar !"
				lRet := .F.
			Endif
		Endif	                  
	 		
	Next nY	
Next nX

If lRet
	PL731GRVDOC(oModel)
Endif
	
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
//Valida se já existe RDA
Function PL731RDA()
Local aArea:= GetArea()
Local lRet := .T.

dbSelectArea("B2G")
dbSetOrder(1)	// filial + codigo
If B2G->(MSSEEK(xFilial("B2G")+M->B2G_CODINT+M->B2G_RDA))
	APMSGSTOP(STR0016,STR0017)//"Atenção, já existe registro cadastrado para a RDA informada. Favor Verificar antes de realizar este processo."##
	lRet := .F.
Endif

RestArea(aArea)

Return lRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} PLSAVDRPPG
Solicitar o relatório e gravar a solicitação na B2H

@author  Renan Martins	
@version P12
@since   11/2016

/*/
//---------------------------------------------------------------------------------
Function PLSAVDRPPG(cCodRda, cTipoRel)
Local cCodOpe := PlsIntPad()

If ( MsgYesNo(STR0026) )
	PlsChJRPr (cCodRDA, cCodOpe, "", "", .F., "", .T., .T., "",, "1",,cTipoRel, oModel) 
    //PLSATBPR(cCodRDA, cCodOpe, "", "", .F., "", .F. , .F.,"", , , "1", , )
Else
	MsgAlert(STR0025)
EndIf
Return



//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlsVlDB2H
Valida documentos e obrigatoriedades

@author  Renan Martins	
@version P12
@since   11/2016

/*/
//---------------------------------------------------------------------------------
Function PlsVlDB2H (cTipo)
Local lRet := .T.
If Upper(Alltrim((cTipo))) $ ("CONTRATO,ADITIVO,1,2")
	lRet := .F.
Endif
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PlsEscFrRPP
ParamBox para seleção do tipo de relatório
@author Renan Martins
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlsEscFrRPP(cCodRda)
Local aPergs 	:= {}
Local aRet 	:= {}
Local lRet  	:= .F.
   
aAdd( aPergs ,{2,STR0030,"1", {STR0028, STR0029},100,,.T.})

If ParamBox(aPergs ,STR0030,aRet,,,.T.,256,129,,,.F.,.F.) 
	IF ( Empty(aRet[1]) )
		MsgAlert("Selecione uma opção!")
		Return lRet 
	ENDIF	
	IF ( !Empty(aRet[1]) )     
		PLSAVDRPPG(cCodRda, Left(aRet[1],1))
	ENDIF	
 	lRet := .T.   
EndIf
Return lRet



//------------

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBAN731
Visualização do Banco de conhecimento da rotina PLSA731.
@author Rodrigo Morgon
@since 12/08/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSBAN731() 

LOCAL cQuery		:= ""
LOCAL cIndex		:= ""
LOCAL cChaveInt  	:= ""
LOCAL aDocB2H    	:= {}
Local oModel 		:= FwModelActive()
Local oModelB2H 	:= oModel:GetModel("B2HDETAIL")
Local cDoc 		:= oModel:GetValue("B2HDETAIL" , "B2H_DOC")//usando o oModelB2H não reconhecu 
Local cRev       	:= oModel:GetValue("B2HDETAIL" , "B2H_REV")//usando o oModelB2H não reconhecu 
Local cSeq			:= oModel:GetValue("B2HDETAIL" , "B2H_SEQ")//usando o oModelB2H não reconhecu 


Private aRotina 		:= {}

// AROTINA UTILIZADO NA TELA DO CONHEC.   =====================
//Como é apenas para mostrar o contrato/aditivo/ tabela gerada, é apenas para aquele item, não sendo necessário anexar outros.
AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
AaDd( aRotina, { "Visualizar", 			"MsDocument", 0, 2 } ) //"Visualizar"
aAdd( aRotina, { "Conhecimento",		"MsDocument"	, 0, 3, 0, NIL } )
//=========================================================

cChaveInt := B2G->B2G_RDA+cDoc+cRev+cSeq

	B2H->( DbSelectArea("B2H") )
	B2H->( DbSetOrder(1) )
	B2H->( MsSeek( xFilial("B2H") + cChaveInt ) )
		
	cIndex := CriaTrab(NIL,.F.)
	cQuery := " B2H_FILIAL == '" + xFilial("B2H") + "' "
	cQuery += " .AND. B2H_RDA == '" + B2G->B2G_RDA + "' "
	cQuery += " .AND. B2H_DOC == '" + cDoc + "' "
	cQuery += " .AND. B2H_REV == '" + cRev + "' "
	cQuery += " .AND. B2H_SEQ == '" + cSeq + "' "
	
	IndRegua("B2H",cIndex,B2H->(IndexKey())/*"B2H->(B2H_FILIAL+B2H_RDA+B2H_DOC+B2H_REV+B2H_SEQ)"*/,,cQuery)
		
	If B2H->(!Eof())	
		//É necessario que exista X2_UNICO da tabela B2G cadastrado.
		//A opção 1 é somente para visualizar o documento, porque só pode existir 1 anexo para 1 documento 
		MsDocument( "B2H", B2H->(RecNo()),1)
	EndIf
		
	B2H->(DbCloseArea())

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PL731GRVDOC
Salva o documento no banco de conhecimento
@author TOTVS
@since 26/08/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL731GRVDOC(oModel)
Local nOpc 			:= oModel:GetOperation()
Local lRet    		:= .T. 
Local oModel 			:= FwModelActive()
Local oModelB2H 		:= oModel:GetModel('B2HDETAIL')
Local aArea     		:= GetArea()
Local aEntidades  	:= {} 
Local nX         		:= 0
Local nY         		:= 0
Local cChaveRDA  		:= B2G->B2G_RDA

aAdd(aEntidades,{oModelB2H,"B2H_SEQ","B2H_DOC","B2H_REV","B2H_PATH"})

AC9->( DbSelectArea("AC9") )
AC9->( DbSetOrder(2) )

B2H->( DbSelectArea("B2H") )
B2H->( DbSetOrder(1) )

For nX := 1 To Len(aEntidades)
	For nY := 1 To aEntidades[nX][1]:Length()
		aEntidades[nX][1]:GoLine(nY)
		If aEntidades[1][1]:IsDeleted(nY) == .F. //Não valida linhas deletadas 			
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		  //³ Grava no Banco de Conhecimento
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		  If !Empty(alltrim(aEntidades[nX][1]:GetValue(aEntidades[nX][5])))
			If !AC9->( MsSeek( xFilial("AC9")+"B2H"+B2H->(B2H_FILIAL+B2H_FILIAL)+cChaveRDA+aEntidades[nX][1]:GetValue(aEntidades[nX][3]);
					+cChaveRDA+aEntidades[nX][1]:GetValue(aEntidades[nX][4])))				
		  			
		  		 If aEntidades[1][1]:IsUpdated(nY)//Esse controle existe para evitar a duplicidade de inclusão de documentos no banco de conhecimento 
		  			PLSINCONH(aEntidades[nX][1]:GetValue(aEntidades[nX][5]),"B2H", ;
		  	             xFilial("B2H")+cChaveRDA+aEntidades[nX][1]:GetValue(aEntidades[nX][3])+;
		  	             aEntidades[nX][1]:GetValue(aEntidades[nX][4])+aEntidades[nX][1]:GetValue(aEntidades[nX][2]), .T.)
	           Endif 	  	 
		  	 Endif            
		  Endif	
		Else
		 PL731EXTDOC(.F.)		
		Endif	                  
	 		
	Next nY	
Next nX
	
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PL731EXTDOC
Funcão executada via X3_WHEN do campo B2H_PATH 
@author TOTVS
@since 26/08/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL731EXTDOC(lExclui)
Local oModel 		:= FwModelActive()
Local oView 		:= FwViewActive()
Local oModelB2H 	:= oModel:GetModel('B2HDETAIL')
Local cRDA 		:= B2G->B2G_RDA
Local cDoc 		:= alltrim(oModel:GetValue("B2HDETAIL" , "B2H_DOC"))
Local cRev       	:= alltrim(oModel:GetValue("B2HDETAIL" , "B2H_REV"))
Local cPath     	:= alltrim(oModel:GetValue("B2HDETAIL" , "B2H_PATH"))
Local cSeq			:= alltrim(oModel:GetValue("B2HDETAIL" , "B2H_SEQ"))
Local aArea       := GetArea()
Local lRet := .T.

Default lExclui := .T.

oView:SetModel(oModel)	

AC9->( DbSelectArea("AC9") )
AC9->( DbSetOrder(2) )
If AC9->( MsSeek( xFilial("AC9")+"B2H"+B2H->(B2H_FILIAL+B2H_FILIAL)+cRDA+cDoc+cRev+cSeq))	
	
	If !Empty(alltrim(cPath)) 
		If lExclui
			lRet := MsgYesNo(STR0021)//"Já existe um anexo armazenado para esse documento. Deseja excluí-lo?"		
		Else
			lRet := .T.
		Endif	
		
		If lRet
			//Exclui o registo do banco de conhecimento
			ACB->( DbSelectArea("ACB") )
			ACB->( DbSetOrder(1) )
			If ACB->( MsSeek( xFilial("ACB")+AC9->AC9_CODOBJ))	
	  			RecLock( "ACB", .F. )
				ACB->( dbDelete() )
				ACB->( MsUnLock() )
			Endif	
	  		//Exclui a relação de objetos x entidades
	  		RecLock( "AC9", .F. )
			AC9->( dbDelete() )
			AC9->( MsUnLock() )
	           
			//Limpa o conteudo do campo que continha o diretório do arquivo  
			oModelB2H:SetValue('B2H_PATH',"    ")
			oView:Refresh() 	
	  	Endif	 
	 Endif 	      
Endif

RestArea(aArea)

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} PL731Espaco
Funcão executada via X3_VALID para retirar espacos 
@author TOTVS
@since 29/10/2015
@version P12
/*/
//-------------------------------------------------------------------

Function PL731Espaco(cPath)
//Variavel Local de Controle
Local aCarc_Esp := {}
Local lRet      := .T.
Local nI        := 0
 
//Imputa os Caracteres Especiais no Array de Controle
AADD(aCarc_Esp,{"!", "Exclamacao"})
AADD(aCarc_Esp,{"#", "Sustenido"})
AADD(aCarc_Esp,{"$", "Cifrao"})
AADD(aCarc_Esp,{"%", "Porcentagem"})
AADD(aCarc_Esp,{"*", "Asterisco"})
AADD(aCarc_Esp,{"/", "Barra"})
AADD(aCarc_Esp,{"(", "Parentese"})
AADD(aCarc_Esp,{")", "Parentese"})
AADD(aCarc_Esp,{"+", "Mais"})
AADD(aCarc_Esp,{"¨", ""})
AADD(aCarc_Esp,{"=", "Igual"})
AADD(aCarc_Esp,{"~", "Til"})
AADD(aCarc_Esp,{"^", "Circunflexo"})
AADD(aCarc_Esp,{"]", "Chave"})
AADD(aCarc_Esp,{"[", "Chave"})
AADD(aCarc_Esp,{"{", "Colchete"})
AADD(aCarc_Esp,{"}", "Colchete"})
AADD(aCarc_Esp,{";", "Ponto e Virgula"})
AADD(aCarc_Esp,{">", "Maior"})
AADD(aCarc_Esp,{"<", "Menor"})
AADD(aCarc_Esp,{"?", "Interrogacao"})
AADD(aCarc_Esp,{",", "Virgula"})
AADD(aCarc_Esp,{" ", "Espaco"})
AADD(aCarc_Esp,{"'", "Aspas"})

//Executa o Laco ate o Tamanho Total do Array
For nI:= 1 to Len(aCarc_Esp)
	//Verifica se Algum dos Caracteres Especiais foi Digitado
	If At(aCarc_Esp[nI][1], AllTrim(cPath)) <> 0
		//Se Sim Emite uma Mensagem
		MsgStop(STR0022 + aCarc_Esp[nI][1]+ STR0023)//"O arquivo selecionado possui o caracter especial "##" no seu nome que não é permitido."
		lRet :=  .F.
	EndIf
Next

Return lRet
