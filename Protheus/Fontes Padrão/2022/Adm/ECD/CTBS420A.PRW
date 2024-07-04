#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'CTBS420A.CH'
#Include "FWLIBVERSION.CH"

//Compatibilização de fontes 30/05/2018

#DEFINE NUM_COL_EMP  	6
#DEFINE EMP_SELECAO 		1
#DEFINE EMP_GREMPRESA 	2
#DEFINE EMP_FILIAL 		3
#DEFINE EMP_DESCRIC 		4
#DEFINE EMP_CGC     		5
#DEFINE EMP_VAZIO   		6


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= FWLoadModel('CTBS420')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina
Esta view somente exibe cabecalho reg k030 - grade do reg k100 - grade do reg k110 pára inclusao e alteracao

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruCQQ	:= FWFormStruct(2,'CQQ')
Local oStruCQR	:= FWFormStruct(2,'CQR')
Local oStruCQS	:= FWFormStruct(2,'CQS')
Local oModel		:= FWLoadModel('CTBS420')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CQQ',oStruCQQ,'CQQMASTER')

oStruCQR:SetProperty( 'CQR_CDPAIS' , MVC_VIEW_LOOKUP    ,'CCH')

oView:AddGrid('VIEW_CQR',oStruCQR,'CQRDETAIL')
oView:AddGrid('VIEW_CQS',oStruCQS,'CQSDETAIL')

// Cria Folder na view
oView:CreateFolder( 'REGISTRO' )
// Cria pastas nas folders
oView:AddSheet( 'REGISTRO', 'K030', STR0001 ) //'K030 - Conglomerados Economicos'

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TOP' 		,  20,,, 'REGISTRO', 'K030' )
oView:CreateHorizontalBox( 'CENTER'	,  40,,, 'REGISTRO', 'K030' )
oView:CreateHorizontalBox( 'DOWN' 		,  40,,, 'REGISTRO', 'K030' )

oView:SetOwnerView('VIEW_CQQ','TOP'		)
oView:SetOwnerView('VIEW_CQR','CENTER'		)
oView:SetOwnerView('VIEW_CQS','DOWN'	)

oView:EnableTitleView('VIEW_CQQ')
oView:EnableTitleView('VIEW_CQR')
oView:EnableTitleView('VIEW_CQS')

oModel:SetPrimarykey({'CQQ_FILIAL','CQQ_IDBLW'})  //COLOCAR NO DICIONARIO X2_UNICO

oView:SetCloseOnOk({||.T.})

oView:AddUserButton( STR0002,'' , {|oView| CT420SelEmp()} ) //STR0002 //"Selecionar Empresas"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CT420SelEmp
Selecao das Empresas/Filiais do SIGAMAT.EMP 

@author TOTVS
@since 06/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Function CT420SelEmp(lF3)
Local oModel	:= FWModelActive()
Local nOperation	:= oModel:GetOperation()
Local oView		:= FWViewActive()

Local aHeader := {}
Local aGrFils := {}
Local oDlg
Local oOk
Local oNo
Local nOpca := 0
Local lCheck := .F.
Local oGrFil
Local lGestao	:=  "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout()     //Indica se usa Gestao Corporativa
Local aCQRExis := {}                                               //array que contera GrupoEmpresas/Filial ja existente na grade

Local oGridCQR := oModel:GetModel("CQRDETAIL")
Local nLinGrade := 0
Local nX := 0
Local lContinua := .T.
Local aAux      := {} 

DEFAULT lF3 := .F.                                                  //INDICA SE INVOCADO POR CONSULTA PADRAO F3

oOk 		:= LoadBitmap( GetResources(), "LBOK")  //BIT MAP MARCACAO BOTAO OK
oNo			:= LoadBitmap( GetResources(), "LBNO")  //BIT MAP MARCACAO BOTAO NAO

//-------------------------------------------------------------------
//Monta o aheader do ListBox das Filiais
//-------------------------------------------------------------------
aHeader := ARRAY(NUM_COL_EMP)

aHeader[EMP_SELECAO]	  := ""  		
aHeader[EMP_GREMPRESA] := STR0010  //"Grupo Empresa"

If lGestao
	aHeader[EMP_FILIAL] := STR0003 //"Empresa/Unidade/Filial"
Else
	aHeader[EMP_FILIAL] := STR0004  //"Filial"
EndIf

aHeader[EMP_DESCRIC]    := STR0005 //STR0005 //"Razão Social"
aHeader[EMP_CGC]	      := STR0006 //STR0006 //"CNPJ"
aHeader[EMP_VAZIO]	  := ""

aCQRExis := GetCQR(oModel)  //CARREGA NO ARRAY AS EMPRESAS JA EXISTENTES NO REGISTRO K100

aGrFils := GetEcdGruFil(aCQRExis)  //CARREGA AS EMPRESAS PASSANDO AS JA EXISTENTE NO K110 PARA NAO COLOCAR NA LISTA DE SELECAO

If Len( aGrFils ) == 0
	Return(.F.)
EndIf

DEFINE MSDIALOG oDlg FROM  20,05 TO If(lF3,450,480),620 TITLE STR0007 PIXEL  //STR0007 //"Seleção Grupo Empresa / Filial "

oGrFil := TWBrowse():New( 0.2, 0.2 , 310, 210,Nil,aHeader, Nil, oDlg, Nil, Nil, Nil,Nil,;
				      {|| aGrFils := GrEmpTroca( oGrFil:nAt, aGrFils), oGrFil:Refresh(), If(lF3,( Sleep(10), nOpca := 1, oDlg:End()),NIL) })      

oGrFil:SetArray( aGrFils )

If !lF3
	oGrFil:bHeaderClick := { |o , nCol | InvGrFl( o , nCol , aGrFils, .T. /*lInvTodos*/ ) }
EndIf

oGrFil:bLine := {|| {;
					If( aGrFils[oGrFil:nAt,EMP_SELECAO] , oOk , oNo ),;
						aGrFils[oGrFil:nAt,EMP_GREMPRESA],;
						aGrFils[oGrFil:nAt,EMP_FILIAL],;
						aGrFils[oGrFil:nAt,EMP_DESCRIC],;
						aGrFils[oGrFil:nAt,EMP_CGC],;
						aGrFils[oGrFil:nAt,EMP_VAZIO];
					}}
   
If !lF3  //SE NAO FOR CONSULTA PADRAO F3 ENTAO MOSTRA BOTAO INVERSAO E BOTAO OK PARA CONFIRMAR

	lCheck := .F.    // Usando New   
	oCheck1 := TCheckBox():New(215, 020,STR0008,{||lCheck:=!lCheck },oDlg,100,210,,{||InvGrFl(oGrFil, oGrFil:nAt, aGrFils, .T. /*lInvTodos*/)},,,,,,.T.,,,) //'Inverte Seleção'

	DEFINE SBUTTON FROM 215,200 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 215,260 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

Endif

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso 
                                                           //	para saida com ESC
                                                           
If nOpca == 1 //botao OK - PRESSIONADO OU DUPLO CLIQUE QUANDO SELECIONADO VIA F3
	
	oGridCQR := oModel:GetModel("CQRDETAIL")
	
	If lF3	   //SELECAO POR F3 EDICAO DO CAMPO CQR_GRUFIL
	
		nLinGrade := oGridCQR:GetLine()			
		
		For nX:=1 TO Len(aGrFils)
			
			If aGrFils[nX,EMP_SELECAO]
				VAR_IXB := aGrFils[nX,EMP_GREMPRESA]+aGrFils[nX,EMP_FILIAL]   //VARIAVEL DE RETORNO DA CONSULTA PADRAO
	
				oGridCQR:GoLine(nLinGrade)
				
				//se ja existe linha aproveita ou se estiver vazio considera uma linha nova recem incluida
				If Empty(oGridCQR:GetValue("CQR_GRUFIL"))  .OR. MsgYesNo(STR0009)   //"Linha ja contem dados, atribui novos valores ?"
					oGridCQR:SetValue("CQR_CNPJ", Subs(aGrFils[nX,EMP_CGC],1,8) )                                   //CNPJ 
					oGridCQR:SetValue("CQR_NOME", aGrFils[nX,EMP_DESCRIC] ) //NOME DA EMPRESA - RAZAO SOCIAL 
					If Empty(oGridCQR:GetValue("CQR_GRUFIL"))                                                       //quando esta em branco atribui Nao
						oGridCQR:SetValue("CQR_EVENTO", "2" )                                                        //NAO
					EndIf
				Else //se responder nao a pergunta atribui novos valores voltar a que estava no campo
					VAR_IXB := oGridCQR:GetValue("CQR_GRUFIL")
				EndIf
				Exit  //lf3 pega primeiro selecionado e sai do loop
			EndIf

		Next
		
		oView:Refresh("CQRDETAIL")  //ESTE REFRESH EH NECESSARIO PARA ATUALIZAR A GRADE COM OS NOVOS VALORES ATRIBUIDOS
		
	Else   //SELECAO VIA ACOES RELACIONADAS

		//--------------------------------------------------------------------------------
		// Tira temporariamente a obrigatoriedade dos campos para funcionamento do método
		// AddLine() a validacao ocorrerá posteriormente no LinhaOK e TudoOK
		//--------------------------------------------------------------------------------

		aAux := oGridCQR:GetStruct():GetFields()

		For nX := 1 TO Len(aAux)
           //campos obrigatorios tira a obrigatoriedade para preencher a grade - valida posterior linOk e TudOK		
			If aAux[nX][10] .And. aAux[nX,3] $ "CQR_NOME|CQR_PERPAR|CQR_PERCON|CQR_DTINI|CQR_DTFIM"
				oGridCQR:GetStruct():SetProperty(aAux[nX][3],MODEL_FIELD_OBRIGAT,.F.)
			EndIf
			
		Next nX

		nLinGrade := oGridCQR:Length()


		For nX:=1 TO Len(aGrFils)
			
			If aGrFils[nX,EMP_SELECAO]

				lContinua := .T.


				If ! Empty(oGridCQR:GetValue("CQR_GRUFIL"))  //se linha nova a incluir incrementa contador de linha e adiciona a nova linha com AddLine 
				    nLinGrade++				
					If oGridCQR:AddLine() != nLinGrade
						lContinua := .F.  //se der erro captura o erro
					EndIf
				EndIf
				If lContinua
					//na linha incluida pelo metodo addline ou na linha posicionada sem preenchimento do Grupo Filial atribui os valores
					oGridCQR:SetValue("CQR_GRUFIL", aGrFils[nX,EMP_GREMPRESA]+aGrFils[nX,EMP_FILIAL])   //GRUPO EMPRESA/FILIAL 
					oGridCQR:SetValue("CQR_CNPJ", Subs(aGrFils[nX,EMP_CGC],1,8) )                       //CNPJ 
					oGridCQR:SetValue("CQR_NOME", aGrFils[nX,EMP_DESCRIC] )                             //NOME DA EMPRESA - RAZAO SOCIAL 
					oGridCQR:SetValue("CQR_EVENTO", "2" )                                               //NAO 
				Else
					Help( , ,"CQRADDLIN", ,STR0011+oModel:GetErrorMessage()[6],1,0,,,,,,{ STR0012+oModel:GetErrorMessage()[7] })	 //"Não pode incluir linhas no Cadastro do bloco K100 !"###Verifique 
				EndIf
			EndIf
			
		Next
		
		//--------------------------------------------------------------------------------
		// Volta a obrigatoriedade retirada dos campos para funcionamento do método
		// AddLine() a validacao ocorrerá posteriormente no LinhaOK e TudoOK
		//--------------------------------------------------------------------------------

		aAux := oGridCQR:GetStruct():GetFields()

		For nX := 1 TO Len(aAux)
           //campos obrigatorios volta a obrigatoriedade para preencher a grade - valida posterior linOk e TudOK		
			If aAux[nX,3] $ "CQR_NOME|CQR_PERPAR|CQR_PERCON|CQR_DTINI|CQR_DTFIM"
				oGridCQR:GetStruct():SetProperty(aAux[nX][3],MODEL_FIELD_OBRIGAT,.T.)
			EndIf
			
		Next nX
	
		oView:Refresh("CQRDETAIL")  //ESTE REFRESH EH NECESSARIO PARA ATUALIZAR A GRADE COM OS NOVOS VALORES ATRIBUIDOS

		
	EndIf

EndIf
                                                               
Return( nOpca == 1  ) //se pressionou OK no acoes relacionadas retorna .T. senao retorna .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} GetEcdGruFil
Monta o array para selecao das Empresas/Filiais do SIGAMAT.EMP 
recebe um array com as empresas ja selecionada para nao repertir no list box de selecao
@author TOTVS
@since 06/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------


Static Function GetEcdGruFil(aCQRExis)
Local aEmp		:= {}		// Matriz com todas as empresas do Sistema
Local aRetSM0 := {}
Local nX
Local bCond := {||.T.}

Default aCQRExis := {}

//somente coloca no filtro as empresas/filiais diferente da logada pois parte do pressuposto que esta fazendo na empresa consolidadora
bCond := {|| aScan(aCQRExis,aRetSM0[nX,SM0_GRPEMP]+aRetSM0[nX,SM0_CODFIL] ) == 0 }      //se nao consta ainda na grade CQR

aRetSM0	:= FWLoadSM0()   //leitura do SIGAMAT.EMP

For nX := 1 To Len(aRetSM0)  //Laco For...Next para varrer todo SIGAMAT.EMP 

	If Eval(bCond) //avalia condicao filial diferente da logada e nao existe ainda na grade da CQR K100
		
		//adiciona no array aEmp e atribui as propriedades 
		aAdd(aEmp ,Array(NUM_COL_EMP) )    
		aEmp[Len(aEmp)][EMP_SELECAO] 	:= .F.
		aEmp[Len(aEmp)][EMP_GREMPRESA] 	:= aRetSM0[ nX,SM0_GRPEMP ]
		aEmp[Len(aEmp)][EMP_FILIAL] 	:= aRetSM0[ nX,SM0_CODFIL ]
		If FwLibVersion() >= "20211004"  
			If Empty(Alltrim( aRetSM0[ nX, 24 /*SM0_FULLNAME*/  ] ))   //Se nome esta em branco no SIGAMAT.EMP Avisa no console do SERVER  
				CONOUT(STR0013+aRetSM0[ nX,SM0_GRPEMP ]+STR0014+aRetSM0[ nX,SM0_CODFIL ]+ STR0015)  //"O Nome da Empresa esta em branco - Verifique o cadastro das empresas (SIGAMAT.EMP) Grupo Empresa: "##" Filial: "##"      -> Verifique. " 
			EndIf
			aEmp[Len(aEmp)][EMP_DESCRIC] 	:= SubStr(aRetSM0[ nX, 24 /*SM0_FULLNAME*/ ] ,1,170) //24 |SM0_FULLNAME|Razão Social Completa
		Else
			If Empty(Alltrim( aRetSM0[ nX,SM0_NOMECOM ] ))   //Se nome esta em branco no SIGAMAT.EMP Avisa no console do SERVER  
				CONOUT(STR0013+aRetSM0[ nX,SM0_GRPEMP ]+STR0014+aRetSM0[ nX,SM0_CODFIL ]+ STR0015)  //"O Nome da Empresa esta em branco - Verifique o cadastro das empresas (SIGAMAT.EMP) Grupo Empresa: "##" Filial: "##"      -> Verifique. " 
			EndIf
			aEmp[Len(aEmp)][EMP_DESCRIC] 	:= aRetSM0[ nX,SM0_NOMECOM ] 
		EndIf
		aEmp[Len(aEmp)][EMP_CGC]     	:= aRetSM0[ nX,SM0_CGC ]
		aEmp[Len(aEmp)][EMP_VAZIO] 		:= ' '   
	EndIf
	
Next

IF Len( aEmp ) <= 0   //se nao conseguir adicionar avisa usuario

	Help("GetGrEmEcd",1,"HELP",STR0016,STR0017,1,0)  //"Nao há filiais para essa empresa"###"Verifique o arquivo de empresas"
	
Endif

Return aEmp 


//-------------------------------------------------------------------
/*/{Protheus.doc} InvGrFl
Inversao da Selecao para todos ou individualmente
@author TOTVS
@since 06/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------


Static Function InvGrFl(oLstBox, nLinha, aArray, lInvTodos)
Local nX

Default lInvTodos := .F.

GrEmpTroca(nLinha,aArray, lInvTodos) 

oLstBox:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GrEmpTroca
Inversao da Selecao para todos ou individualmente
@author TOTVS
@since 06/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Static Function GrEmpTroca(nLinha,aArray, lInvTodos) 
Local nX

If lInvTodos
	For nX := 1 TO Len(aArray)
		aArray[nX,EMP_SELECAO] := !aArray[nX,EMP_SELECAO]
	Next		
Else
	aArray[nLinha,EMP_SELECAO] := !aArray[nLinha,EMP_SELECAO]
EndIf

Return aArray

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCQR
CARREGA NO ARRAY AS EMPRESAS JA EXISTENTES NO REGISTRO K100
@author TOTVS
@since 06/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetCQR(oModel, lPosic)
Local oGridCQR := oModel:GetModel("CQRDETAIL")
Local nX := 0
Local aRetorno := {}
Local nLinOri  := oGridCQR:GetLine()  //grava a linha atual da grade para retornar apos contagem laco for...next

Default lPosic := .F. // quando falso considera todos que estao na grade

For nX:=1 TO oGridCQR:Length()
	
	oGridCQR:GoLine(nX)  //vai para linha
	
	If ! oGridCQR:IsDeleted() .And. If(!lPosic, .T., nLinOri != nX )  //se nao estiver deletada e considera todos os elementos da grade
		aAdd( aRetorno, oGridCQR:GetValue( "CQR_GRUFIL" ) ) //adiciona no array conteudo do campo
	EndIf

Next 

oGridCQR:GoLine(nLinOri)  //vai para linha posicionada anteriormente ao laco for...next

Return(aRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} VlGrEmpFil
Valida Grupo Empresa Filial do SIGAMAT.EMP
@author TOTVS
@since 06/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function VlGrEmpFil()

Local aRetSM0 := {}
Local cGruFil := "" 
Local lRet := .T.
Local oModel	:= FWModelActive()
Local oGridCQR := oModel:GetModel("CQRDETAIL")
Local nPos := 0
Local aCQRExis := {}

cGruFil := oGridCQR:GetValue("CQR_GRUFIL")

aCQRExis := GetCQR(oModel, .T.)  //CARREGA NO ARRAY AS EMPRESAS JA EXISTENTES NO REGISTRO K100

If ! Empty(cGruFil)

	lRet := aScan(aCQRExis,cGruFil ) == 0  //somente pode continuar se nao encontrar nos ja existente na grade

	If lRet

		aRetSM0	:= FWLoadSM0()   //leitura do SIGAMAT.EMP
	
		lRet := ( ( nPos := aScan( aRetSM0, {|x| x[SM0_GRPEMP] == Subs(cGruFil,1,2) .and. Rtrim( x[SM0_CODFIL] ) == Rtrim( Subs(cGruFil,3) ) } ) ) > 0 )
		
	EndIf
	
EndIf

Return( lRet )