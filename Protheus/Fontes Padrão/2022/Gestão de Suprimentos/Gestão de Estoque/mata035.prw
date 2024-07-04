#INCLUDE "MATA035.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#DEFINE nTamRot 50
#DEFINE nTamMod 50

Static cXX4Model

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA035  � Autor �  Eduardo Motta        � Data � 20/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao de Grupo                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri�ao � PLANO DE MELHORIA CONTINUA        �Programa    MATA035.PRW ���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data       	|BOPS             ���
�������������������������������������������������������������������������Ĵ��
���      01  �                          �           	|                 ���
���      02  �                          �           	|                 ���
���      03  �                          �           	|                 ���
���      04  � Ricardo Berti            � 20/04/2006	| 096844          ���
���      05  �                          �           	|                 ���
���      06  �                          �           	|                 ���
���      07  � Ricardo Berti            � 20/04/2006	| 096844          ���
���      08  �                          �           	|                 ���
���      09  �                          �           	|                 ���
���      10  �                          �           	|                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function MATA035(aRotAuto,nOpcAuto)

Default nOpcAuto := 3

If nModulo <> 89 .AND. !(ValidEAI() .AND. SupergetMV("MV_INTTUR",,.F.))
	//��������������������������������������������������������������Ŀ
	//� Gravar no arquivo SBM o conteudo da tabela 03 do SX5         �
	//����������������������������������������������������������������

	A508Grupo()
	If	aRotAuto <> NIL
		Private aRotina := MenuDef()
		FWMVCRotAuto(ModelDef(),"SBM",nOpcAuto,{{"MATA035_SBM",aRotAuto}})	
	Else
		oMBrowse:= FWMBrowse():New()
		oMBrowse:SetAlias("SBM")
		oMBrowse:DisableDetails()
		oMBrowse:SetAttach( .T. )//Habilita as vis�es do Browse
		//Se n�o for SIGACRM inibe a exibi��o do gr�fico
		If nModulo <> 73
			oMBrowse:SetOpenChart( .F. )
		EndIf
		oMBrowse:SetTotalDefault('BM_GRUPO','COUNT',STR0018)//'Total de Registros'
		ACTIVATE FWMBROWSE oMBrowse
	EndIf
Else

	oBrowse := FWLoadBrw("MATA035")   
 
	oBrowse:Activate()
EndIf	

Return .T.     
                               
Static Function BrowseDef()
Local oBrowse as object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SBM")
	oBrowse:SetDescription(STR0001)  //"Grupo"
	oBrowse:SetOnlyFields( { 'BM_FILIAL', 'BM_GRUPO', 'BM_DESC', 'BM_CODGRT', 'BM_DESGRT','BM_CLASGRU', 'BM_CONC', 'BM_CORP', 'BM_EVENTO', 'BM_LAZER'  } ) // Define campos q aparecerao no browser 

Return oBrowse 
                               
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A035Visual� Autor � Nereu Humberto Junior � Data � 19/07/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Grupos de Produtos              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A035Visual(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA035                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

FUNCTION A035Visual(cAlias,nReg,nOpc)

LOCAL nOpcA    := 0      
LOCAL aButtons := {}
LOCAL aUsrBut  := {}

If ExistBlock( "MA035BUT" ) 
	If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIf 
EndIf 		

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA := AxVisual(cAlias,nReg,nOpc,,,,,aButtons )

dbSelectArea(cAlias)

Return Nil
      

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A035Inclui� Autor � Nereu Humberto Junior � Data � 19/07/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Grupo de Produtos               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A035Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA035                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A035Inclui(cAlias,nReg,nOpc)

LOCAL nOpcA    := 0      
LOCAL aButtons := {}
LOCAL aUsrBut  := {}
LOCAL lPIMSINT := (SuperGetMV("MV_PIMSINT",.F.,.F.))// Indica se Existe Integra��o Protheus x PIMS Graos 
Local aIntSBM	:= {}
Local aParam	:= {{|| .T.}, {|| .T.}, {|| .T.}, {||A035Int( 2, nOpc, aIntSBM )}}	// Bloco de c�digo executado ap�s a transa��o da inclus�o do cliente
Local lMa035Inc := ExistBlock( "MA035INC" )

If ExistBlock( "MA035BUT" ) 
	If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIf 
EndIf 		

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

	A035Int( 1, nOpc, aIntSBM )

	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0
	nOpcA := AxInclui(cAlias,nReg,nOpc, , , ,"Ma035Valid(nOpc)", , ,aButtons, aParam )
	If nOpcA == 1
	If lMa035Inc
			Execblock( "MA035INC", .F., .F.)
		EndIf
		//������������������������������Ŀ
		//� Integracao PIMS GRAOS        �
		//��������������������������������
		If lPIMSINT
			PIMSGeraXML("MaterialFamily",STR0010,"2","SBM")
		EndIf 
		
		//� Integracao Shopify - Adicionado integra��o com Shopify SHPXFUN.PRW
		If cPaisLoc == 'EUA' .AND. SuperGetMv("MV_SHOPIFY",.F.,.F.) .AND. FindFunction("SPYCMAT035")
			SPYCMAT035()   
		EndIf        	             			
	EndIf

dbSelectArea(cAlias)

Return Nil


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A035Altera� Autor � Nereu Humberto Junior � Data � 19/07/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Grupo de Produtos               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A035Altera(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA035                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A035Altera(cAlias,nReg,nOpc)
Local aArea		:= GetArea()
LOCAL nOpcA:=0 
LOCAL aButtons := {}
LOCAL aUsrBut  := {}
LOCAL lPIMSINT := (SuperGetMV("MV_PIMSINT",.F.,.F.))// Indica se Existe Integra��o Protheus x PIMS Graos 
Local aIntSBM	:= {}
Local aParam	:= {{|| .T.}, {|| .T.}, {|| .T.}, {||A035Int( 2, nOpc, aIntSBM )}}	// Bloco de c�digo executado ap�s a transa��o da inclus�o do cliente
Local lMa035Alt := ExistBlock( "MA035ALT" )

If ExistBlock( "MA035BUT" ) 
	If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIf 
EndIf 		

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

A035Int( 1, nOpc, aIntSBM )

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA:=0
nOpcA := AxAltera( cAlias, nReg, nOpc, , , , , "Ma035Valid(nOpc)", , , aButtons, aParam )
If nOpcA == 1
	If lMa035Alt
		Execblock( "MA035ALT", .F., .F. )
	EndIf
	//������������������������������Ŀ
	//� Integracao PIMS GRAOS        �
	//��������������������������������
	If lPIMSINT
		PIMSGeraXML("MaterialFamily",STR0010,"2","SBM")
	EndIf
	//� Integracao Shopify - Adicionado integra��o com Shopify SHPXFUN.PRW
	If cPaisLoc == 'EUA' .AND. SuperGetMv("MV_SHOPIFY",.F.,.F.) .AND. FindFunction("SPYCMAT035")
		SPYCMAT035()
	EndIf

EndIf

RestArea( aArea )
Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A035Deleta� Autor � Nereu Humberto Junior � Data � 19/07/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Grupo de Produtos               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A035Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA035                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A035Deleta(cAlias,nReg,nOpc)

Local nOpcA		:= 0
Local aButtons  := {}
Local aUsrBut   := {}  
Local aArea		:= GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local lRet		:= .T.
Local aIntSBM	:= {}
Local aParam	:= {{|| .T.}, {|| MATA035Ex()}, {|| .T.}, {|| .T.}}  
Local cAliasAAI	:= ""
Local cQuery	:= ""
Local cMsg	    := ""
Local cAliasACP	:= ""
Local cAliasACR := ""
Local cAliasACX := ""
Local cAliasAI2	:= ""
Local cAliasDA1	:= ""

If ExistBlock( "MA035BUT" ) 
	If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIf 
EndIf 

(cAlias)->(dbGoto(nReg))

//������������������������������������������������������������Ŀ
//� Verifica se o Grupo de Produto est� vinculado a um Produto �
//��������������������������������������������������������������                
SB1->(dbSetOrder(4)) //B1_FILIAL+B1_GRUPO+B1_COD
If SB1->(MsSeek(xFilial("SB1")+(cAlias)->BM_GRUPO))
	Help(" ",1,"A035EXGRPR") 
	lRet := .F.
EndIf		

//������������������������������������������������������������Ŀ
//� Verifica se o Grupo est� vinculado a um Respons�vel		   �
//��������������������������������������������������������������                
If lRet
	dbSelectArea("AGX")
	AGX->(dbSetOrder(2)) //AGX_FILIAL+AGX_GRUPO+AGX_CODRSP
	If AGX->(dbSeek(xFilial("AGX")+(cAlias)->BM_GRUPO))
		Help(" ",1,"NODELETA",,STR0014,2,0)	//"Este grupo esta sendo utilizado pela rotina de Respons�veis X Grupo de Produtos."
		lRet := .F.
	EndIf
EndIf	

//����������������������������������������������������������������Ŀ
//� Verifica se o Grupo de Produto est� vinculado a um Solicitante �
//������������������������������������������������������������������    
If lRet .And. MATA035Sol(cAlias)
   lRet := .F.
EndIf

If lRet .And. !SoftLock(cAlias)
	lRet := .F.
Endif
  
If lRet
   cAliasAAI := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "AAI" )
   cQuery += "  WHERE AAI_FILIAL='" + xFilial( "AAI" ) + "'"
   cQuery += "    AND AAI_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAAI,.F.,.T. )

   If (cAliasAAI)->TOT_GRP > 0      
      Help(" ",1,"HELP", , STR0015, 3, 1 )  //"EEste grupo esta sendo utilizado por uma tabela (FAQ) e nao podera ser excluida."
      lRet := .F.
   Endif
   (cAliasAAI)->(DbCloseArea())   
EndIf   

If lRet
   cAliasDA1 := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "DA1" )
   cQuery += "  WHERE DA1_FILIAL = '" + xFilial( "DA1" ) + "'"
   cQuery += "    AND DA1_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.F.,.T. )

   If (cAliasDA1)->TOT_GRP > 0      
      Help(" ",1,"NODELETA",,STR0019,2,0)	//"Este grupo esta sendo utilizado pela rotina de Tabela de Pre�o."
      lRet := .F.
   Endif
   (cAliasDA1)->(DbCloseArea())   
EndIf   


//����������������������������������������������������������������������Ŀ
//� Verifica se o Grupo de Produto est� vinculado a uma regra de negocio �
//������������������������������������������������������������������������    
If lRet

   cAliasACP := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "ACP" )
   cQuery += "  WHERE ACP_FILIAL='" + xFilial( "ACP" ) + "'"
   cQuery += "    AND ACP_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACP,.F.,.T. )

	If (cAliasACP)->TOT_GRP > 0
	      
		SX2->(MsSeek("ACP"))
		cMsg := STR0016+' "'+Lower(Alltrim(X2Nome()))+'"'+CRLF //"Ha itens em" 
		SX2->(MsSeek("SBM"))
		cMsg += Lower(STR0017+Alltrim(X2Nome()))+CRLF // "utilizando o "
		
		Help(" ",1,"NODELETA",,cMsg ,3)
		lRet := .F.
   Endif
   (cAliasACP)->(DbCloseArea())   


EndIf   

//��������������������������������������������������������������������������Ŀ
//� Verifica se o Grupo de Produto est� vinculado a uma regra de Bonifica��o �
//����������������������������������������������������������������������������    
If lRet

   cAliasACR := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "ACR" )
   cQuery += "  WHERE ACR_FILIAL='" + xFilial( "ACR" ) + "'"
   cQuery += "    AND ACR_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACR,.F.,.T. )

	If (cAliasACR)->TOT_GRP > 0
	      
		SX2->(MsSeek("ACR"))
		cMsg := STR0016+' "'+Lower(Alltrim(X2Nome()))+'"'+CRLF //"Ha itens em" 
		SX2->(MsSeek("SBM"))
		cMsg += Lower(STR0017+Alltrim(X2Nome()))+CRLF // "utilizando o "
		
		Help(" ",1,"NODELETA",,cMsg ,3)
		lRet := .F.
   Endif
   (cAliasACR)->(DbCloseArea())   


EndIf 

If lRet

   cAliasACX := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "ACX" )
   cQuery += "  WHERE ACX_FILIAL='" + xFilial( "ACX" ) + "'"
   cQuery += "    AND ACX_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACX,.F.,.T. )

   If (cAliasACX)->TOT_GRP > 0      
		SX2->(MsSeek("ACX"))
		cMsg := STR0016+' "'+Lower(Alltrim(X2Nome()))+'"'+CRLF //"Ha itens em" 
		SX2->(MsSeek("SBM"))
		cMsg += Lower(STR0017+Alltrim(X2Nome()))+CRLF // "utilizando o "
		
		Help(" ",1,"NODELETA",,cMsg ,3)
		lRet := .F.
   Endif
   (cAliasACX)->(DbCloseArea())   
EndIf   


If lRet

   cAliasAI2 := GetNextAlias()
   cQuery    := ""

   cQuery += " SELECT COUNT(*) TOT_GRP "
   cQuery += "   FROM " + RetSqlName( "AI2" )
   cQuery += "  WHERE AI2_FILIAL='" + xFilial( "AI2" ) + "'"
   cQuery += "    AND AI2_GRUPO = '" + (cAlias)->BM_GRUPO+ "'"
   cQuery += "    AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery( cQuery )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAI2,.F.,.T. )

   If (cAliasAI2)->TOT_GRP > 0      
		SX2->(MsSeek("AI2"))
		cMsg := STR0016+' "'+Lower(Alltrim(X2Nome()))+'"'+CRLF //"Ha itens em" 
		SX2->(MsSeek("SBM"))
		cMsg += Lower(STR0017+Alltrim(X2Nome()))+CRLF // "utilizando o "
		
		Help(" ",1,"NODELETA",,cMsg ,3)
		lRet := .F.
   Endif
   (cAliasAI2)->(DbCloseArea())   
EndIf   


RestArea(aArea)    
RestArea(aAreaSB1)    
    
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MATA035EX � Autor � Eduardo Motta         � Data � 28/09/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se pode ser feita a exclusao                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA035Ex()

Local aArquivos	:= {}
Local lRet		    := .T.
Local aArea		:= GetArea()

//�����������������������������������Ŀ
//� Verifica se utilizado em produtos.�
//�������������������������������������
dbSelectArea("SB1")
dbSetOrder(4)
If dbSeek(xFilial()+SBM->BM_GRUPO)
	Aviso(STR0002,STR0003,{STR0004},2) //"Atencao!"###"Este grupo de produto esta sendo utilizado em algum produto e nao podera ser excluido."###"Voltar"
	lRet := .F.
ElseIf GetMV('MV_VEICULO') == 'S'
   aadd(aArquivos,{"AAB","AAB_GRUPO ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"AAI","AAI_GRUPO ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SAD",2           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SB1",4           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SB4","B4_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SBI",4           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SC9","C9_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SCT","CT_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SD1","D1_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SD2","D2_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"SD3","D3_GRUPO  ", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE4","VE4_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE6","VE6_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE8",1           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE8",2           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VE9",5           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VEH",1           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VEK","VEK_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VF6","VF6_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VF7","VF7_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VF8","VF8_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VF9","VF9_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VFC","VFC_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VG5","VG5_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VG6","VG6_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VG8","VG8_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VO3",2           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VO8","VO8_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VOK","VOK_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VOV",1           , SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VS3","VS3_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VSD","VSD_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VV6","VV6_GRUITE", SBM->BM_GRUPO,   })
   aadd(aArquivos,{"VVT","VVT_GRUITE", SBM->BM_GRUPO,   })
   lRet := FG_DELETA(aArquivos)
EndIf

If lRet
	If (ExistBlock("MT035EXC"))
		lRet := ExecBlock("MT035EXC",.F.,.F.)
		If Valtype( lRet ) <> "L"
			lRet := .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet  

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �01/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados			  ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()     
Local aArea   := GetArea()

Private aRotina := {}

// ADICIONA MENU
ADD OPTION aRotina TITLE STR0005  ACTION 'PesqBrw' 			OPERATION OP_PESQUISAR	ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0006  ACTION 'VIEWDEF.MATA035'	OPERATION OP_VISUALIZAR	ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0007  ACTION 'VIEWDEF.MATA035'	OPERATION OP_INCLUIR	ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0008  ACTION 'VIEWDEF.MATA035'	OPERATION OP_ALTERAR	ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0009  ACTION 'VIEWDEF.MATA035'	OPERATION OP_EXCLUIR	ACCESS 0 // "Excluir"

If nModulo <> 89 .AND. !(ValidEAI() .AND. SupergetMV("MV_INTTUR",,.F.))
	//������������������������������������������������������������������������Ŀ
	//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
	//��������������������������������������������������������������������������
	If ExistBlock("MTA035MNU")
		ExecBlock("MTA035MNU",.F.,.F.)
	EndIf
	aRotina := CRMXINCROT("SBM",aRotina)
EndIf	

RestArea(aArea)

Return(aRotina) 
                                                                          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ma035Valid� Autor � Andre Sperandio       � Data � 14/08/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Alteracao		                        	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ma035Valid(nOpc)

Local lRet 	:= .T.
Local lRetPE:= .T.

If lRet .And. ExistBlock('MA035VLD')
	lRet := If(ValType(lRetPE := ExecBlock('MA035VLD',.F.,.F., { nOpc }))=='L', lRetPE, lRet)
EndIf

Return lRet                   

/*
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������Ŀ��
���Fun��o    �MATA035SOL� Autor � Aline Sebrian                      � Data � 03/10/08 ���
��������������������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se existe solicitante vinculado ao grupo de produtos           ���
��������������������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                                         ���
��������������������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                                ���
���������������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
*/
Function MATA035Sol(cAlias)    

Local lRet		 := .F.   
Local cAliasSAI := ""      


Local cQuery    := ""

cAliasSAI := GetNextAlias()
 	
If Select(cAliasSAI) > 0 
	dbSelectArea(cAliasSAI)
	dbCloseArea()
EndIf
    
cQuery    := "SELECT AI_FILIAL, AI_GRUPO "
cQuery    += "FROM "+RetSqlName("SAI")+" SAI "     
cQuery    += "WHERE SAI.AI_FILIAL='"+xFilial("SAI")+"' AND "
cQuery    += " SAI.AI_GRUPO='"+(cAlias)->BM_GRUPO+"' AND "
cQuery    += "SAI.D_E_L_E_T_=' ' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSAI, .T., .T. )      

If (cAliasSAI)->(!Eof())
   	Help(" ",1,"A035EXGRSO") 
	lRet := .T.
EndIf

(cAliasSAI)->(dbCloseArea())

Return lRet  

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A035Int� Autor � Vendas CRM               � Data � 15/09/2009 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza integracao com a criterium ou outra integracao       ���
���          �que utiliza o framework do SIGALOJA de integracao.            ���
���          � O par�metro aIntSB1 normalmente � vazio.                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �A035Int()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: Momento da chamada, sendo:                             ���
���          �           1: Antes de qualquer altera��o                     ���
���          �           2: Depois das altera��es                           ���
���          �ExpN2: Op��o da rotina                                        ���
���          �ExpA3: Array contendo o n�mero do registro e adaptador do SBM.���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function A035Int( nMomento, nOpc, aIntSBM )

	Local lIntegra 		:= SuperGetMv("MV_LJGRINT", .F., .F.)	// Se h� integra��o ou n�o
	Local aArea			:= GetArea()

	If lIntegra
		If nMomento == 1
			MsgRun( STR0012, STR0011, {|| A035IniInt( nOpc, aIntSBM ) } ) // "Aguarde" "Anotando registros para integra��o"
		ElseIf nMomento == 2			
			MsgRun( STR0013, STR0011, {|| A035FimInt( nOpc, aIntSBM ) } ) // "Aguarde" "Executando integra��o"
		EndIf
	EndIf
	
	RestArea( aArea )
Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A035IniInt   � Autor � Vendas CRM         � Data � 15/09/2009 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Faz o cache dos itens antes de serem exclu�dos, possibilitan-���
���          �do o envio dos mesmos, mesmo ap�s de serem apagados.          ���
���          � O par�metro aIntSBM normalmente � vazio.                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �A035IniInt()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: Op��o da rotina                                        ���
���          �ExpA2: Array contendo o n�mero do registro e adaptador do SBM.���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function A035IniInt( nOpc, aIntSBM )
	Local oFactory		:= LJCAdapXmlEnvFactory():New()
	Local cChave		:= ""
	
	// Se houver integra��o e n�o for inclus�o, anota todos os registros para exclus�o, caso algum seja exclu�do
	If nOpc != 3
		aIntSBM :=	{ SBM->(Recno()), oFactory:Create( "SBM" ) }		
		cChave 	:= xFilial( "SBM" ) + SBM->BM_GRUPO
	    aIntSBM[2]:Inserir( "SBM", cChave, "1", "5" )
	    aIntSBM[2]:Gerar()
	EndIf	
Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A035FimInt   � Autor � Vendas CRM         � Data � 15/09/2009 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Envia os itens apagados e todos os outros itens.             ���
���          � O par�metro aIntSBM normalmente � vazio.                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �A035FimInt()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: Op��o da rotina                                        ���
���          �ExpA2: Array contendo o n�mero do registro e adaptador do SBM.���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function A035FimInt( nOpc, aIntSBM )
	Local oFactory		:= LJCAdapXmlEnvFactory():New( )	// Cria a fabrica de Adaptadores de envio
	Local cChave		:= ""
	
	// Verifica se houve algum registro apagado, e gera a integra��o desse registro
	If nOpc != 3
		If Len(aIntSBM) > 0
			// Procura pelo registro do cabe�alho
			SBM->(DbGoTo( aIntSBM[1] ) ) 
			
			// Se n�o encontrar, significa que o cabe�alho foi apagado, ent�o envia somente a exclus�o do cabe�alho
			If SBM->( DELETED() )
				aIntSBM[2]:Finalizar()
			EndIf
		EndIf
	EndIf
	
	// Independente de ter registros apagados ou n�o, gera quando n�o for exclus�o, todos os outros registros
	If nOpc != 5
		aIntSBM := { SBM->( Recno() ), oFactory:Create( "SBM" ) }		
		cChave 	:= xFilial( "SBM" ) + SBM->BM_GRUPO
	    aIntSBM[2]:Inserir( "SBM", cChave, "1", cValToChar( nOpc ) )
	    aIntSBM[2]:Gerar()
		aIntSBM[2]:Finalizar()
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do cadastro de grupo de produtos

@author Leandro F. Dourado
@since 05/04/2012
@version P12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oStructG3K  	:= Nil
Local oStructSBM 	:= Nil
Local oModel     	:= Nil
Local auMovStatus 	:= {}
Local oEvent  		:= Nil

If nModulo <> 89 .AND. !(ValidEAI() .AND. SupergetMV("MV_INTTUR",,.F.))

	//-----------------------------------------
	//Monta a estrutura do formul�rio com base no dicion�rio de dados
	//-----------------------------------------
	oStructSBM := FWFormStruct(1,"SBM",{||.T.})

	//-----------------------------------------
	//Monta o modelo do formul�rio
	//-----------------------------------------
	oEvent:= MATA035EvDef():New()
	oModel:= MPFormModel():New("MATA035", /*{| oModel | A035PreVld(oModel, auMovStatus) }*/, /*{| oModel | A035PosVld(oModel, auMovStatus) }*/, /*{| oModel | Mt035Grv(oModel, auMovStatus)}*/ )
	oModel:AddFields("MATA035_SBM", Nil, oStructSBM )
	oModel:GetModel("MATA035_SBM"):SetDescription(STR0010)
	oModel:InstallEvent("MATA035EvDef", /*cOwner*/, oEvent)

	//Integracao Shopify - Adicionado integra��o com Shopify SHPXFUN.PRW
	If cPaisLoc == 'EUA' .AND. SuperGetMv("MV_SHOPIFY",.F.,.F.) .AND. FindFunction("SPYIMAT035")
		SPYIMAT035(@oModel)
	EndIf
Else
	//-----------------------------------------
	//Monta a estrutura do formul�rio com base no dicion�rio de dados
	//-----------------------------------------
	oStructSBM := FWFormStruct(1,"SBM",/*bAvalCampo*/,/*lViewUsado*/)
	oStructG3K := FWFormStruct(1,"G3K",/*bAvalCampo*/,/*lViewUsado*/)
		
	// CRIA OBJETO DO MODELO DE DADOS
	oModel:= MPFormModel():New('MATA035',,,/*CANCEL*/,/*CANCEL*/)
	                                          
	// ADICIONA AO MODELO ESTRUTURA DE FORMUL�RIO DE EDI��O POR CAMPOS
	oModel:AddFields('SBMMASTER',/*cOwner*/,oStructSBM,/*Criptog()*/,{|oModel|A035ValSeg(oModel:GetModel( 'SBMMASTER' ))},/*bCarga*/)
	
	// ADICIONA AO MODELO ESTRUTURA DE FORMUL�RIO DE EDI��O DE GRID
	oModel:AddGrid( 'G3KDETAIL', 'SBMMASTER', oStructG3K, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosValidacao*/ , /*BLoad*/ )
	
	// Define a inser��o de um item no grid como .F.
	oModel:GetModel( 'G3KDETAIL' ):SetOptional( .T. )
	
	// ALTERA PROPRIEDADE DO CAMPO PARA OBRIGAT�RIO
	oStructSBM:SetProperty( 'BM_CODGRT' ,	MODEL_FIELD_OBRIGAT,.T.)
	oStructSBM:SetProperty( 'BM_CONC' ,	MODEL_FIELD_OBRIGAT,.T.)
	oStructSBM:SetProperty( 'BM_CLASGRU' ,	MODEL_FIELD_OBRIGAT,.T.)
	oStructG3K:SetProperty( 'G3K_CODGRP' ,	MODEL_FIELD_OBRIGAT,.F.)
	
	// FAZ RELACIONAMENTO ENTRE COMPONENTES DO MODEL
	oModel:SetRelation( 'G3KDETAIL', { { 'G3K_FILIAL', 'xFilial( "G3K" )' }, { 'G3K_CODGRP', 'BM_GRUPO' } }, G3K->( IndexKey( 1 ) ) )// G3K_FILIAL+G3K_CODGRP
	
	// ADICIONA A DESCRI��O DO MODELO DE DADO
	oModel:SetDescription(STR0020) // "Forma de Pagamento"
	
	// ADICIONA A DESCRI��O DO COMPONENTE DO MODELO DE DADOS
	oModel:GetModel( 'SBMMASTER' ):SetDescription( STR0020 ) // "Grupo de Produto"
	oModel:GetModel( 'G3KDETAIL' ):SetDescription( STR0021 ) // "Forma de Pagamento"
					
	//oModel:SetPrimaryKey({})
	//oModel:SetPrimaryKey( {'G3F_FILIAL', 'G3F_CODCLI', 'G3F_LOJA', 'G3F_TIPO'} )
	oModel:SetPrimaryKey({"G3K_CODGRP","G3K_CODFOP"})
	
	oModel:GetModel("G3KDETAIL"):SetUniqueLine({"G3K_CODGRP","G3K_CODFOP"})
EndIf
	
Return(oModel)

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Interface do modelo de dados do cadastro de grupo de produtos

@author Leandro F. Dourado
@since 13/09/2011
@version P12
*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView  		:= Nil
Local oModel  		:= FWLoadModel("MATA035")
Local oStructSBM 	:= Nil
Local oStructG3K 	:= Nil
Local aButtons  	:= {}
Local aUsrBut   	:= {} 
Local nX			:= 0

If nModulo <> 89 .AND. !(ValidEAI() .AND. SupergetMV("MV_INTTUR",,.F.))	
	//-----------------------------------------
	//Monta a estrutura do formul�rio com base no dicion�rio de dados
	//-----------------------------------------
	oStructSBM := FWFormStruct(2,"SBM")
	//-----------------------------------------
	//Monta o modelo da interface do formul�rio
	//-----------------------------------------
	oView := FWFormView():New()
	oView:SetContinuousForm()
	oView:SetModel(oModel)   
	oView:EnableControlBar(.T.)      
	oView:AddField( "MATA035_SBM" , oStructSBM )
	oView:CreateHorizontalBox( "HEADER" , 100 )
	oView:SetOwnerView( "MATA035_SBM" , "HEADER" )

	If ExistBlock( "MA035BUT" ) 
		If Valtype( aUsrBut := Execblock( "MA035BUT", .f., .f. ) ) == "A"
			AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
		EndIf 
	EndIf

	//loop para incluir todos os bot�es na View
	For nX := 1 to Len(aButtons)
		oView:AddUserButton(aButtons[nX][3], aButtons[nX][1],aButtons[nX][2]) 
	Next nX 
	Else
		// CRIA OBJETO DE MODELO DE DADOS BASEADO NA MODELDEF
		oStructSBM 	:= FWFormStruct(2,'SBM')
		oStructG3K 	:= FWFormStruct(2,'G3K')
		
		// REMOVE CAMPOS DO FIELD
		oStructSBM:RemoveField("BM_PICPAD")
		oStructSBM:RemoveField("BM_PROORI")
		oStructSBM:RemoveField("BM_CODMAR")
		oStructSBM:RemoveField("BM_DESMAR")
		oStructSBM:RemoveField("BM_STATUS")
		oStructSBM:RemoveField("BM_GRUREL")
		oStructSBM:RemoveField("BM_TIPGRU")
		oStructSBM:RemoveField("BM_DESTGR")
		oStructSBM:RemoveField("BM_MARKUP")
		oStructSBM:RemoveField("BM_PRECO")
		oStructSBM:RemoveField("BM_MARGPRE")
		oStructSBM:RemoveField("BM_LENREL")
		oStructSBM:RemoveField("BM_TIPMOV")
		oStructSBM:RemoveField("BM_FORMUL")
		oStructSBM:RemoveField("BM_DTUMOV")
		oStructSBM:RemoveField("BM_HRUMOV")
		oStructG3K:RemoveField("G3K_CODGRP")
			
		// INCLUI CONSULTA F3 no campo
		oStructG3K:SetProperty( "G3K_CODFOP", MVC_VIEW_LOOKUP,"G3N" )
		
		// CRIA OBJETO DA VIEW
		oView:= FWFormView():New()
		
		// DEFINE QUAL MODELO DE DADOS SER� UTILIZADO
		oView:SetModel(oModel)
		
		// ADICIONA VIEW DE CONTROLE DO TIPO FORMFIELDS
		oView:AddField('VIEW_SBM', oStructSBM,'SBMMASTER')
		
		// ADICIONA VIEW DE CONTROLE DO TIPO FORMGRID
		oView:AddGrid('VIEW_G3K', oStructG3K, 'G3KDETAIL' )
		
		// CRIA BOX HORIZONTAL
		oView:CreateHorizontalBox( 'SUPERIOR', 40 )
		oView:CreateHorizontalBox( 'INFERIOR', 60 )
		
		// RELACIONA O ID DA VIEW COM BOX DE EXIBI��O
		oView:SetOwnerView( 'VIEW_SBM', 'SUPERIOR' )
		oView:SetOwnerView( 'VIEW_G3K', 'INFERIOR' )
	EndIf	

Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A035ValSeg(oSBMMASTER)

VALIDA SE FOI SELECIONADO ALGUM SEGMENTO PARA ESTE GRUPO  DE PRODUTO

@sample 	A035ValSeg()
@return  	aRotina                       
@author  	Fanny Mieko Suzuki
@since   	18/06/2015
@version  	P12
@return 	lRet
/*/
//------------------------------------------------------------------------------------------

Static Function A035ValSeg(oSBMMASTER)

Local nOperation	:= 0
Local lLazer		:= ""
Local lCorpor		:= ""
Local lEvento		:= ""
Local cValid 		:= ""
Local lRet 		:= .T.

// VERIFICAR QUAL O TIPO DE OPERA��O ESTA SENDO REALIZADA
nOperation 	:= oSBMMASTER:GetOperation()

lCorpor 	:= FwFldGet("BM_CORP")
lEvento 	:= FwFldGet("BM_EVENTO")
lLazer 	:= FwFldGet("BM_LAZER")

// VERIFICA SE � INCLUS�O OU ALTERA��O?
If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE 
	// VALIDA SE NENHUM SEGMENTO FOI SELECIONADO PARA ESTA ENTIDADE
	If lCorpor == .F. .AND. lEvento == .F. .AND. lLazer == .F.
		Help( "A035VALSEG", 1, STR0022, , STR0023, 1, 0) // "Aten��o" - "� necess�rio selecionar pelo menos um segmento para este Grupo de Produto."
		lRet:= .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} A035PreVld
Realiza pre validacoes do modelo de dados

@author Leandro F. Dourado
@since 09/04/2012
@version P12
*/
//-------------------------------------------------------------------

Static Function A035PreVld(oModel, auMovStatus) 
Local aArea			:= GetArea()
Local aAreaSB1  		:= SB1->(GetArea())
Local aIntSBM			:= {}
Local nOpc 			:= oModel:GetOperation()

If nOpc == 1
	nOpc := 2
EndIf

auMovStatus := {}

A035Int( 1, nOpc, aIntSBM )
    
RestArea(aAreaSB1)
RestArea(aArea) 

Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} A035PosVld
Realiza pos validacoes do Model

@author Leandro F. Dourado
@since 09/04/2012
@version P11.6
*/
//-------------------------------------------------------------------

Static Function A035PosVld(oModel,auMovStatus)
Local nOpc 			:= oModel:GetOperation()
Local lRet 			:= .T.
Local lIntSFC 		:= ExisteSFC("SBM") .And. !IsInCallStack("AUTO035")// Determina se existe integracao com o SFC
Local lIntDPR 		:= IntegraDPR() .And. !IsInCallStack("AUTO035")// Determina se existe integracao com o DPR
LOCAL luMovme		:= (SuperGetMV("MV_UMOV",,.F.)) // Indica se Existe Integra��o Protheus x uMov.me
Local oMdl
Local cDescricao 	:= ""
Local lMa035Del 	:= ExistBlock( "MA035DEL" )



If	nOpc == 3 .Or. nOpc == 4
	lRet := Ma035Valid(nOpc)
ElseIf nOpc == 5
	lRet := A035Deleta("SBM", SBM->(Recno()), nOpc)
EndIf

If lRet
	A035Int( 2, 2, {} )
	If lMa035Del
		Execblock( "MA035DEL", .F., .F. )
	EndIf
EndIf
//����������������������������������������������������������������Ŀ
//�Chama rotina para integracao com DPR(Desenvolvedor de Produtos) �
//������������������������������������������������������������������
If lRet .And.(lIntDPR .Or. lIntSFC)
	lRet := A035IntDPR(nOpc)	
EndIf

If	luMovme .And. (nOpc == 3 .Or. nOpc == 4)
	oMdl := oModel:GetModel('MATA035_SBM')
	cDescricao := oMdl:GetValue('BM_DESC')
	If cDescricao <> SBM->BM_DESC
		aAdd( auMovStatus, oMdl:GetValue('BM_GRUPO') )
	EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} Mt035Grv
Funcao que realiza a gravacao dos dados

@author Leandro F. Dourado
@since 09/04/2012
@version P11.6
*/
//-------------------------------------------------------------------

Static Function Mt035Grv(oModel,auMovStatus)
Local nOpc 		:= oModel:GetOperation()
Local lRet	
Local cNameBlock  := Iif(nOpc == 3,"MA035INC","MA035ALT")
Local cAlias		:= "SBM"
Local aIntSBM		:= {}
LOCAL lPIMSINT 	:= (SuperGetMV("MV_PIMSINT",.F.,.F.))// Indica se Existe Integra��o Protheus x PIMS Graos
LOCAL luMovme		:= (SuperGetMV("MV_UMOV",,.F.)) // Indica se Existe Integra��o Protheus x uMov.me  
Local cID			:= "MATA035_SBM"
Local nX			:= 1
Local lExistBlk		:= ExistBlock( cNameBlock )

If nOpc == 3 .OR. nOpc == 4
	lRet := FWFormCommit(oModel,,{|oModel,cID,cAlias|A035Int( 2, nOpc, aIntSBM )})
ElseIf nOpc == 5
	lRet := FWFormCommit(oModel)
EndIf

If lRet
	If nOpc == 3 .OR. nOpc == 4
		If lExistBlk
			Execblock( cNameBlock, .F., .F.)
		EndIf

		//������������������������������Ŀ
		//� Integracao PIMS GRAOS        �
		//��������������������������������
		If lPIMSINT
			PIMSGeraXML("MaterialFamily",STR0010,"2","SBM")
		EndIf
	
		If luMovme .And. Len( auMovStatus ) > 0
			For nX := 1 to Len( auMovStatus )
				If SBM->(MsSeek( xFilial("SBM") + auMovStatus[nX]))
					RecLock( "SBM", .F.)	
					SBM->BM_DTUMOV := CTOD("")
					SBM->BM_HRUMOV := ""
					SBM->(MsUnlock())
				EndIf
			Next 
		EndIf
		 
	EndIf
EndIf

Return lRet     

//-------------------------------------------------------------------
/*{Protheus.doc} A035IntDPR
Atualiza tabelas do DPR conforme modelagem dos dados(MVC)

@author Leonardo Quintania
@since 13/11/2012
@version 11.80
*/
//-------------------------------------------------------------------
Function A035IntDPR(nOpc,cError,cNome,oModel)
	Local aArea   := GetArea()	// Salva area atual para posterior restauracao
	Local lRet    := .T.		// Conteudo de retorno
	Local aCampos := {}			// Array dos campos a serem atualizados pelo modelo
	Local aAux    := {}			// Array auxiliar com o conteudo dos campos
	Local nX	  	:= 0			// Indexadora de laco For/Next
	Local oModelAnt := FwModelActive() //Modelo ativo atual

	Default oModel := FWLoadModel("SFCA021")

	If nOpc == 3
		aAdd(aCampos,{"CY7_CDGE",M->BM_GRUPO})
	EndIf

	If nOpc # 5
		aAdd(aCampos,{"CY7_DSGE",M->BM_DESC})
	EndIf

	//�����������������������������������������������������������Ŀ
	//�Instancia modelo de dados(Model) do Grupo de Estoque - DPR �
	//�������������������������������������������������������������
	//oModel := FWLoadModel("SFCA021")
	oModel:SetOperation(nOpc)

	If nOpc # 3
		//������������������������������������������������������������������������������������������Ŀ
		//�Quando se tratar de alteracao ou exclusao primeiramente o registro devera ser posicionado �
		//��������������������������������������������������������������������������������������������
		CY7->(dbSetOrder(1))
		CY7->(dbSeek(xFilial("CY7")+SBM->BM_GRUPO))
	EndIf
			
	//������������������������Ŀ
	//�Ativa o modelo de dados �
	//��������������������������
	If (lRet := oModel:Activate())
		//������������������������������������Ŀ
		//�Obtem a estrutura de dados do Model �
		//��������������������������������������
		aAux := oModel:GetModel("CY7MASTER"):GetStruct():GetFields()
		
		//��������������������������������������������������������������Ŀ
		//�Loop para validacao e atribuicao de dados dos campos do Model �
		//����������������������������������������������������������������
		For nX := 1 To Len(aCampos)
			//��������������������������������������������������Ŀ
			//�Valida os campos existentes na estrutura do Model �
			//����������������������������������������������������
			If aScan(aAux,{|x| AllTrim(x[3]) ==  AllTrim(aCampos[nX,1])}) > 0
				//��������������������������������������������������������������������������������Ŀ
				//�Atribui os valores aos campos do Model caso passem pela validacao do formulario �
				//�referente a tipos de dados, tamanho ou outras incompatibilidades estruturais.   �
				//����������������������������������������������������������������������������������
				If !(oModel:SetValue("CY7MASTER",aCampos[nX,1],aCampos[nX,2]))
					lRet := .F.
					Exit       
				EndIf
			EndIf
		Next nX
	Endif

	If lRet
		//�����������������������������������������������������������Ŀ
		//�Valida os dados e integridade conforme dicionario do Model �
		//�������������������������������������������������������������
		If (lRet := oModel:VldData())
			//�������������������������������������Ŀ
			//�Efetiva gravacao dos dados na tabela �
			//���������������������������������������
			lRet := oModel:CommitData()
		EndIf
	EndIf

	//�������������������������������������������������������Ŀ
	//�Gera log de erro caso nao tenha passado pela validacao �
	//���������������������������������������������������������
	If !lRet
		A010SFCErr(oModel,@cError,NIL,cNome,SBM->BM_GRUPO)
	EndIf

	//�����������������Ŀ
	//�Desativa o Model �
	//�������������������
	oModel:DeActivate()

	If ValType( oModelAnt ) == "O"
        FwModelActive( oModelAnt )
    EndIf
	RestArea(aArea)
Return lRet
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
��� Function  � IntegDef � Autor � Alex Egydio          � Data �  03/01/13   ���
����������������������������������������������������������������������������͹��
��� Descricao � Funcao de tratamento para o recebimento/envio de mensagem    ���
���           � unica do Grupo de Produtos.                                  ���
����������������������������������������������������������������������������͹��
��� Uso       � MATA035                                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Local aRet 		:= {}
Local cRotina	:= Padr( 'MATA035'	 , nTamRot )
Local cFamily	:= Padr( 'FAMILY' 	 , nTamMod )
Local cStockGrp	:= Padr( 'STOCKGROUP', nTamMod )

Default xEnt 		:= ""
Default nTypeTrans 	:= ""
Default cTypeMessage:= ""
Default cVersion 	:= ""
Default cTransac 	:= ""
Default lEAIObj 	:= .F.

// Armazena busca na variavel Static para nao posicionar XX4 a cada chamada da IntegDef
// caso contrario se tiver mais de um cadastro de adapter para a mesma rotina o programa fica em looping
If cXX4Model == Nil
	If FWXX4Seek( cRotina + cFamily )
		cXX4Model := "FAMILY"
	ElseIf FwXX4Seek( cRotina + cStockGrp )
		cXX4Model := "STOCKGROUP"
	Else
		cXX4Model := " "
	EndIf
EndIf

// Ao cadastrar um dos tr�s adapters a rotina CFGA020 precisar� requisitar o
// WhoIs para saber quais as vers�es dispon�veis. Como no cadastro nenhum
// dos tr�s adapters estar� na tabela XX4 as vers�es dispon�veis ter�o que
// ser cadastradas aqui dentro. Ao criar uma nova vers�o dos adapters o array
// de vers�es ter� que ser atualizado aqui tamb�m.

Do Case
	Case "FAMILY" $ cXX4Model
		aRet := MATI035(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
	Case "STOCKGROUP" $ cXX4Model
		aRet := MATI035A(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
	Case cTypeMessage == EAI_MESSAGE_WHOIS
		//WhoIs
		//MATI035  v1.000, 2.000, 2.001, 2.002
		//MATI035a v1.000
		aRet := {.T., '1.000|2.000|2.001|2.002'}
EndCase

Return aRet

//Validar se est� em modo sincronismo de carga inicial do EAI e se a vers�o da mensagem � = a 3 (mensagem especifica para o modulo turismo)
//Validar na proxima realease se a fun��o FWEAIInSinc existir, remover o IsInCallStack
Static Function ValidEAI() 
Return If(FindFunction('FWEAIInSinc'),FWEAIInSinc(),IsInCallSt("IpcCfg020A"))
