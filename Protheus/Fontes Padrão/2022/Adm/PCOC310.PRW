#INCLUDE "PCOC310.ch"
#include "protheus.ch"
/*/
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOC310  � AUTOR � Edson Maricate        � DATA � 26.11.2003 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa de Consulta ao arquivo de saldos mensais dos Cubos  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOC310                                                      潮�
北砡DESCRI_  � Programa de Consulta ao arquivo de saldos mensair dos Cubos  潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo: PCOC310(2) - Executa a chamada da funcao de visua-  潮�
北�          �                       zacao da rotina.                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOC310(nCallOpcx)

Local bBlock
Local nPos
Private cCadastro	:= STR0001 //"Consulta Saldos Mensais de Cubos"
Private aRotina := MenuDef()
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no Browse                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOC3101" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Centros Orcamentarios                                �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOC3101                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOC3101", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf

	PCOC310INF()
	If nCallOpcx <> Nil
		nPos := Ascan(aRotina,{|x| x[4]== nCallOpcx})
		If ( nPos # 0 )
			bBlock := &( "{ |x,y,z,k| " + aRotina[ nPos,2 ] + "(x,y,z,k) }" )
			Eval( bBlock,Alias(),AL4->(Recno()),nPos)
		EndIf
	Else
		mBrowse(6,1,22,75,"AKS")
	EndIf
EndIf

Return



Function PCOC310ViewChv()

Local aArea := GetArea()
Local aAreaAKW := AKW->(GetArea())
Local cCubo   := M->AKS_CONFIG
Local cSaldo := ""
Local nIni:= 1, nFim := 1
Local aQebra := {}, cAux
Local cTitle

dbSelectArea("AKW")
dbSetOrder(1)
dbSeek(xFilial()+cCubo)

While !Eof() .And. xFilial()+cCubo == AKW->AKW_FILIAL+AKW->AKW_COD

	cTitle := AllTrim(AKW->AKW_DESCRI)
	cAux := &(AllTrim(AKW->AKW_CHAVER))
	nFim := Len(cAux)
	cAux := Subs(M->AKS_CHAVE, nIni, nFim)
	cSaldo += cTitle+Space(20-Len(cTitle)*2)+chr(9)+ " :   "+cAux+C310Descri(cAux)+CRLF
	nIni += nFim
	dbSkip()

End

RestArea(aAreaAKW)
RestArea(aArea)

Return(cSaldo)



Static Function C310Descri(cAux)

Local aArea := GetArea(cAux)
Local cDescri := ""

dbSelectArea(AKW_ALIAS)
dbSetOrder(1)

If dbSeek(xFilial()+cAux) .And. ;
	AllTrim(AKW->AKW_DESCRE)!=AllTrim(AKW->AKW_RELAC)
	cDescri := " - "+&(AllTrim(AKW->AKW_DESCRE))
EndIf	

RestArea(aArea)

Return(cDescri)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � MenuDef  篈utor  � Pedro Pereira Lima � Data �  09/29/11   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,	"PCOC310INF" , 0 , 1},; //"Pesquisar"
							{ STR0003, 	"PCOC310INF" , 0 , 2} }  //"Visualizar"
							
Return aRotina
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � MenuDef  篈utor  � Pedro Pereira Lima � Data �  09/29/11   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOC310INF()
	
	Help(" ",1,"PCOC310INF",,STR0004,1,0)  //"A tabela de Saldos Mensais (AKS) est� descontinuada, e atualmente os saldos s鉶 controlados apenas pela tabela de Saldo Diario (AKT)." 

Return 
