#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'DBTREE.CH'
#INCLUDE "TopConn.ch"  
#INCLUDE "CRMA120.CH"
#INCLUDE "FWMVCDEF.CH"
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA120

Estrutura SubClientes 

@sample 	CRMA120(nReg)

@param		nReg		Registro do cliente
	
@return	lRetorno	Verdadeiro /  Falso 

@author	Cristiane Nishizaka
@since		14/01/2014       
@version	P12   
/*/
//------------------------------------------------------------------------------

Function CRMA120()

Local lRetorno		:= .F.
Local oDlg			:= Nil
Local oTree		:= Nil
Local aSize		:= MsAdvSize(.F.)
Local oMenuPop		:= Nil
Local aMenuPop		:= {}
Local aAreaSA1		:= SA1->(GetArea())

Private INCLUI 	:= .F.

SaveInter()

If !MPUserHasAccess("CRMA120", 1, __cUserId)
 	Alert(STR0017)
Else
	DEFINE DIALOG oDlg TITLE STR0001 FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL  //"SubClientes"
		 	
		oTree := DbTree():New(0,0,160,260,oDlg,,,.T.)	// Insere itens    
		oTree:Align := CONTROL_ALIGN_ALLCLIENT
			
		// Posiciona no Pai
		While !Empty(SA1->A1_CLIPRI)
			SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			SA1->(DbSeek(xFilial("SA1")+SA1->A1_CLIPRI+SA1->A1_LOJPRI)) 		
		EndDo
		
		FATPDLoad(Nil,Nil,{"A1_NOME"}) 	
		
		//Monta estrutura		
		Crm120MTree(oTree,SA1->A1_COD,SA1->A1_LOJA)   
		
		FATPDUnload()
	
		MENU oMenuPop POPUP OF oTree
		
		aAdd(aMenuPop,MenuAddItem(STR0002,,,.T.,,,,oMenuPop,{|| A030Visual("SA1",GetRcnoCg(oTree:GetCargo()),1)},,,,,{ || .T. } )) 																				//"Visualizar"
		aAdd(aMenuPop,MenuAddItem(STR0003,,,.T.,,,,oMenuPop,{|| A030Altera("SA1",GetRcnoCg(oTree:GetCargo()),4)},,,,,{ || .T. } ))  																			//"Alterar"
		aAdd(aMenuPop,MenuAddItem(STR0004,,,.T.,,,,oMenuPop,{|| INCLUI := .T.,PosEstrut("OPORTUNIDADE",GetRcnoCg(oTree:GetCargo()))},,,,,{ || .T. } ))																			 //"Gerar Oportunidade"
		aAdd(aMenuPop,MenuAddItem(STR0005,,,.T.,,,,oMenuPop,{|| PosEstrut("APONTAMENTO",GetRcnoCg(oTree:GetCargo()))},,,,,{ || .T. } ))																			//"Gerar Apontamento"
		aAdd(aMenuPop,MenuAddItem(STR0006,,,.T.,,,,oMenuPop,{|| FtContato( "SA1", GetRcnoCg(oTree:GetCargo()), 2,,1)},,,,,{ || .T. } ))																			//"Contatos"
		aAdd(aMenuPop,MenuAddItem(STR0007,,,.T.,,,,oMenuPop,{|| GetLegend()	},,,,,{ || .T. } ))		//"Legenda"
	
		ENDMENU
		
		oTree:BrClicked := {|oTree,x,y| MenuAct(oTree,x,y,oMenuPop) } // Posição x,y em relação a Dialog	
		
		oTree:EndTree()
		
		
		  	
	ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lRetorno := .T., oDlg:End()},{||oDlg:End()}) CENTERED

EndIf
 
RestInter()

RestArea(aAreaSA1)

	
Return( lRetorno )     


//------------------------------------------------------------------------------
/*/{Protheus.doc} Crm120MTree

Monta a estrutura de SubClientes.

@sample 	Crm120MTree(oTree,cCliPai,cLojaPai) 

@param		oTree 		Objeto DbTree.
			cCliPai 	Cliente Pai.
			cLojaPai	Loja Pai.
	
@return	.T. 

@author	Cristiane Nishizaka
@since		14/01/2014       
@version	P12   
/*/ 
//------------------------------------------------------------------------------

Static Function Crm120MTree(oTree,cCliPai,cLojaPai)
Local aArea 	 := GetArea() 
Local aAreaSA1	 := SA1->(GetArea())
Local nRecno	 := 0					// Recno.

If !Empty(SA1->A1_CLIPRI)
	oTree:AddItem(STR0008+SA1->A1_COD+SA1->A1_LOJA+" | "+STR0009+FATPDObfuscate(SA1->A1_NOME,"A1_NOME"),SA1->A1_COD+SA1->A1_LOJA,"PMSTASK4","PMSTASK6",,,2) //Cliente Secundário(Fechado): Verde; Cliente Secundário/Primario (Aberto): Azul//"Código: "//"Nome: "
Else
	oTree:AddItem(STR0010+Space(65),"FOLDER12","FOLDER12",,,1) //Pasta Pai//"Estrutura de SubClientes"
	oTree:AddItem(STR0011+SA1->A1_COD+SA1->A1_LOJA+" | "+STR0012+FATPDObfuscate(SA1->A1_NOME,"A1_NOME"),SA1->A1_COD+SA1->A1_LOJA,"PMSTASK2","PMSTASK2",,,2)	//Cliente Primário: Amarelo//"Código: "//"Nome: "
EndIf

SA1->(DbSetOrder(11)) //A1_FILIAL+A1_CLIPRI+A1_LOJPRI+A1_COD+A1_LOJA                                                                                                                    
SA1->(DbSeek(xFilial("SA1")+cCliPai+cLojaPai))

While !SA1->(EOF()) .AND. SA1->A1_CLIPRI+SA1->A1_LOJPRI == cCliPai+cLojaPai
	oTree:TreeSeek(cCliPai+cLojaPai)
	nRecno := Recno()
	Crm120MTree(oTree,SA1->A1_COD,SA1->A1_LOJA)
	SA1->(DbGoTo(nRecno))		
	SA1->(DbSkip())
End 
 
RestArea(aAreaSA1)
RestArea(aArea)
Return( .T. )		
     

//------------------------------------------------------------------------------
/*{Protheus.doc} GetLegend

Retorna a lista das legendas disponiveis para a estrutura

@sample 	GetLegend() 

@return 	Nil	

@author	Cristiane Nishizaka
@since		14/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------	 

Static Function GetLegend()

oLegenda := FwLegend():New()

oLegenda:Add( "", "BR_AMARELO", STR0013 ) // "Cliente Primário"
oLegenda:Add( "", "BR_VERDE"  , STR0014 ) // "Cliente Secundário"
oLegenda:Add( "", "BR_AZUL"   , STR0015 ) // "Cliente Secundário/Primário"
oLegenda:View()		
		
oLegenda := Nil
DelClassIntf()

Return(Nil) 


//------------------------------------------------------------------------------
/*{Protheus.doc} GetRcnoCg

Retorna o registro do cliente selecionado na estrutura de SubClientes.

@sample 	GetRcnoCg(cCargo) 

@param		cCargo		Chave de identificação do item selecionado.

@return 	nCargo		Registro selecionado na estrutura de SubClientes

@author	Cristiane Nishizaka
@since		14/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------	 

Static Function GetRcnoCg(cCargo)

Local aArea 	 := GetArea()
Local aAreaSA1	 := SA1->(GetArea())
Local nCargo	 := Nil
Local cFilterDb  := ""

SA1->(DbSetOrder(1)) //A1_COD+A1_LOJA
cFilter := SA1->(DBFilter())

//Tirando o filtro , que esteja ativo na tabela
If !Empty(cFilter)
	SA1->(DbClearFilter())
EndIf

If SA1->(DbSeek(xFilial("SA1")+cCargo))
	nCargo	:= SA1->(Recno())
EndIf

If !Empty(cFilter)
	SA1->(dbSetFilter({|| cFilter  }, cFilter ))
EndIf

RestArea(aAreaSA1)
RestArea(aArea)

Return(nCargo)


//------------------------------------------------------------------------------
/*{Protheus.doc} GetListCli

Busca lista de clientes acessíveis ao usuário logado de acordo com a estrutura 
de negócio.

@sample 	GetListCli() 

@param		

@return 	aClientes 	Array de clientes

@author	Cristiane Nishizaka
@since		14/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function GetListCli()

Local aClientes 	:= {}
Local cWhere 		:= ""
Local cQuery 		:= ""
Local cCodVend 	:= ""
Local cOperador	:= IIf(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")

cCodVend :=  CRMXRetVend() //vendedor logado

//Tabela temporaria
If Select("TMPCONT") > 0
	DBSelectArea("TMPCONT")   
	TMPCONT->(DBCloseArea())
EndIf

// Busca clientes relacionados com o representante
 
cWhere := CRMXFilEnt("SA1",.T.)
If !Empty(cWhere)
	cWhere += " AND " 
	cQuery := " SELECT DISTINCT SA1.A1_FILIAL , SA1.A1_COD , SA1.A1_LOJA  FROM " +RetSqlName("SA1")+ " SA1 "+CRLF
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SA1.A1_FILIAL " + cOperador + " SA1.A1_COD " + cOperador + " SA1.A1_LOJA) = AO4.AO4_CHVREG "
	cQuery += "WHERE "+cWhere+" SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
EndIf


//Monta array de retorno
If !Empty(cQuery)
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery NEW ALIAS "TMPCONT" 
	While TMPCONT->(!Eof())
		Aadd(aClientes,{TMPCONT->A1_FILIAL,TMPCONT->A1_COD,TMPCONT->A1_LOJA})
		TMPCONT->(dbSkip())
	EndDo
	TMPCONT->(DBCloseArea())
EndIf

Return aClientes


//------------------------------------------------------------------------------
/*{Protheus.doc} PermCli

Verifica se o representante possui permissão para acessar o cliente de acordo 
com a estrutura de negócio.

@sample 	PermCli(aClientes, cCodCli, cEntid) 

@param		aClientes		Array de clientes
			cCodCli		Codigo cliente
			cEntid			Entidade da ação a ser executada no menu da estrutura 			

@return	lRet			.T. Possui
							.F. Não possui 	

@author	Cristiane Nishizaka
@since		14/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function PermCli(aClientes,cCodCli,cEntid)

Local aArea		:= {}
Local aAreaSA3		:= {}
Local aAreaACA		:= {}
Local cCodVend 	:= ""
Local lRet			:= .F.	
Local nPos			:= 0

//Verifica se o cliente (cCodCli) selecionado na estrutura é um dos clientes (aClientes) do vendedor logado. 
nPos := aScan(aClientes,{|x| x[1]+x[2]+x[3] == xFilial("SA1") + cCodCli})

If nPos <> 0
	lRet := .T.
EndIf

If lRet

	aArea	  	:= GetArea()
	aAreaSA3	:= SA3->(GetArea())	
	aAreaACA	:= ACA->(GetArea())
	cCodVend	:= CRMXRetVend()
	
	//Verifica se o vendedor tem permissão para alterar ou incluir oportunidades, apontamentos e contatos para o 
	//cliente selecionado na estrutra.
	DbSelectArea("SA3") //A3_FILIAL+A3_COD
	SA3->(DbSetOrder(1))
	
	DbSelectArea("ACA") //ACA_FILIAL+ACA_GRPREP 
	ACA->(DbSetOrder(1)) 
	
	If SA3->(DbSeek(xFilial("SA3")+cCodVend)) 
		If ACA->(DbSeek(xFilial("ACA")+SA3->A3_GRPREP))
			Do Case
				Case cEntid == "CLIENTES" 
					If !(ACA->ACA_ACCLIE $ "1|3|4|6|8") 
						lRet := .F.
					EndIf
				Case cEntid == "OPORTUNIDADES"
					If !(ACA->ACA_ACOPOR $ "1|3|4|5|7") 
						lRet := .F. 				
					EndIf
				Case cEntid == "APONTAMENTOS"
					If !(ACA->ACA_ACAPON $ "1|3|4|5|7") 
						lRet := .F. 				
					EndIf
			EndCase
		EndIf
	EndIf
	
	RestArea(aAreaACA)
	RestArea(aAreaSA3)
	RestArea(aArea)	
	
EndIf

Return lRet


//------------------------------------------------------------------------------
/*{Protheus.doc} MenuAct

Funcao de chamada do menu.

@sample 	MenuAct( oTree, nX, nY, oMenuPop ) 

@param		oTree		Objeto Tree
			nX			Dimensao X
			nY			Dimensao Y
			oMenuPop 	Objeto Menu		

@return		

@author	Cristiane Nishizaka
@since		14/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function MenuAct( oTree, nX, nY, oMenuPop )      

Local cCodVend := CRMXRetVend()
Local cCodUser := RetCodUsr()	

//Se módulo CRM e o usuário está vinculado a um vendedor, aplicar filtros
//Para administrador liberar os botões.
If nModulo == 73 .AND. !Empty(cCodVend) .And. cCodUser <> "000000"      

	//Obtem a lista de clientes acessíveis do usuário logado
	aClientes	:= GetListCli() 	
	
	//Desabilita todos os itens do menu 
	aEval( oMenuPop:aItems, { |x| x:Disable() } ) 
	
	cCargo := oTree:GetCargo() 
	
	//Habilita as opcoes de acordo com a entidade do tree 
	If PermCli(aClientes,oTree:GetCargo())
		oMenuPop:aItems[1]:enable() //Visualizar
		oMenuPop:aItems[5]:enable() //Contatos Relacionados
	EndIf
	If PermCli(aClientes,oTree:GetCargo(),"CLIENTES")	
		oMenuPop:aItems[2]:enable() //Alterar
	EndIf
	If PermCli(aClientes,oTree:GetCargo(),"OPORTUNIDADES")
		oMenuPop:aItems[3]:enable() //Gerar Oportunidade
	EndIf
	If PermCli(aClientes,oTree:GetCargo(),"APONTAMENTOS")
		oMenuPop:aItems[4]:enable() //Apontamentos
	EndIf
	oMenuPop:aItems[6]:enable()  //Legenda
	
EndIf

//Ativa o Menu PopUp                                  
oMenuPop:Activate( nX-20, nY-110, oTree )
                                   
Return()   

//------------------------------------------------------------------------------
/*{Protheus.doc} PosEstrut

Posiciona no cliente selecionado na estrutura e chama rotina de inclusão de apontamentos e oportunidades.

@sample 	PosEstrut(cOpc, nReg) 

@param		cOpc		Opção menu.
			nReg		Registro selecionado.	

@return		

@author	Cristiane Nishizaka
@since		14/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function PosEstrut(cOpc, nReg)

Local aAreaSA1	 := SA1->(GetArea())
Local cFilterDb  := ""
Default nReg     := 0



SA1->(DbSetOrder(1)) //A1_COD+A1_LOJA
cFilter := SA1->(DBFilter())

//Tirando o filtro , que esteja ativo na tabela
If !Empty(cFilter)
	SA1->(DbClearFilter())
EndIf

SA1->(DbGoto(nReg))

DbSelectArea("SA1")
SA1->(DbGoto(nReg))

If cOpc == "OPORTUNIDADE"
	CRM120IncOp()
Else
	CRM120IncAp()
EndIf	

If !Empty(cFilter)
	SA1->(dbSetFilter({|| cFilter  }, cFilter ))
EndIf

RestArea(aAreaSA1)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM120IncAp

Inclusão do cadastro de apontamento. 

@sample		CRM120IncAp()

@param			Nenhum

@return		Nenhum

@author		Vendas CRM
@since			27/03/2007
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function CRM120IncAp()

Local oModel     	:= Nil 
Local oView      	:= Nil
Local aSize     	:= FWGetDialogSize( oMainWnd ) 

oModel := FWLoadModel("FATA310")
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
//Passa o codigo do cliente posicionado
oModel:GetModel("AD5MASTER"):SetValue("AD5_VEND", CRMXRetVend())
oModel:GetModel("AD5MASTER"):SetValue("AD5_CODCLI", SA1->A1_COD)
oModel:GetModel("AD5MASTER"):SetValue("AD5_LOJA", SA1->A1_LOJA)
oView := FWLoadView("FATA310")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_INSERT) 
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)
            
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(Upper(STR0016)) // "Incluir"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
FATPDLogUser('CRM120INCA')	// Log de Acesso LGPD
oFWMVCWin:Activate()

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM120IncOp

Inclusão do cadastro de Oportunidade. 

@sample		CRM120IncOp()

@param			Nenhum

@return		Nenhum

@author		Vendas CRM
@since			27/03/2007
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function CRM120IncOp()

Local oModel  		:= FWLoadModel("FATA300")
Local oView    		:= Nil
Local aSize	 		:= FWGetDialogSize( oMainWnd )	
Local bCloseOnOk 	:= {|| } 
Local cCodVend	:= ""

Local lRet			:= .F.
Local lCancel			:= .F.

cCodVend := CRMXRetVend()

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()

oModel:GetModel("AD1MASTER"):SetValue("AD1_CODCLI"	,SA1->A1_COD)
oModel:GetModel("AD1MASTER"):SetValue("AD1_LOJCLI"	,SA1->A1_LOJA)
oModel:GetModel("AD1MASTER"):SetValue("AD1_NOMCLI"	,SA1->A1_NOME)			
  		
oView := FWLoadView("FATA300")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_INSERT)
  
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)
	
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0016)//"Incluir"
oFWMVCWin:oView:BCloseOnOk := {|| lRet:=.T.  }
oFWMVCWin:oView:oModel:BCancel := {|| lCancel:=.T.  }
FATPDLogUser('CRM120INCO')	// Log de Acesso LGPD
oFWMVCWin:Activate()
  	
If lCancel
	lRet := .F.
EndIf  	
  	
Return lRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

