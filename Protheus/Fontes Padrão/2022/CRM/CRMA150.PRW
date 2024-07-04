#include "CRMA150.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'DBTREE.CH'
#INCLUDE "TopConn.ch"
   
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA150

Estrutura SubContatos

@sample 	CRMA150(nReg)

@param		nReg		Registro do contato
	
@return	lRetorno	Verdadeiro /  Falso 

@author	Cristiane Nishizaka
@since		20/01/2014       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function CRMA150()
 
Local lRetorno	:= .F.
Local oDlg		:= Nil
Local oTree		:= Nil
Local aSize		:= MsAdvSize(.F.)
Local oMenuPop	:= Nil
Local aMenuPop	:= {}
Local aArea 	:= GetArea()
Local aAreaSU5	:= SU5->(GetArea())
Local aPDFields	:= {"U5_CONTAT"}	// Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.

aRotina := Menudef()
FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

DEFINE DIALOG oDlg TITLE STR0001 FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL  //"SubContatos"
	 	
	oTree := DbTree():New(0,0,160,260,oDlg,,,.T.)	// Insere itens    
	oTree:Align := CONTROL_ALIGN_ALLCLIENT	
	
	// Posiciona no Pai	
	While !Empty(SU5->U5_CONPRI)
		SU5->(DbSetOrder(1)) //U5_FILIAL+U5_CODCONT+U5_IDEXC
		SU5->(DbSeek(xFilial("SU5")+SU5->U5_CONPRI))
	EndDo
		
	//Monta estrutura		
	Crm150MTree(oTree,SU5->U5_CODCONT)   
	

	MENU oMenuPop POPUP OF oTree
	
	aAdd(aMenuPop,MenuAddItem(STR0002,,,.T.,,,,oMenuPop,{|| A70Visual("SU5",GetRcnoCg(PadL(oTree:GetCargo(),6)),2)},,,,,{ || .T. } )) 																				//"Visualizar"
	aAdd(aMenuPop,MenuAddItem(STR0003,,,.T.,,,,oMenuPop,{|| A70Altera("SU5",GetRcnoCg(PadL(oTree:GetCargo(),6)),4)},,,,,{ || .T. } ))  																			//"Alterar"
	aAdd(aMenuPop,MenuAddItem(STR0004,,,.T.,,,,oMenuPop,{|| TK010Con('SU5',GetRcnoCg(PadL(oTree:GetCargo(),6)),2) },,,,,{ || .T. } ))																			 //"Perfil do Contato"
	aAdd(aMenuPop,MenuAddItem(STR0005,,,.T.,,,,oMenuPop,{|| GetLegend()	},,,,,{ || .T. } ))		//"Legenda"

	ENDMENU
	
	oTree:BrClicked := {|oTree,x,y| MenuAct(oTree,x,y,oMenuPop) } // Posição x,y em relação a Dialog	
	
	oTree:EndTree()
	  	
ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lRetorno := .T., oDlg:End()},{||oDlg:End()}) CENTERED

//Finaliza o gerenciamento dos campos com proteção de dados.
FATPDUnLoad()   

RestArea(aAreaSU5)
RestArea(aArea)
	
Return( lRetorno )     


//------------------------------------------------------------------------------
/*/{Protheus.doc} Crm150MTree

Monta a estrutura de SubContatos.

@sample 	Crm150MTree(oTree,cContPai) 

@param		oTree 		Objeto DbTree.
			cContPai 	Contato Pai.
	
@return	.T. 

@author	Cristiane Nishizaka
@since		20/01/2014       
@version	P12   
/*/ 
//------------------------------------------------------------------------------

Static Function Crm150MTree(oTree,cContPai)
 
Local nRecno		:= 0				// Recno.
Local nIndexSU5 	:= 0

If !Empty(SU5->U5_CONPRI)
	oTree:AddItem(STR0006+U5_CODCONT+" | "+STR0007+FATPDObfuscate(SU5->U5_CONTAT,"U5_CONTAT"),SU5->U5_CODCONT,"PMSTASK4","PMSTASK6",,,2) //Contato Secundário(Fechado): Verde; Contato Secundário/Primario (Aberto): Azul//"Código: "//"Nome: "
Else
	oTree:AddItem(STR0008+Space(65),"FOLDER12","FOLDER12",,,1) //Pasta Pai//"Estrutura de SubContatos"
	oTree:AddItem(STR0009+SU5->U5_CODCONT+" | "+STR0010+FATPDObfuscate(SU5->U5_CONTAT,"U5_CONTAT"),SU5->U5_CODCONT,"PMSTASK2","PMSTASK2",,,2)	//Contato Primário: Amarelo//"Código: "//"Nome: "
EndIf

If cPaisLoc == "BRA"  
	nIndexSU5 := 12
Else
	nIndexSU5 := 11
EndIf

SU5->(DbSetOrder(nIndexSU5)) //U5_FILIAL+U5_CONPRI+U5_CODCONT	
SU5->(DbSeek(xFilial("SU5")+cContPai))

While !SU5->(EOF()) .AND. SU5->U5_CONPRI == cContPai
	oTree:TreeSeek(cContPai)
	nRecno := Recno()
	Crm150MTree(oTree,SU5->U5_CODCONT)
	SU5->(DbGoTo(nRecno))		
	SU5->(DbSkip())
End 
 
Return( .T. )		
     

//------------------------------------------------------------------------------
/*{Protheus.doc} GetLegend

Retorna a lista das legendas disponiveis para a estrutura

@sample 	GetLegend() 

@return 	Nil	

@author	Cristiane Nishizaka
@since		20/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------	 
Static Function GetLegend()

oLegenda := FwLegend():New()

oLegenda:Add( "", "BR_AMARELO", STR0011 ) // "Contato Primário" 
oLegenda:Add( "", "BR_VERDE"  , STR0012 ) // "Contato Secundário" 
oLegenda:Add( "", "BR_AZUL"   , STR0013 ) // "Contato Secundário/Primário" 
oLegenda:View()		
		
oLegenda := Nil
DelClassIntf()

Return(Nil) 


//------------------------------------------------------------------------------
/*{Protheus.doc} GetRcnoCg

Retorna o registro do contato selecionado na estrutura de SubContatos.

@sample 	GetRcnoCg(cCargo) 

@param		cCargo		Chave de identificação do item selecionado.

@return 	nCargo		Registro selecionado na estrutura de SubContatos.

@author	Cristiane Nishizaka
@since		20/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------	 

Static Function GetRcnoCg(cCargo)

Local nCargo		:= Nil

DbSelectArea("SU5")
DbSetOrder(1)	//U5_FILIAL+U5_CODCONT+U5_IDEXC

If DbSeek(xFilial("SU5")+cCargo)

	nCargo	:= SU5->(Recno())

EndIf

Return(nCargo)


//------------------------------------------------------------------------------
/*{Protheus.doc} GetListCont

Busca lista de contatos acessíveis ao usuário logado de acordo com a estrutura 
de negócio.

@sample 	GetListCont() 

@param		

@return 	aContatos 	Array de contatos

@author	Cristiane Nishizaka
@since		20/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function GetListCont()

Local aContatos 	:= {}
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
   

cWhere := CRMXFilEnt("SU5",.T.)
If !Empty(cWhere)
	cWhere += " AND " 
	cQuery := " SELECT DISTINCT SU5.U5_FILIAL , SU5.U5_CODCONT FROM " +RetSqlName("SU5")+ " SU5 "+CRLF
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SU5.U5_FILIAL " + cOperador + " SU5.U5_CODCONT) = AO4.AO4_CHVREG "  
	cQuery += "WHERE "+cWhere+" SU5.D_E_L_E_T_ = '' AND SU5.U5_FILIAL = '"+xFilial("SU5")+"'"
EndIf
   

//Monta array de retorno
If !Empty(cQuery)
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery NEW ALIAS "TMPCONT" 
	While TMPCONT->(!Eof())
		Aadd(aContatos,{TMPCONT->U5_FILIAL, TMPCONT->U5_CODCONT})
		TMPCONT->(dbSkip())
	EndDo
	TMPCONT->(DBCloseArea())
EndIf

Return aContatos


//------------------------------------------------------------------------------
/*{Protheus.doc} PermCont

Verifica se o representante possui permissão para acessar o contato de acordo 
com a estrutura de negócio.

@sample 	PermCont(aContatos, cCodCont, cOpc) 

@param		aContatos		Array de contatos
			cCodCont		Codigo contato	
			cOpc			Opção menu	

@return	lRet			.T. Possui
							.F. Não possui 	

@author	Cristiane Nishizaka
@since		14/01/2014       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function PermCont(aContatos,cCodCont,cOpc)

Local aArea		:= {}
Local aAreaSA3		:= {} 
Local aAreaACA		:= {}
Local cCodVend 	:= ""
Local lRet			:= .F.	
Local nPos			:= 0
Local nX

//Verifica se o contato (cCodCont) selecionado na estrutura é um dos contatos (aContatos) do vendedor logado. 
nPos := aScan(aContatos,{|x| x[1]+x[2] == xFilial("SU5") + cCodCont})

If nPos <> 0
	lRet := .T.
EndIf

If lRet

	aArea	  	:= GetArea()
	aAreaSA3	:= SA3->(GetArea())	
	aAreaACA	:= ACA->(GetArea())
	cCodVend	:= CRMXRetVend()
	
	//Verifica se o vendedor tem permissão para alterar o cadastro do contato selecionado na estrutura
	DbSelectArea("SA3") //A3_FILIAL+A3_COD
	SA3->(DbSetOrder(1))
	
	DbSelectArea("ACA") //ACA_FILIAL+ACA_GRPREP 
	ACA->(DbSetOrder(1)) 
	
	If SA3->(DbSeek(xFilial("SA3")+cCodVend)) 
		If ACA->(DbSeek(xFilial("ACA")+SA3->A3_GRPREP))
			If !Empty(cOpc)
				If !(ACA->ACA_ACCONT $ "1|3|4|6|8") 
					lRet := .F.
				EndIf
			EndIf
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

Local cCodVend		:=   ""                      


cCodVend	:= CRMXRetVend()


//Se módulo CRM e o usuário está vinculado a um vendedor, aplicar filtros
If nModulo == 73 .AND. !Empty(cCodVend) 

	//Obtem a lista de contatos acessíveis do usuário logado
	aContatos	:= GetListCont() 	
	
	//Desabilita todos os itens do menu 
	AEval( oMenuPop:aItems, { |x| x:Disable() } ) 
	
	cCargo := oTree:GetCargo() 
	
	//Habilita as opcoes de acordo com o registro do tree 
	If PermCont(aContatos,PadL(oTree:GetCargo(),6),"")
		oMenuPop:aItems[1]:enable() //Visualizar
	EndIf
	If PermCont(aContatos,PadL(oTree:GetCargo(),6),"ALTERAR")	
		oMenuPop:aItems[2]:enable() //Alterar
		oMenuPop:aItems[3]:enable() //Perfil do Contato
	EndIf
	oMenuPop:aItems[4]:enable()  //Legenda
	
EndIf	

//Ativa o Menu PopUp                                  
oMenuPop:Activate( nX-20, nY-160, oTree )
                                   
Return  

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opções disponíveis no POPUP do subcontatos.

@return aRotina Rotinas que serão exibidas no menu. 

@author     Alex Silva Santos
@version    12.1.17
@since      13/09/2017
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

	aRotina := StaticCall(TMKA070, MENUDEF)

Return( aRotina )

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
