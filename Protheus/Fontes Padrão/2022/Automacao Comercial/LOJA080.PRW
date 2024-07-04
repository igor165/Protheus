#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'LOJA080.CH'
#INCLUDE 'FWMVCDEF.CH'    
#INCLUDE "FWMBROWSE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLOJA080   บAutor  ณAndre Alves Veiga   บ Data ณ  28/05/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de Identificacao de loja. Utilizado para configurarบฑฑ
ฑฑบ          ณas lojas para a consulta de estoque.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LOJA080

Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SLJ')
oBrowse:SetDescription(STR0001) // Identificacao de Lojas
oBrowse:Activate()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuno    |MenuDef   ณ Autor ณVendas CRM             ณ Data ณ26/01/12  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de defini็ใo do aRotina                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRotina   retorna a array com lista de aRotina             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ LOJA080                                                    ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003	ACTION "PesqBrw" 		 OPERATION 1 ACCESS 0 //"Pesquis	ar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.LOJA080" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005   	ACTION "VIEWDEF.LOJA080" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.LOJA080" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0007    ACTION "VIEWDEF.LOJA080" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณModelDef  บAutor  ณVendas CRM          บ Data ณ  26/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine o modelo de dados (MVC)                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA080                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ModelDef()

Local oStruSLJ := FWFormStruct( 1, 'SLJ')
Local bCommit  := { |oModel| Lj080Cmt( oModel ) } // Grava os dados e faz chamada para loja off line -> Lj080AltOk
Local oModel   := Nil

oModel := MPFormModel():New('LOJA080M',,, bCommit,)
oModel:AddFields( 'SLJMASTER',, oStruSLJ,,,)
oModel:GetModel( 'SLJMASTER' ):SetDescription( STR0001 )// Identificacao de Lojas

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณVendas CRM          บ Data ณ  26/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine a interface para cadastro de concorrentes em MVC.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA080                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef() 

Local oModel   := FWLoadModel( 'LOJA080' )
Local oStruSLJ := FWFormStruct( 2, 'SLJ',)
Local oView    := Nil

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_SLJ', oStruSLJ, 'SLJMASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_SLJ', 'TELA' )

Return oView
                         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj080Cmt  บAutor  ณVendas CRM          บ Data ณ  26/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBloco executado na gravacao dos dados do formulario.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA080                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Lj080Cmt(oModel)
Local aArea		:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local cCodigo	 	:= oModel:GetValue( 'SLJMASTER', 'LJ_CODIGO' ) 
Local lRet			:= .T.
local aLocais		:= {} //Locais de Estoque
Local nC			:= 0 //Variแvel contadora
Local aNNRArea		:= {} //WorkArea de Armazens
Local cFilCad		:= oModel:GetValue( 'SLJMASTER', 'LJ_RPCFIL' ) 
Local lECCia 		:= !Empty(oModel:GetValue( 'SLJMASTER', 'LJ_ECFLAG' )) //Tratamento Integracao e-commerce CiaShop
Local cLocaisEC 	:= SuperGetMv("MV_LJECOMG", ,"")
Local cLocal		:= oModel:GetValue( 'SLJMASTER', 'LJ_LOCAL' ) 
Local cEmpCad		:= oModel:GetValue( 'SLJMASTER', 'LJ_RPCEMP' )
     
     
//Verifica se existe a empresa/Filial cadastrado
If (lECCia .OR. !Empty(oModel:GetValue( 'SLJMASTER', 'LJ_TOKEN' ))) .AND.  !(lRet := FWFilExist( cEmpCad, cFilCad))
	MsgAlert(STR0015  + cEmpCad + "/"+cFilCad + STR0016) //"Empresa/Filial ["##+"] nใo cadastrado"
EndIf
     
If lRet .and. lECCia 

	If cEmpCad <> cEmpAnt
		MsgAlert(STR0010) //"Para lojas e-commerce, a empresa deve ser igual เ empresa de cadastro"
		 lRet := .F.
	EndIf
	If lRet .AND.  Empty(cLocal)
		If !Empty(cLocaisEC)
			If !MsgYesNo(STR0011)//"Deseja incluir como local de estoque os armaz้ns configurados no e-commerce?"
				 lRet := .F.
			Else
				oModel:GetModel('SLJMASTER'):SetValue("LJ_LOCAL",cLocaisEC)
			EndIf
		Else
			MsgAlert(STR0012)//"Incluir locais de estoque para loja e-commerce"
			 lRet := .F.
		EndIf
	EndIf
	
	If lRet
		//Verifica se os armaz้ns estใo cadastrados para a filial informada
		
		aLocais		:= StrTokArr ( StrTran(oModel:GetValue( 'SLJMASTER', 'LJ_LOCAL' ) , " ", ""), ",") //Locais de Estoque
		
		aNNRArea := NNR->(GetArea())
		NNR->(DbSetOrder(1)) //NNR_FILIAL + NNR_CODIGO
	
		For nC := 1 to Len(aLocais)
			lRet := NNR->(DbSeek(xFilial("NNR", cFilCad) + aLocais[nC]))
			If !lRet
				MsgAlert(STR0013 + aLocais[nC] + STR0014)//"Nใo existe local de estoque ["##"] cadastrado para a filial"
				Exit
			EndIf
		Next
		
		If nOperation == MODEL_OPERATION_UPDATE 
			oModel:GetModel('SLJMASTER'):SetValue("LJ_ECDTEX"," ")
		EndIf
	
	EndIf
	
EndIf

//Grava os dados
If lRet
	lRet := FWFormCommit(oModel) 
EndIf

If lRet
	//Chamada processo loja off line
	Lj080AltOk("021","SLJ",cCodigo,1)
EndIf

RestArea( aArea )

Return lRet   


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLj080LocalบAutor  ณAndre Alves Veiga   บ Data ณ  29/05/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a validacao do campo de Local (almoxarifado)            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLj080Local( cLocal[, nOperacao] )                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ[1] - String contendo os locais (almoxarifados) no formato: บฑฑ
ฑฑบ          ณ      01,02,03 --> Aqui foram escolhidos os almox. 01, 02   บฑฑ
ฑฑบ          ณ                   e 03                                     บฑฑ
ฑฑบ          ณ      01-03,05 --> Aqui foram escolhidos os almox. 01, 02,  บฑฑ
ฑฑบ          ณ                   03 e 05                                  บฑฑ
ฑฑบ          ณ[2] - nOperacao (1)-Valida o campo | Retorno .T. ou .F.     บฑฑ
ฑฑบ          ณ                (2)-Retorna um array com os estoques        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Lj080Local( cLocal, nOperacao )
Local xRetorno
Local i, nX 
Local cLocalDe := ""
Local cLocalAte := ""
Local lRet := .T. 

Default nOperacao := 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz a validacao do campo                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cLocal := Alltrim(cLocal)
If nOperacao == 1
	xRetorno := lRet
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetorna a array com os locais escolhidos                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	xRetorno := {}
	For i:=1 to Len(cLocal)
		If Subst(cLocal,i,1) == '-'
			cLocalAte := Subst(cLocal,i+1,2)
			For nX := Val(cLocalDe) to Val(cLocalAte)
				aAdd(xRetorno,StrZero(nX,2,0))
			Next nX
			cLocalDe := ""
			cLocalAte := ""
			i := i+3
		ElseIf Subst(cLocal,i,1) == ','
			aAdd(xRetorno,cLocalDe)
			cLocalDe := ""
		Else
			cLocalDe += Subst(cLocal,i,1)
		Endif
	Next i
	If !Empty(cLocalDe)
		aAdd(xRetorno,cLocalDe)
	Endif
	
Endif

Return xRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณLj080AltOkณ Autor ณ IP-Vendas 			ณ Data ณ 12/04/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Define a operacao que sera realizada na tabela de 	      ณฑฑ
ฑฑณ			 ณ integracao de acordo com o processo de replicacao executadoณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Registros utilizados na integracao Off-line                ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Lj080AltOk( cProcess, cTabela, cChave, nOrdem, cTipo)
		
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn		:= .F.	        
		
lAmbOffLn	 		:= SuperGetMv("MV_LJOFFLN", Nil, .F.)	//Identifica se o ambiente esta operando em offline		

//Verifica se o ambiente esta em off-line
If lAmbOffLn
	//Instancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New(cProcess)
	
	//Determina o tipo de operacao 
	If Empty(cTipo)
		If INCLUI
			cTipo := "INSERT"
		ElseIf ALTERA
			cTipo := "UPDATE"
		Else
			cTipo := "DELETE"				
		EndIf
	Endif    
	
	If cTipo = "DELETE"				
		//Considera os registros deletados
		SET DELETED OFF
	EndIf
		    
	If !Empty(cTipo)
		//Insere os dados do processo (registro da tabela)
		oProcessOff:Inserir(cTabela, xFilial(cTabela) + cChave, nOrdem, cTipo)	
			
		//Processa os dados 
		oProcessOff:Processar()	
	EndIf
	
	//Desconsidera os registros deletados
	SET DELETED ON
EndIf
	
Return Nil
/*                         
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณLj080EcLoc ณ Autor ณ IP-Vendas 			ณ Data ณ 07/12/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Condi็ใo de Atualiza็ใo do Gatilho do Local de Estoque   ณฑฑ
ฑฑณ			 ณ  														  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Loja080													  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj080EcLoc()
Local lRet

lRet := !Empty(M->LJ_ECFLAG) .And. Empty(M->LJ_LOCAL)

Return lRet
