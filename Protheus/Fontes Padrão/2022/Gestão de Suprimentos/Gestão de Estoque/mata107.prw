#INCLUDE "MATA107.CH" 
#INCLUDE "PROTHEUS.CH"
Static l107Grv := NIL
Static l107Fil := NIL
Static l107Qry := NIL
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Mata107  � Autor � Ernani Forastieri     � Data �18.03.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Libera��o de Solicita��o ao Armazem                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void MatA107(void)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Mata107()
Local cCondicao   := "CP_STATSA == 'B' .And. !SCR->(dbSeek(xFilial('SCR')+'SA'+PadR(SCP->CP_NUM,Len(SCR->CR_NUM))))"
Local cRet        := ''
Local cFilQuery   := ""
Local cFilPE      := ""
Local cSubQry     := "SUBSTR"
Local cLenQry     := "LENGTH"	      
Private cCadastro := STR0001 //"Libera��o de Solicita��o ao Armazem"
Private cDelFunc  := ".T."
Private aRotina   := MenuDef() 

l107Grv := IIf(l107Grv == NIL, ExistBlock("MT107GRV"), l107Grv)
l107Fil := IIf(l107Fil == NIL, ExistBlock("MT107FIL"), l107Fil)
l107Qry := IIf(l107Qry == NIL, ExistBlock("MT107QRY"), l107Qry)

Pergunte("MTA107",.T.)

Set Key VK_F12 To MTA107PERG()

If l107Fil
	cRet := AllTrim(ExecBlock("MT107FIL",.F.,.F.,{cCondicao}))
	If Valtype(cRet) == "C" .And. !Empty(cRet)
		cCondicao := cRet         
	EndIf
	SCR->(dbSetOrder(1))
EndIf

cFilQuery := "@CP_STATSA = 'B' AND "
cFilQuery += "(SELECT COUNT(*) FROM " +RetSQLName("SCR") + " WHERE D_E_L_E_T_ = ' ' AND "
cFilQuery += "CR_FILIAL = '" +xFilial("SCR") +"' AND CR_TIPO = 'SA' AND "

If Upper(TcGetDb()) == "MSSQL"
	cSubQry := "SUBSTRING"
	cLenQry := "LEN"
Endif

cFilQuery += cSubQry + "(CR_NUM,1," + cLenQry + "(CP_NUM)) = CP_NUM) = 0"

dbSelectArea("SCP")
dbSetOrder(1)                                             
If l107Qry
	//P.E. Utilizacao: Filtro da Mbrowse para ambiente Top
   	//Executado somente se nao utilizar MT107FIL
	cFilPE := AllTrim(ExecBlock("MT107QRY",.F.,.F.))  
	If Valtype(cFilPE) == "C" .And. !Empty(cFilPE)
		cFilQuery += " AND " +cFilPE
    EndIf
EndIf
                              
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SCP' )
oBrowse:SetDescription( cCadastro ) 
oBrowse:AddLegend( "!Empty(CP_PREREQU) .And. CP_STATSA $ ' L'"	, "DISABLE" ,STR0009)	//"Pre-requisi��o gerada"
oBrowse:AddLegend( "Empty(CP_PREREQU) .And. CP_STATSA $ ' L'"	, "ENABLE" 	,STR0010)	//"Liberada"
oBrowse:AddLegend( "CP_STATSA == 'B'"							, "BR_PRETO",STR0011)	//"Aprova��o pendente"
oBrowse:AddLegend( "CP_STATSA == 'R'"							, "BR_CANCEL",STR0014)	//"Rejeitada"

If l107Fil .And. !Empty(cCondicao)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetFilterDefault(cCondicao)
ElseIf l107Qry .And. !Empty(cFilQuery)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetFilterDefault(cFilQuery)
Else 
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetFilterDefault(cCondicao)	
Endif

SCR->(dbSetOrder(1))
DbSeek(xFilial("SCP"))                                                                     
oBrowse:Activate()

Set Key VK_F12 To

Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A107Lib   � Autor � Ernani Forastieri     � Data �18.03.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a liberacao da pre-requisicao                          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void A107Lib(ExpCP,ExpN1,ExpN2)                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN2 = Numero do registro                                 ���
���          � ExpN3 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatA107                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A107Lib(cAlias, nRecNo, nOpc)
Local aArea    := GetArea()
Local aAreaSCW := SCW->(GetArea())
Local aAreaSCP := SCP->(GetArea())
Local aInfoSAI := {}
Local lRet	   := .T.                   
Local bWhen	   := NIL
Local cChave   := ""  

/*���������������������������������������������������������Ŀ
  � mv_par01 Liberacao de SA 1- Por Item,2- Por Solicitacao �
  ����������������������������������������������������������� */
If mv_par01 == 1
	cChave := SCP->(CP_FILIAL+CP_NUM+CP_ITEM)
	bWhen  := {|| !SCP->(EOF()) .And. SCP->(CP_FILIAL+CP_NUM+CP_ITEM) == cChave}
Else
	cChave := SCP->(CP_FILIAL+CP_NUM)
	SCP->(dbSetOrder(1))
	SCP->(dbSeek(cChave))
	bWhen  := {|| !SCP->(EOF()) .And. SCP->(CP_FILIAL+CP_NUM) == cChave}
EndIf               
          
If ApMsgNoYes(STR0004,STR0003) //"Confirma Libera��o"###"ATEN��O"
	While Eval(bWhen)
		//�����������������������������������������������������������������������������Ŀ
		//� Ponto de entrada MT107LIB utilizado para validacao do usuario na Liberacao  �
		//�������������������������������������������������������������������������������
		If Existblock("MT107LIB")
			lRet:= Execblock("MT107LIB",.F.,.F.)
			If ValType(lRet) # "L"
				lRet :=.T.
			EndIf
		EndIf
	
		If lRet
			Begin Transaction
				dbSelectArea("SCP")
				RecLock("SCP",.F.)
				SCP->CP_STATSA := "L"
				MsUnlock()
				MaVldSolic(SCP->CP_PRODUTO,UsrRetGrp(),RetCodUsr(),.F.,0,,@aInfoSAI)
				If !Empty(aInfoSAI)
					AtuSalSCW(aInfoSAI[1], aInfoSAI[2], aInfoSAI[3], aInfoSAI[4], aInfoSAI[6])
				EndIf     
	
				If l107Grv
					ExecBlock("MT107GRV",.f.,.f.)
				EndIf  
				
			End Transaction
		EndIf
		SCP->(dbSkip())
	End
	
EndIf
RestArea(aAreaSCP)
RestArea(aAreaSCW)
RestArea(aArea)   
Return 


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
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
PRIVATE aRotina	:= {}
aadd( aRotina, {STR0005, "AxPesqui", 0, 1, 0, .F.} )  
aadd( aRotina, {STR0006, "AxVisual", 0, 2, 0, NIL} )  
aadd( aRotina, {STR0008, "A107Legenda", 0, 2, 0, NIL} )  
aadd( aRotina, {STR0013, "CallMATR107", 0, 5, 0, NIL} )    
aadd( aRotina, {STR0007, "A107Lib" , 0, 4, 0, nil} ) 	

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("MTA107MNU")
	ExecBlock("MTA107MNU",.F.,.F.)
EndIf
Return(aRotina)


/*/{Protheus.doc} CallMATR107
Usada para chamar a impress�o do termo de retirada e restaurar a pergunta 
@author vitor.pires
@since 15/04/2016
@version 1.0
@return ${Nil}, ${nenhum}
/*/Function CallMATR107() 
MATR107()
Pergunte("MTA107",.F.)
Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MTA107PERG� Autor � Rodrigo de T. Silva   � Data � 23/02/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada da funcao PERGUNTE                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA107                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTA107PERG()

Pergunte("MTA107",.T.)

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A107Legenda� Autor � Leonardo Quintania  � Data � 26.01.15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA107                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A107Legenda()
Local aItLeg    := {}

aAdd(aItLeg, {"DISABLE" ,STR0009}) //"Pre-requisi��o gerada"
aAdd(aItLeg, {"ENABLE"  ,STR0010}) //"Liberada"
aAdd(aItLeg, {"BR_PRETO",STR0011}) //"Aprova��o pendente"
aAdd(aItLeg, {"BR_CANCEL",STR0014}) //"Rejeitada"

BrwLegenda(cCadastro,STR0012, aItLeg) //"Solicita��o Armaz�m"   

Return .T.
