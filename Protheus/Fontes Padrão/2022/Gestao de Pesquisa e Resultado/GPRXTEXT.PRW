#INCLUDE "PROTHEUS.CH"        	
#INCLUDE "APWIZARD.ch"
#INCLUDE "GPRXTEXT.ch"

#DEFINE CTRL Chr(13)+Chr(10)
#DEFINE HTMO ' <B><font color="#FF0000"><I> '
#DEFINE HTMC ' </B></font></I> '
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GprAnalyser�Autor  � Henry Fila           � Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Wizard de analise das respostas dissertativas              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GprAnalyser( cPesquisa )                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Codigo da Pesquisa                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION GprTextAnalyser( cPesquisa )

Local aCab     := {OemtoAnsi(STR0001),OemtoAnsi(STR0002),OemtoAnsi(STR0003),OemtoAnsi(STR0004)}
Local aCabDis  := {" ",OemtoAnsi(STR0001),OemtoAnsi(STR0002),OemtoAnsi(STR0005)}
Local aTam     := {5,5,20,30,30,30}                              
Local aLin     := {{Space(6),Space(30),Space(6),StrZero(0,3),""}}
Local aDissert := {{Space(6),Space(30),Space(15)}}
Local aQuestoes:= {}

Local cTexto   := ""           
Local cMsg     := ""
Local cBusca        := Space(100)

Local lAvanco       := .F.

Local nOcorrencias  := 0          

Local oSay1
Local oSay2
Local oSay3
Local oWizard
Local oLbx
Local oLbx2
Local oOk     := LoadBitMap(GetResources(), "LBTIK")       	// Bitmap utilizado no Lisbox  (Marcado)
Local oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Local aLine  := {}

//���������������������������������������������������������������������Ŀ
//� Traz as questoes dissertativas da pesquisa                          �
//�����������������������������������������������������������������������
aQuestoes := GprPesqQuestao( cPesquisa, 3, 1)
If Empty(aQuestoes)
    AAdd( aQuestoes ,{-1, Space(Len(SKG->KG_CODQST)), Space(Len(SKG->KG_DESC)), 0} )
Endif

//���������������������������������������������������������������������Ŀ
//� Monta o wizard da busca                                             �
//�����������������������������������������������������������������������

DEFINE WIZARD oWizard TITLE OemtoAnsi( STR0006 ) HEADER OemtoAnsi( STR0007 ) ; 
	MESSAGE OemtoAnsi( STR0008 ); //"Estas questoes dissertativas pertencem a pesquisa selecionada e serao analisadas de acordo com o metodo de busca"
	TEXT " "; 
	NEXT {|| .T. } ;
	PANEL NOFIRSTPANEL 
		
	oWizard:GetPanel( 1 )		

	//���������������������������������������������������������������������Ŀ
	//� Browse de questoes da pesquisa                                      �
	//�����������������������������������������������������������������������
	oLbx2:=TwBrowse():New(000,000,288,138,,aCabDis,aTam,oWizard:GetPanel(1),,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx2:bLDblClick	:={ || GprMarkQuest(@oLbx2, @aQuestoes) }
		
	oLbx2:lColDrag	:= .T.
	oLbx2:nFreeze	:= 1
		
	oLbx2:SetArray( aQuestoes )  

	aLine := {	IIF(oLbx2:aArray[oLbx2:nAt,1]>0,oOk,oNo), oLbx2:aArray[oLbx2:nAt][2], oLbx2:aArray[oLbx2:nAt][3], oLbx2:aArray[oLbx2:nAt][4] }

	oLbx2:bLine	:= {|| aLine }
							 
	//���������������������������������������������������������������������Ŀ
	//� Painel de busca                                                     �
	//�����������������������������������������������������������������������
	CREATE PANEL oWizard  HEADER OemtoAnsi( STR0006 ) ; 
		MESSAGE OemtoAnsi( STR0009 ) ; 
		BACK {|| .T. } ;
		NEXT {|| lAvanco } ;
		FINISH {|| .T. } PANEL

	oWizard:GetPanel( 2 )

	@ 15,05 SAY OemtoAnsi( STR0010 ) OF oWizard:GetPanel(2) SIZE 90,8 PIXEL  
	@ 25,05 GET cBusca OF oWizard:GetPanel(2) SIZE 200,10 When .T. PIXEL	


	TButton():New(25,220, OemtoAnsi( STR0011 ), oWizard:GetPanel(2),{|| lAvanco := GprText( cPesquisa, cBusca, @cTexto, oSay1, oSay2, oSay3, @nOcorrencias, @aLin, oLbx, @oMtr1, @cMsg, aQuestoes ) },45,12,,,,.T.,,,,,,)

	//���������������������������������������������������������������������Ŀ
	//� Meter de progresso de analise                                       �
	//�����������������������������������������������������������������������
	oMtr1 := TMeter():New( 65,05,,,  oWizard:GetPanel(2), 275,12,,.T.,,,,,,,,)	

	oSay1 := TSay():New(105,05, {||OemtoAnsi( STR0012 )+" <B>"+StrZero(nOcorrencias,15)+"</B> "+OemtoAnsi( STR0013 ) },oWizard:GetPanel(2),,,,,,.T.,,,200,10,,,,,,.T.)
	oSay3 := TSay():New(120,05, {||cMsg},oWizard:GetPanel(2),,,,,,.T.,,,200,10,,,,,,.T.)

	//���������������������������������������������������������������������Ŀ
	//� Painel de resultados                                                �
	//�����������������������������������������������������������������������
	CREATE PANEL oWizard  HEADER OemtoAnsi( STR0014 ) ; 
		MESSAGE OemtoAnsi( STR0015 ) ; //"Questoes com respostas de acordo com o criterio de busca selecionado. Clique nas questoes para visualisar suas respectivas respostas"
		BACK {|| .T. } ;
		NEXT {|| .T. } ;
		FINISH {|| .T. } PANEL

		oWizard:GetPanel( 3 )

		oLbx:=TwBrowse():New(000,000,130,138,,aCab,aTam,oWizard:GetPanel(3),,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		
		oLbx:lColDrag	:= .T.
		oLbx:nFreeze	:= 1
		
		oLbx:bChange    := {|| cTexto := aLin[oLbx:nAt,5] , oSay2:Refresh() }		
		
		oLbx:SetArray( aLin )  
		
		oLbx:bLine		:= { ||{oLbx:aArray[oLbx:nAt][1],;
								 oLbx:aArray[oLbx:nAt][2],;
								 oLbx:aArray[oLbx:nAt][3],;								 
								 oLbx:aArray[oLbx:nAt][4] } }

		//���������������������������������������������������������������������Ŀ
		//� Scroll do texto dissertativo                                        �
		//�����������������������������������������������������������������������
									
		oSbr1  := TScrollBox():New(oWizard:GetPanel(3),0,133,138,156,.T.,.T.,.T.)
	
		oSay2 := TSay():New(0,2, {||cTexto}, oSbr1, ,,,,.T.,.T.,,,130,600,,,,.T.,,.T. )
	
ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GprText    �Autor  � Henry Fila           � Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Analisa as respostas dissertativas de uma pesquisa         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GprAnalyser( cPesquisa )                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Codigo da Pesquisa                                  ���
���Parametros� ExpC2: Busca                                               ���
���Parametros� ExpC1: Texto a ser buscado                                 ���
���Parametros� ExpC1: Objeto de refresh1                                  ���
���Parametros� ExpC1: Objeto de refresh2                                  ���
���Parametros� ExpC1: Ocorrencias encontradas (referencia)                ���
���Parametros� ExpC1: Linha do objeto memo(referencia)                    ���
���Parametros� ExpC1: Objeto do browse de resposta                        ���
���Parametros� ExpC1: Objeto do browse de resposta                        ���
���Parametros� ExpC1: Objeto do browse de resposta                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function GprText( cPesquisa, cPChave, cTexto, oSay1, oSay2, oSay3, nOcorrencias, aLin, oLbx, oMtr1, cMsg, aQuestoes )

Local aArea    := GetArea()        
Local aPChave  := {}

Local cText    := ""

Local lFind    := .F.

Local nX       := 0                
Local nI       := 0                                          


//���������������������������������������������������������������������Ŀ
//� Inicializa variaveis de contadores e ocorrencias                    �
//�����������������������������������������������������������������������
oMtr1:nTotal := 100
aLin         := {}
nOcorrencias := 0

//���������������������������������������������������������������������Ŀ
//� Ajusta separacao e acentuacao                                       �
//�����������������������������������������������������������������������
IF !Empty(cPChave)
	cPChave := UPPER(NoAcento(ansitooem(AllTrim(cPChave))))
	While "  "$cPChave
		cPChave := strtran(cPChave,'  ','')
	Enddo
	aPChave := StrTokArr(cPChave,' ')
	lHasChave := .t.
EndIf

//���������������������������������������������������������������������Ŀ
//� Busca respostas de questoes dissertativas da pesquisa               �
//�����������������������������������������������������������������������
SKU->( dbSetOrder( 1 ) )
If SKU->( MsSeek( xFilial( "SKS" ) + cPesquisa ) )
	
	While SKU->( !Eof() ) .And. SKU->KU_FILIAL == xFilial( "SKU" ) .And. ;
								SKU->KU_CODPESQ == cPesquisa

 		//���������������������������������������������������������������������Ŀ
		//� Busca dados da questao                                              �
		//�����������������������������������������������������������������������
    	cTexto := ""
									
		SKG->( dbSetOrder( 1 ) )
		If SKG->( MsSeek( xFilial( "SKG" ) + SKU->KU_CODQUES ) )

			//���������������������������������������������������������������������Ŀ
			//� Incrementa o meter                                                  �
			//�����������������������������������������������������������������������
			If(nI==100,nI := 0,nI++)
			oMtr1:Set(nI)
			oMtr1:Refresh()

			//���������������������������������������������������������������������Ŀ
			//� Verifica se o tipo de questao e dissertativa e se foi selecionada   �
			//�����������������������������������������������������������������������

			If AScan( aQuestoes,{|x| x[1] == 1 .And. Alltrim(x[2]) == Alltrim(SKG->KG_CODQST)  } ) > 0			
			
				If SKG->KG_TIPOQST == "3"
	
					//���������������������������������������������������������������������Ŀ
					//� Busca o campo memo da questao                                       �
					//�����������������������������������������������������������������������
					cText := ""        
					GprDescricao(@cText, SKU->KU_CODDISS)
	
					cText := STRTRAN(cText,CHR(13)," <BR> ")
					cText := STRTRAN(cText,CHR(10)," <BR> ")
					cText := STRTRAN(cText,"<BR> <BR>"," <BR> ")
	
					//���������������������������������������������������������������������Ŀ
					//� Trata acentuacao do texto memo                                      �
					//�����������������������������������������������������������������������
					cText := UPPER(NoAcento(AnsiToOem(AllTrim(cText))))	
	
					//���������������������������������������������������������������������Ŀ
					//� Busca a pesquisa no campo memo                                      �
					//�����������������������������������������������������������������������
					nOkPChv := GprFindInText(aPChave,@cText)			
	
					//���������������������������������������������������������������������Ŀ
					//� Inclui no array os dados da busca bem sucedida                      �
					//�����������������������������������������������������������������������
					If nOkPChv > 0                                                       
						AAdd(aLin,{SKU->KU_CODQUES,SKG->KG_DESC,SKU->KU_CODRESP,StrZero(nOkPChv,3),cText} )
						lFind := .T.
						nOcorrencias++
						oSay1:Refresh()                                                                                 
						oLbx:SetArray(aLin)					
						
						oLbx:bLine		:= { ||{oLbx:aArray[oLbx:nAt][1],;
												 oLbx:aArray[oLbx:nAt][2],;
												 oLbx:aArray[oLbx:nAt][3],;												 
												 oLbx:aArray[oLbx:nAt][4] } }
						
					EndIf
					
				Endif
				
			Endif	
			
		Endif
		
		SKU->( dbSkip() )
	
	EndDo

Endif

If lFind
	cMsg := HTMO+OemtoAnsi( STR0016 )+HTMC+OemtoAnsi( STR0017 )
	oSay3:Refresh()
Else
	cMsg := HTMO+OemtoAnsi( STR0018 )+HTMC+OemtoAnsi( STR0019 ) //"         Altere o Filtro e tente novamente."
	oSay3:Refresh()
EndIf


If Empty( aLin )
	aLin     := {{Space(6),Space(30),Space(30),StrZero(0,3),""}}
Else
	cTexto := aLin[1,5]		
Endif	

ASort(aLin,,,{|x1,x2| x1[4]>x2[4] })

//���������������������������������������������������������������������Ŀ
//� Refresh nos objetos                                                 �
//�����������������������������������������������������������������������

oMtr1:Set(100)             
oMtr1:Refresh()

oSay2:Refresh()                          

//���������������������������������������������������������������������Ŀ
//� Restaura a area de trabalho                                         �
//�����������������������������������������������������������������������

RestArea( aArea )

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GprDescrica�Autor  � Henry Fila           � Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca o texto dentro de um campo memo                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GprDescricao( cTexto, cCodigoTexto )                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Texto                                               ���
���Parametros� ExpC2: Codigo do campo memo                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GprDescricao( cTexto, cCodTexto )

Local aArea := GetArea()

DEFAULT cTexto := ""          

//���������������������������������������������������������������������Ŀ
//� Busca o texto na tabela de memos                                    �
//�����������������������������������������������������������������������
SYP->(dbSetOrder( 1 ) )

If  SYP->( MsSeek( xFilial( "SYP" ) + cCodTexto )  )

	While SYP->( !Eof() ) .And. SYP->YP_FILIAL == xFilial( "SYP" ) .And. ;
									SYP->YP_CHAVE  == cCodTexto

		//���������������������������������������������������������������������Ŀ
		//� Adiciona o memo no retorno da variavel                              �
		//�����������������������������������������������������������������������
		cTexto += SYP->YP_TEXTO		
		
	    SYP->( dbSkip() )
	EndDo

EndIf

RestArea( aArea )
                 
Return( .T. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GprFindinText�Autor  � Henry Fila         � Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca o texto procurado                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GprFindInText(aPChave,cText)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1: Array dos textos                                    ���
���Parametros� ExpC2: Busca                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function GprFindInText(aPChave,cText)

Local cTextLocal := cText
Local aTextLocal := {}
Local nFound := 0 , nI , nJ ,nK , nT

//���������������������������������������������������������������������Ŀ
//� Trata o texto incluindo espacos                                     �
//�����������������������������������������������������������������������
cTextLocal := strtran(cTextLocal,'.',' . ')
cTextLocal := strtran(cTextLocal,',',' , ')
cTextLocal := strtran(cTextLocal,'!',' ! ')
cTextLocal := strtran(cTextLocal,'?',' ? ')
cTextLocal := strtran(cTextLocal,'"',' " ')
cTextLocal := strtran(cTextLocal,"'",' " ')

//���������������������������������������������������������������������Ŀ
//� Analisa contorno fonetico                                           �
//�����������������������������������������������������������������������
cTextLocal := strtran(cTextLocal,'K','C')
While '  '$cTextLocal
	cTextLocal := strtran(cTextLocal,'  ',' ')
Enddo

aTextLocal := strtokarr(cTextLocal,' ')

nT := len(aPChave)
nK := len(aTextLocal)       

//���������������������������������������������������������������������Ŀ
//� Busca a palavra no campo memo                                       �
//�����������������������������������������������������������������������
For nI := 1 to nT
	cPalChave := alltrim(fonetica(aPChave[nI]))
	For nj := 1 to nK
		if cPalChave $ fonetica(aTextLocal[nj])
			//���������������������������������������������������������������������Ŀ
			//� Inclui a palavra no texto com caracteristicas html                  �
			//�����������������������������������������������������������������������
			aTextLocal[nj] := HTMO+aTextLocal[nj]+HTMC
			nFound++
		Endif
	Next
Next

If nFound>0
	cText := ""
	aeval(aTextLocal,{|x| cText += x + ' '})
Endif

Return nFound

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GprMarkQuest �Autor  � Henry Fila         � Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca a questao a ser analisada                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GprMarkQuest(aLbx2,aQuestoes)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto da listbox                                   ���
���          � ExpA2: Array de questoes                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GprMarkQuest(oLbx2, aQuestoes)

aQuestoes[oLbx2:nAt,1] := aQuestoes[oLbx2:nAt,1] * (-1)
oLbx2:Refresh()

Return

