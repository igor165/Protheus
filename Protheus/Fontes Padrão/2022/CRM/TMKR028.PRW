#INCLUDE "TMKR028.CH"
#INCLUDE "PROTHEUS.CH"   
#INCLUDE "REPORT.CH"

/*
	DESCRICAO DOS ARRAYS

	aTreeScript
	1- Codigo do No Pai
	2- Codigo da Pergunta
	3- Descricao da Pergunta
	4- Memo da Pergunta
	5- Array com as respostas
	
	aResposta
	1- Codigo da Resposta
	2- Descricao das Respostas
	3- Pontuacao das Respostas
	4- Memo das Respostas
*/


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR028  � Autor � Rafael M. Quadrotti   � Data � 30/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de SCRIPTS - Gerencia de Campanhas               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Call Center - Relatorios 			                      ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Michel W. �08/08/06�99198 �Atualizacao para relatorio release 4.       ��� 
���Michel W. �11/10/06�110638�Adicionado titulos na secoes do relatorio.  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function TMKR028()
Local oReport	//Objeto relatorio TReport (Release 4)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TMK028",.F.)
//�������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                 			  �
//� mv_par01            // Do Script                                  �
//� mv_par02            // Ate Script                                 �
//� mv_par03            // Formato.                                   �
//���������������������������������������������������������������������
	
//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := ReportDef()
oReport:PrintDialog() 

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef    � Autor �Michel W. Mosca     � Data �08/08/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina que define os itens que serao apresentados no relato-���
���          �rio de Scripts Dinamicos no release 4.                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CALL CENTER                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/              
Static Function ReportDef()
Local oReport 				//Objeto relatorio TReport (Release 4)
Local oSection1             //Objeto secao 1 do relatorio (Cabecalho, campos das tabelas SUA e SA3)
Local oSection2
Local oSection3
Local cSUZ := "SUZ"     //Alias da consulta Embedded SQL
Local cSUP := "SUP"     //Alias da consulta Embedded SQL
cSUZ	:= GetNextAlias()						// Pega o proximo Alias Disponivel	

// "Ranking de Vendas" # // "Este programa ira emitir uma listagem contendo os vendedores e os totais" #
// "das vendas realizadas por eles e tambem podendo ser analisado por operador" #
// "A emissao ocorrera baseada nos parametros do relatorio"
DEFINE REPORT oReport NAME "TMKR028" TITLE STR0001 PARAMETER "TMK028" ACTION {|oReport| Tkr028PrtRpt( oReport, cSUZ, cSUP )} DESCRIPTION STR0002

//�����������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal �
//�������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0023 TABLES "SUZ"  	//Cabe�alho do Script Dinamico
DEFINE SECTION oSection2 OF oSection1 TITLE STR0024 TABLES "SUP"    //Descri��o de Perguntas
DEFINE SECTION oSection3 OF oSection2 TITLE STR0025 TABLES "SUP"    //Descri��o de Respostas

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������            
//�������������������������������������������������Ŀ
//�Imprime os dados do cabecalho do script dinamico.�
//���������������������������������������������������
DEFINE CELL NAME "UZ_CODSCRI" OF oSection1 ALIAS "SUZ"	//"Script       : "
DEFINE CELL NAME "UZ_DESC" OF oSection1 ALIAS "SUZ" 	//"T�tulo       : "	
DEFINE CELL NAME "UZ_TEMPO" OF oSection1 ALIAS "SUZ" 	//"Tempo        : "
	
//������������������������������������Ŀ
//�Verifica qual o tipo de atendimento.�
//��������������������������������������
DEFINE CELL NAME "" OF oSection1 BLOCK{||IIF((cSUZ)->UZ_TIPO == "1",STR0008,IIF((cSUZ)->UZ_TIPO == "2",STR0009,STR0010))} TITLE "Tipo" SIZE 12	

//����������������������������������Ŀ
//�Verifica qual o formato do script.�
//������������������������������������
DEFINE CELL NAME "" OF oSection1 BLOCK{||IIF((cSUZ)->UZ_FORMATO == "1",STR0012,STR0013)} TITLE STR0020 SIZE 15	
DEFINE CELL NAME "UZ_SCORMIN" OF oSection1 ALIAS "SUZ"		//"Score m�nimo: "
DEFINE CELL NAME "UZ_SCORMAX" OF oSection1 ALIAS "SUZ" 		//"Score Minimo: " 	
DEFINE CELL NAME "" OF oSection1 BLOCK{||(cSUZ)->UZ_PROCMIN + " - " + ;
						Posicione("SX5",1,xFilial("SX5") + "E3" + (cSUZ)->UZ_PROCMIN,"X5DESCRI()")} TITLE STR0021 SIZE 50	//"A��o M�nima: " 
DEFINE CELL NAME "" OF oSection1 BLOCK{||(cSUZ)->UZ_PROCMAX + " - " + ;
						Posicione("SX5",1,xFilial("SX5") + "E3" + (cSUZ)->UZ_PROCMAX,"X5DESCRI()")} TITLE STR0022 SIZE 50	//"A��o M�xima: " 

//FORMATO PESQUISA e FORMATO ATENDIMENTO
DEFINE CELL NAME "UP_DESC" OF oSection2 ALIAS "SUP"

DEFINE CELL NAME "UP_DESC" OF oSection3 ALIAS "SUP" SIZE 80
DEFINE CELL NAME "UP_SCORE" OF oSection3 ALIAS "SUP"
DEFINE CELL NAME "UP_CODOBS" OF oSection3 ALIAS "SUP"




Return(oReport)                    


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tkr028PrtRpt � Autor �Michel W. Mosca     � Data �08/08/2006���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio de           ���
���          �Scripts dinamicos no release 4.                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tkr028PrtRept(ExpO1,ExpC2,ExpC3)                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = objeto relatorio                                   ���
���          � ExpC2 = alias da query atual                               ���
���          � ExpC3 = alias da query atual                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tkr028PrtRpt(oReport, cSUZ, cSUP)
Local oSection1 := oReport:Section(1)		//Objeto secao 1 do relatorio (Cabecalho, campos das tabelas SUA e SB1)
Local oSection2 := oSection1:Section(1)		// Secao de perguntas
Local oSection3 := oSection2:Section(1)    // Secao de respostas

//���������������������������������������������������������������������������������Ŀ
//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
//�����������������������������������������������������������������������������������
MakeSqlExpr("TMKR028")      

BEGIN REPORT QUERY oSection1
BeginSQL alias cSUZ
	SELECT	UZ_CODSCRI,		UZ_DESC,	UZ_TEMPO,		UZ_SCORMIN,
			UZ_SCORMAX,		UZ_TIPO,	UZ_FORMATO,		UZ_PROCMIN,
			UZ_PROCMIN,		UZ_PROCMAX,	UZ_FILIAL		
	FROM 	%table:SUZ% SUZ
	WHERE	UZ_FILIAL = %xFilial:SUZ% AND
			UZ_CODSCRI BETWEEN %exp:mv_par01% AND %exp:mv_par02%	AND 
			%exp:STR(mv_par03,1)% IN('3',UZ_FORMATO) 			AND 
			SUZ.%notDel%
	ORDER BY %order:SUZ%    
EndSql    
END REPORT QUERY oSection1                      

While	!Eof()									.AND.;
		(cSUZ)->UZ_FILIAL == xFilial("SUZ")		.AND.;
		(cSUZ)->UZ_CODSCRI    >= mv_par01		.AND.;
		(cSUZ)->UZ_CODSCRI    <= mv_par02
				
	oReport:IncMeter()	
	
	If oReport:Cancel()
		Exit
	EndIf	

	//������������������Ŀ
	//�Validacoes em CDX.�
	//��������������������
	#IFNDEF TOP		
		If !Empty(mv_par03) .AND. (mv_par03 <> 3) .AND. Val((cSUZ)->UZ_FORMATO) <> mv_par03 
			DbSkip()
			Loop
		EndIf		
	#ENDIF     

	oSection1:Init()	
	oSection1:SetLineStyle()
	oSection1:PrintLine()
	oSection1:Finish() 
	
	If ((cSUZ)->UZ_FORMATO == "1") //Atendimento
  		PrtAtendimento(cSUZ, cSUP, oSection2, oSection3, oReport)
    Else   //Pesquisa
    	PrtPesquisa(cSUZ, cSUP, oSection2, oSection3, oReport)
    EndIf	
	                   
	oReport:ThinLine()
	oReport:EndPage()
	
	
	
	
	DbSelectArea(cSUZ)
	DbSkip()
End

Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrtPesquisa  � Autor �Michel W. Mosca     � Data �09/08/2006���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio de           ���
���          �Scripts dinamicos no release 4. Formato Pesquisa.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrtPesquisa  (ExpC1,ExpC2,ExpO3,ExpO4,ExpO5)               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = alias da query atual                               ���
���          � ExpC2 = alias da query atual                               ���
���          � ExpO3 = objeto secao                                       ���
���          � ExpO4 = objeto secao                                       ���
���          � ExpO5 = objeto relatorio                                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrtPesquisa(cSUZ, cSUP, oSection2, oSection3, oReport)
Local lFirst	:= .T.
Local cScript	:= ""
Local cTree   	:= ""

//�����������������������������������������������������������������Ŀ
//�Posiciona SUP(Perguntas e respostas do Script) e avalia o Formato�
//�������������������������������������������������������������������
DbSelectArea("SUP")
DbSetOrder(2)
MsSeek(xFilial("SUP") + (cSUZ)->UZ_CODSCRI,.T.)
cScript := SUP->UP_CODCAMP
cTree   := SUP->UP_IDTREE

//����������������������������������������������������������������������Ŀ
//�Imprime as perguntas/respostas do script dinamico no formato PESQUISA.�
//������������������������������������������������������������������������

oSection2:Init()
While ( !Eof()) .And. (SUP->UP_CODCAMP == cScript)	
	If !EMPTY(SUP->UP_TIPOOBJ) // Define se e Pergunta ou Resposta    
		If !lFirst 
			oSection3:Finish()
			oReport:SkipLine()
		EndIf   
		lFirst	:= .F.
		oSection2:PrintLine()
		oSection3:Init()     
		oSection3:SetLeftMargin(10)          		
	Else
		oSection3:PrintLine()		
	EndIf

	DbSelectArea("SUP")	
	DbSkip()
End
If !lFirst 
	oSection3:Finish()
	oReport:SkipLine()
EndIf                 
oSection2:Finish()

Return(.T.)                


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrtAtendimento Autor �Michel W. Mosca     � Data �09/08/2006���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio de           ���
���          �Scripts dinamicos no release 4. Formato Atendimento.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrtAtendimento(ExpC1,ExpC2,ExpO3,ExpO4,ExpO5)              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = alias da query atual                               ���
���          � ExpC2 = alias da query atual                               ���
���          � ExpO3 = objeto secao                                       ���
���          � ExpO4 = objeto secao                                       ���
���          � ExpO5 = objeto relatorio                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function PrtAtendimento(cSUZ, cSUP, oSection2, oSection3, oReport)
Local nLevel	:=	0
Local aArea:= GetArea()                                                   


//�����������������������������������������������������������������Ŀ
//�Posiciona SUP(Perguntas e respostas do Script) e avalia o Formato�
//�������������������������������������������������������������������
DbSelectArea("SUP")
DbSetOrder(2)
MsSeek(xFilial("SUP") + (cSUZ)->UZ_CODSCRI,.T.)

//����������������������������������������������������������������������Ŀ
//�Imprime as perguntas/respostas do script dinamico no formato PESQUISA.�
//������������������������������������������������������������������������

oSection2:Init()
oSection3:Init()     
oSection3:Cell("UP_SCORE"):Disable()
oSection3:Cell("UP_CODOBS"):Disable()

While !Eof() .AND. (xFilial("SUP") == SUP->UP_FILIAL) .AND. ((cSUZ)->UZ_CODSCRI == SUP->UP_CODCAMP)
	If !EMPTY(SUP->UP_TIPOOBJ) .AND. SUP->UP_IDTREE == "0000000" // Define se e Pergunta ou Resposta    
		oSection2:PrintLine()
		//Imprime Respostas
		PrtAtdR(cSUZ, cSUP, oSection2, oSection3, oReport, SUP->UP_CARGO, nLevel+1)		
		oSection2:SetLeftMargin(0)
		oSection3:SetLeftMargin(0)		
	EndIf

	DbSelectArea("SUP")	
	DbSkip()
End

oSection3:Cell("UP_SCORE"):Enable()
oSection3:Cell("UP_CODOBS"):Enable()
oSection3:Finish()
oSection2:Finish()     

//������������������������������
//�Restaura o ambiente inicial.�
//������������������������������
RestArea(aArea)

Return(.T.)                



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrtAtdR      � Autor �Michel W. Mosca     � Data �09/08/2006���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio de           ���
���          �Scripts dinamicos no release 4. Imprime as repostas.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrtAtdR(ExpC1,ExpC2,ExpO3,ExpO4,ExpO5)                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = alias da query atual                               ���
���          � ExpC2 = alias da query atual                               ���
���          � ExpO3 = objeto secao                                       ���
���          � ExpO4 = objeto secao                                       ���
���          � ExpO5 = objeto relatorio                                   ���
���          � ExpC6 = Cod. do Cargo do item pai                          ���
���          � ExpN7 = Numero do nivel da arvore que o registro se encon- ���
���          �         -tra. Utilizado para imprimir no formato de arvore.���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function PrtAtdR(cSUZ, cSUP, oSection2, oSection3, oReport, cCargoPai, nLevel)
Local aArea:= GetArea()
Local nLevelAux := nLevel*4

DbSelectArea("SUP")
DbSetOrder(1)
lRet := MsSeek(xFilial("SUP") + (cSUZ)->UZ_CODSCRI + cCargoPai)

While !Eof() .AND. (xFilial("SUP") == SUP->UP_FILIAL) .AND. ((cSUZ)->UZ_CODSCRI == SUP->UP_CODCAMP)

	If(cCargoPai <> SUP->UP_IDTREE .AND. !Empty(cCargoPai)) 			
		DbSelectArea("SUP")	
		DbSkip()		           
		Loop
	EndIf  

	If EMPTY(SUP->UP_TIPOOBJ) // Define se e Pergunta ou Resposta    		          		
		oSection3:SetLeftMargin(nLevelAux)	
		oSection3:PrintLine()		
		//Verifica se h� perguntas abaixo da resposta
		PrtAtdP(cSUZ, cSUP, oSection2, oSection3, oReport, SUP->UP_CARGO, nLevel+1)
	EndIf

	DbSelectArea("SUP")	
	DbSkip()
End

//������������������������������
//�Restaura o ambiente inicial.�
//������������������������������
RestArea(aArea)

Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrtAtdP      � Autor �Michel W. Mosca     � Data �09/08/2006���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio de           ���
���          �Scripts dinamicos no release 4. Imprime as perguntas.       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrtAtdP(ExpC1,ExpC2,ExpO3,ExpO4,ExpO5)                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = alias da query atual                               ���
���          � ExpC2 = alias da query atual                               ���
���          � ExpO3 = objeto secao                                       ���
���          � ExpO4 = objeto secao                                       ���
���          � ExpO5 = objeto relatorio                                   ���
���          � ExpC6 = Cod. do Cargo do item pai                          ���
���          � ExpN7 = Numero do nivel da arvore que o registro se encon- ���
���          �         -tra. Utilizado para imprimir no formato de arvore.���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function PrtAtdP(cSUZ, cSUP, oSection2, oSection3, oReport, cCargoPai, nLevel)
Local aArea:= GetArea()                                                   
Local nLevelAux	:= nLevel*4
Default cCargoPai	:= ""



//�����������������������������������������������������������������Ŀ
//�Posiciona SUP(Perguntas e respostas do Script) e avalia o Formato�
//�������������������������������������������������������������������
DbSelectArea("SUP")
DbSetOrder(1)
lRet := MsSeek(xFilial("SUP") + (cSUZ)->UZ_CODSCRI + cCargoPai)

//����������������������������������������������������������������������Ŀ
//�Imprime as perguntas/respostas do script dinamico no formato PESQUISA.�
//������������������������������������������������������������������������

While !Eof() .AND. (xFilial("SUP") == SUP->UP_FILIAL) .AND. ((cSUZ)->UZ_CODSCRI == SUP->UP_CODCAMP)
	If(cCargoPai <> SUP->UP_IDTREE .AND. !Empty(cCargoPai)) 			
		DbSelectArea("SUP")	
		DbSkip()		           
		Loop
	EndIf  

	If !EMPTY(SUP->UP_TIPOOBJ) // Define se e Pergunta ou Resposta    
		oSection2:SetLeftMargin(nLevelAux)
		oSection2:PrintLine()		
		//Imprime Respostas
		PrtAtdR(cSUZ, cSUP, oSection2, oSection3, oReport, SUP->UP_CARGO, nLevel+1)         		
	EndIf

	DbSelectArea("SUP")	
	DbSkip()
End

//������������������������������
//�Restaura o ambiente inicial.�
//������������������������������
RestArea(aArea)

Return(.T.)                