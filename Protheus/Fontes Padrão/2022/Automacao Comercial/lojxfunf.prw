#include "PROTHEUS.CH"
#include "LOJXFUNF.CH"

//****************************************************************************
//                             I M P O R T A N T E
//- N�o inicializar vari�veis com GETMV e SuperGetMV, ou outras fun- 
//��es que utilizem o dicion�rio pois a fun��o OnLoginLoj � executada ao abrir
// o sistema, para alterar o bot�o da tela de login, e nenhum
// dicion�rio foi inicializado neste momento
//****************************************************************************

Static __cProcPyme

/*����������������������������������������������������������������������������
��� Programa � ExecInLoj   � Autor � Vendas Crm        � Data � 02/02/2010 ���
��������������������������������������������������������������������������͹��
��� Desc.    � Menus                                                       ���
��������������������������������������������������������������������������͹��
���Sintaxe   � ExecInLoj(ExpN1)                                            ���
��������������������������������������������������������������������������͹��
���Parametros� ExpN1 = Nome                                        		   ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Retorno   � Nil                                                 		   ���
��������������������������������������������������������������������������͹��
���Uso       � SIGALOA                                                     ���
����������������������������������������������������������������������������*/
Function ExecInLoj( cName )
Local lChamIniPaf	:= .F.
Local lExecPAF		:= .F.
Local lCentPDV		:= IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Eh Central de PDV 
Local cRotinas		:= "" // Retorno do ponto de entrada LJXF001
Local aLjxBGetPaf	:= {}
Local lRet			:= .F.
Local lContinua		:= .T.

cName	:= Upper(cName) + '/'

If ( Subs( cName, 1, 1 ) $ '#&@' )
    lRet := .T.
    lContinua := .F.
EndIf

If lContinua
	aLjxBGetPaf := LjxBGetPaf()
	lChamIniPaf := aLjxBGetPaf[1]
	lExecPAF	:= aLjxBGetPaf[2]
	
	If lChamIniPaf .AND. lExecPAF
		If ( __cProcPyme == NIL )
			__cProcPyme	:= ''
			__cProcPyme += 'LOJA701'	+ '/'
			__cProcPyme += 'MATA030' 	+ '/'  
			__cProcPyme += 'CRMA980' 	+ '/'
			__cProcPyme += 'FRTA080'   	+ '/'   
			__cProcPyme += 'EDAPP' 		+ '/'
			__cProcPyme += 'LOJA120'   	+ '/'   
			__cProcPyme += 'LOJA121'   	+ '/'   
			__cProcPyme += 'LOJA420'	+ '/'
			__cProcPyme += 'LOJA1104'	+ '/'   
			__cProcPyme += 'LOJA1105'	+ '/'   
			__cProcPyme += 'LOJA1106'	+ '/'
			__cProcPyme += 'LOJA1107'	+ '/'
			__cProcPyme += 'LOJA1108'	+ '/'
			__cProcPyme += 'LOJA1130'	+ '/'
			__cProcPyme += 'LOJA1415'	+ '/' 
			__cProcPyme += 'LJ1415LP'	+ '/'		
			__cProcPyme += 'LJROTTEF'	+ '/'		
			__cProcPyme += 'LOJA260'	+ '/'
			__cProcPyme += 'LOJA0047'	+ '/' 
			__cProcPyme += 'LOJA1156'	+ '/'
			__cProcPyme += 'LOJA1157'	+ '/'
			__cProcPyme += 'LOJA1158'	+ '/' 
			__cProcPyme += 'CRDA010'	+ '/'
			__cProcPyme += 'LJWVALCONF'	+ '/'			
			__cProcPyme += 'LOJA251'	+ '/'
			__cProcPyme += 'STBMENFIS'	+ '/'
			__cProcPyme += Upper('LjWizNFCe')	+ '/'
			__cProcPyme += Upper('LjWizPAF') + '/'
			__cProcPyme += Upper('LjMonitPaf') + '/'
		EndIf
	ElseIf lChamIniPaf .AND. !lExecPAF
		If ( __cProcPyme == NIL )
			__cProcPyme	:= ''
		EndIf
	ElseIf lCentPDV  
		// Central de PDV 
		If ( __cProcPyme == NIL )  	
			__cProcPyme	:= ''
			__cProcPyme += 'LOJA701'	+ '/'	// Venda Assitida   			
			__cProcPyme += 'LOJA602'	+ '/'	// Estorno de venda 
			   
			__cProcPyme += 'LOJA120'   	+ '/'   // Perfil de Caixa
			__cProcPyme += 'LOJA121'   	+ '/'   // Cadastro de Estacao
			__cProcPyme += 'CFGA050'	+ '/' 	// Wizard do componente de comunicacao
			__cProcPyme += 'CFGA051'	+ '/' 	// Wizard do componente de comunicacao
			__cProcPyme += 'CFGA052'	+ '/' 	// Wizard do componente de comunicacao
			__cProcPyme += 'CFGA053'	+ '/' 	// Wizard do componente de comunicacao
			__cProcPyme += 'CFGA054'	+ '/' 	// Wizard do componente de comunicacao
			__cProcPyme += 'CFGA055'	+ '/' 	// Wizard do componente de comunicacao   
			
			__cProcPyme += 'LOJA1104'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1105'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1106'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1107'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1108'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1130'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA0047'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1156'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1157'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1158'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1176'	+ '/' 	// OffLine
			__cProcPyme += 'LOJA1415'	+ '/' 	// OffLine 
			
			If ExistBlock("LJXF001")
				cRotinas += ExecBlock("LJXF001",.F.,.F.)
			                                             
				If ValType( cRotinas ) == "C"
					__cProcPyme += cRotinas
				EndIf
			Endif
		EndIf
	Else   
		lRet := .T.
		lContinua := .F.
	EndIf
	
	If lContinua
		If cName $ __cProcPyme
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*����������������������������������������������������������������������������
��� Programa � LjxDataBar  � Autor � Varejo		       � Data � 29/03/2013 ���
��������������������������������������������������������������������������͹��
��� Desc.    � Faz a leitura a interpretacao do codigo de barras 		   ���
���			 � GS1 Data Bar.                                               ���
��������������������������������������������������������������������������͹��
���Parametros� ExpC1 = Codigo capiturado pelo leitor               		   ���
����������������������������������������������������������������������������*/
Function LjxDataBar(cCodDtaBar) 

Local cSymbolId := ""	// Simbolo identificador do tipo de cod bar
Local cAI		:= ""   // Application Identifiers
Local aReturn	:= {}   // Retorno da funcao em 2 dimensoes
Local cCodBar	:= ""   // Codigo de barras no padrao EAN 13
Local dDtValid	:= ""   // Data de validade do produto

DEFAULT cCodDtaBar := ""
//Separa os simbolos do databar, verifique o documento 
//Databar_GS1_General_Specifications_v13_Identificador_de_Simbologia.pdf (deve ser solicitado a GS1)
cSymbolId  	:= Substr(cCodDtaBar,1,3) 
cCodDtaBar 	:= Substr(cCodDtaBar,4,Len(cCodDtaBar)) 
cCodBar 	:= cCodDtaBar

If UPPER(cSymbolId) == "[E0" 	//GS1 DataBar

	While Len(cCodDtaBar) > 0
		cAI 	:= Substr(cCodDtaBar,1,2)

		If cAI == "01" 				// Tradicional EAN 13
			cCodBar		:= Substr(cCodDtaBar,4,13)
			cCodDtaBar  := Substr(cCodDtaBar,17,Len(cCodDtaBar))// Remove o trecho capiturado
			
		ElseIf cAI == "17"			// Data de Validade YYMMDD
			dDtValid	:=  STOD("20"+Substr(cCodDtaBar,3,6) )
			cCodDtaBar  := Substr(cCodDtaBar,9,Len(cCodDtaBar))	// Remove o trecho capiturado
		Else
			//Para esse primeiro modelo nao foram desenvolvidos todos os codigos AIs
			cCodDtaBar  := ""
		EndIf
	End
Else
	cCodBar 	:= cSymbolId + cCodDtaBar   // Caso nao encontre retorna o mesmo cod
EndIf

AAdd( aReturn, { cCodBar  }) // Tradicional EAN 13
AAdd( aReturn, { dDtValid }) // Data de Validade

Return aReturn

/*����������������������������������������������������������������������������
��� Programa � LjxMsgVenc  � Autor � Varejo		       � Data � 09/04/2013 ���
��������������������������������������������������������������������������͹��
��� Desc.    � Mostra a mensage na tela informando que o produto 		   ���
���			 � nao pode ser vendido, nesse caso esta vencido.	           ���
����������������������������������������������������������������������������*/
Function LjxMsgVenc()
Local oDlg		:= Nil								//Objeto dialog
local oFontText	:= Nil								//Fonte 
Local oFntMsg	:= Nil								//Fonte da mensagem
	
//Define as fontes
DEFINE FONT oFontText NAME "Courier New" SIZE 15,30 BOLD 
DEFINE FONT oFntMsg NAME "Arial" SIZE 10, 20 

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 323,412 TO 560,798 PIXEL STYLE DS_MODALFRAME STATUS //"Controle de Produtos"
		@ 005, 005 TO 50, 189 LABEL "" PIXEL OF oDlg  
		@ 003, 001 SAY STR0002+STR0003 PIXEL SIZE 180,040 FONT oFontText COLOR CLR_BLUE CENTERED //" PRODUTO N�O PODE "+"SER VENDIDO "

		oDlg:lEscClose := .F.
		@ 055,005 GET oMsgDet VAR STR0004 FONT oFntMsg MEMO SIZE 184,45 PIXEL WHEN .F.//"Necess�rio solicitar um superior para realizar a troca do produto."
	
		DEFINE SBUTTON FROM 105, 164 TYPE 1 ENABLE OF oDlg ACTION (oDlg:End())
	
ACTIVATE MSDIALOG oDlg CENTERED    
	
Return Nil

/*���������������������������������������������������������������������������
���Fun��o    | OnLoginLoj � Autor � Vendas Clientes     � Data � 14/06/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que executa ponto de entrada para habilitar menu 	���
���				fiscal na tela de Login do SIGALOJA						���
�������������������������������������������������������������������������Ĵ��
���Retorno� Bloco contendo nome do bot�o e fun��es que ser�o executadas   ���
�������������������������������������������������������������������������Ĵ�
��� Uso      � SIGAFRT                                                    ���
���������������������������������������������������������������������������*/
Function OnLoginLoj()
//Parametros:
//{ Nome do bot�o , fun��o(�es) }
Local bExcMenu := { "" , {|| .F. } }

//Habilita Menu Somente no PDV-PAF
If LjxBGetPaf()[2] //Indica se � pdv
	bExcMenu := {STR0005 , {|| LjMenFiLog(),MsgAlert(STR0006),__QUIT()}} //"Menu Fiscal" , "Sess�o encerrada"
Else
	bExcMenu := {STR0005 , {|| MsgAlert(STR0007) } } //"Menu Fiscal" , "Fun��o habilitada somente para PDV PAF-ECF"
EndIf

Return bExcMenu

/*���������������������������������������������������������������������������
���Fun��o    | LjMenFiLog � Autor � Vendas Clientes     � Data � 14/06/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que executa o menu 								  ���
���				fiscal na tela de Login do SIGALOJA						  ���
������������������������������������������������������������������������� ���
���Retorno� lRet														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFRT                                                    ���
���������������������������������������������������������������������������*/
Function LjMenFiLog(lLoadAmb)                                 
Local cArqINI	:= GetAdv97()                       							//Retorna o nome do arquivo INI do server
Local cRPCEmp 	:= GetPvProfString("Loja1115", "Parm1", "99", cArqINI) 			// Empresa
Local cRPCFil 	:= GetPvProfString("Loja1115", "Parm2", "01", cArqINI) 			// Filial
Local cEstacao	:= GetPvProfString("Loja1115", "Parm3", "001", cArqINI)			// Estacao
Local aTabelas	:= {'SM0','SL1', 'SL2', 'SL4', 'SF2', 'SD2', 'SLG', 'SFI', 'SF3', 'SFT', 'SA6'}

Default lLoadAmb	:= .T.  //Valida se carrega o ambiente pois na nova interface n�o h� Menu Fiscal na tela de login

//Necess�rio declarar estas duas variaveis para que seja possivel o acesso ao ECF
Private nHdlEcf := 0
Private nModulo := 12

If lLoadAmb
	RPCSetType(3)
	LjMsgRun(STR0008 ,, {|| RpcSetEnv(cRPCEmp,cRPCFil,,,"LOJA",,aTabelas) } )	//"Iniciando Ambiente ...."
EndIf

LjMsgRun(STR0009 ,, {|| OpenLoja() } ) //"Carregando Ambiente ...."	
LjxArqIdPaf()
STBMenFis(.F.)

If lLoadAmb
	RPCClearEnv()
EndIf

Return .T.

/*�����������������������������������������������������������������������Ŀ��
���Fun��o	 �LjGetCPDV � Autor � Vendas Cliente        � Data �10/06/13  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida entrada no sistema sendo Central de PDV              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � LjGetCPDV()    										      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nil                                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA1 - Se eh Central de PDV         						  ���
���Retorno   �ExpA2 - Se comunica com a Central de PDV (Usado nos PDVs)	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �Venda Assistida											  ���
���������������������������������������������������������������������������*/
Function LjGetCPDV()
Local aRet 			:= {} 				// Array de retorno
Local lIsCPDV		:= .F.				// Eh central de PDV
Local lComCPDV		:= .F.				// Se comunica com a central de PDV (Usado no PDVs)
Local cArqINI   	:= GetAdv97()      	// Retorna o nome do arquivo INI do server
Local cIsCPDV 		:= GetPvProfString("CPDV", "ISCPDV"		, "", cArqINI) // Identifica no INI se eh Central de PDV
Local cComCPDV 		:= GetPvProfString("CPDV", "COMCPDV"	, "", cArqINI) // Identifica no INI se comunica com a  Central de PDV
       
If AllTrim(cIsCPDV) = "1" 
	// Indica que o sistema foi iniciado como Central de PDV
	lIsCPDV := .T.
EndIf   

If AllTrim(cComCPDV) = "1" 
	// Indica que o sistema se comunica com a Central de PDV
	lComCPDV := .T.
EndIf 

If lIsCPDV .AND. lComCPDV                                          
	//Um ambiente n�o pode ser ao mesmo tempo Central e se comunicar com uma Central
	MsgAlert("Aten��o, Verifique as Configura��es do [CPDV] no .INI ")
EndIf

// Iniciou do executavel da Central de PDV
Aadd(aRet,lIsCPDV ) // 1 - Iniciou como Central de PDV
Aadd(aRet,lComCPDV) // 2 - Faz comunicao com a Central de PDV
 
Return aRet    

//----------------------------------------------------------
/*/{Protheus.doc} LjIpiPedEnt
Funcao responsavel por retornar o IPI proporcional aos itens ja entregues 
dos pedidos de entrega gerados pelo Loja
@param	 cPedido - Pedido Entrega
		 cItem   - Item do Pedido
		 nQtdEmp - Qtd Empenhada do item
		 nQtdEnt - Qtd Entregue do item
		 nQtdVen - Qtd Vendida do item
@author  Vendas & CRM
@version P12.17
@since   29/03/2018
@obs	 Chamado no Mata500 - Eliminar Residuo
/*/
//----------------------------------------------------------
Function LjIpiPedEnt(cPedido, cItem, nQtdEmp, nQtdEnt, nQtdVen)
Local aArea		 := GetArea()
Local nRet 		 := 0
Local nVlrIPIDev := 0
Local cQueryL2   := ''
Local cAliasL2   := ''

// Posiciona no registro SL1
dbSelectArea("SL1")
SL1->(dbSetOrder(1))
If SL1->(DbSeek(xFilial('SL1') + cPedido))
	If SL1->L1_VALIPI > 0  // Venda com IPI
		cQueryL2 := "SELECT L2_VALIPI FROM "
		cQueryL2 += RetSqlName("SL2")+" SL2 "
		cQueryL2 += "WHERE SL2.L2_FILIAL='"+xFilial("SL2")+"' AND "
		cQueryL2 += "SL2.L2_NUM='"+SL1->L1_NUM+"' AND "
		cQueryL2 += "SL2.L2_ITESC6='"+cItem+"' AND "
		cQueryL2 += "SL2.D_E_L_E_T_<>'*'"

		cQueryL2 := ChangeQuery(cQueryL2)
		cAliasL2 := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryL2),cAliasL2,.T.,.T.)
	
		If !(cAliasL2)->(Eof())
			nVlrIPIDev := (cAliasL2)->L2_VALIPI   // IPI total

			If (nQtdEmp + nQtdEnt) < nQtdVen  .And. (nQtdEmp + nQtdEnt) > 0 // entrega parcial									
				nVlrIPIDev := (cAliasL2)->L2_VALIPI-((cAliasL2)->L2_VALIPI*((nQtdEmp + nQtdEnt)/nQtdVen))   // Proporcionalizar o IPI em relacao a quantidade entregue e a quantidade vendida
			Endif

			nRet := nVlrIPIDev
		Endif

		(cAliasL2)->(DbCloseArea())
	Endif
Endif
					
RestArea(aArea)	

Return nRet					
