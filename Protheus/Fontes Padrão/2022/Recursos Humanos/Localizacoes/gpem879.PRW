#INCLUDE "PROTHEUS.ch"
#INCLUDE "GPEM879.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa    �GPEM879   �Autor  �L.Trombini          � Data �  15/09/2010 ���
���������������������������������������������������������������������������͹��
���Desc.       �Gera arquivos Magneticos para o Equador                     ���
���������������������������������������������������������������������������͹��
��� Uso        � Generico                                                   ���
���������������������������������������������������������������������������͹��
���            �    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.       ���
���������������������������������������������������������������������������͹��
���Programador � Data   �   BOPS      �  Motivo da Alteracao                ���
���������������������������������������������������������������������������͹��
���Jonathan Glz�05/05/15�   PCREQ-4256� Se elimina la funcion AjustaGPM879, ���
���            �        �             � la cual realiza la modificacion al  ���
���            �        �             � diccionario de datos(SX1) por motivo���
���            �        �             � de adecuacion de nueva estructura de���
���            �        �             � SXs para version 12                 ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function GPEM879()

Local nOpca
Local aSays			:= {}, aButtons:= { } //<== arrays locais de preferencia

Private cCadastro 	:= OemToAnsi(STR0001) //"Ajuste de Parametros"
Private nSavRec  		:= RECNO()
Private cProcessos	:= ""
Private cPer       	:= ""
Private nTipoRel		:= 0
Private cProcRange  	:= ""
Private cProcAux		:= ""
Private lUmProc		:= .F.
Private lSubAG		:= .F.
Private lTemS1		:= .F.
Private lTemS2		:= .F.
Private lTemS3		:= .F.
Private cValSr		:= "01"

nOpca := 0

AADD(aSays,OemToAnsi(STR0002) )  //"Rutina para gener. de archivo de texto "
AADD(aSays,OemToAnsi(STR0003) )  //"O sistema ir� gerar o arquivo de acordo com os par�metros informados."

AADD(aButtons, { 5,.T.,{|| Pergunte("GPM879",.T.) }} )
AADD(aButtons, { 1,.T.,{|| If( GPE879Gera(), FechaBatch(), ) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao     GPE875Gera�Autor  �Luis Trombini       � Data �  15/09/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega parametros e cria arquivo texto escolhido pelo     ���
���          � usuario.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � P11                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GPE879Gera()

//--Carrega as perguntas.
Pergunte("GPM879",.F.)

//--Seta e Carrega os Mnemonicos.
SetMnemonicos(NIL,NIL,.T.)

/*
��������������������������������������������������������������Ŀ
� Variaveis utilizadas para parametros                         �
� mv_par01        //  Filial ?	 		    				   �
� mv_par02        //  Mes/Ano?						           �
� mv_par03        //  Data de Envio					           �
� mv_par04        //  Arquivo de Saida?                        �
����������������������������������������������������������������
*/
cFilial     := mv_par01 // verificar o de/para
cMesAno 	:= mv_par02
Private nTamProc 		:= GetSx3Cache("RC_PROCES", "X3_TAMANHO")
Private nHdl    		:= fCreate(mv_par03)

If nHdl == -1
    MsgAlert(STR0004+mv_par03+STR0005,STR0006) //"O arquivo de nome "###" nao pode ser executado! Verifique os parametros."###"Atencao!"
    Return .F.
Endif

//Inicializa a regua de processamento
Processa({|lEnd| GPE879Proc() },STR0007)         //"Processando..."

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    |GPE879Proc�Autor  �Luis Trombini       � Data �  15/09/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de geraco do arquivo                                ���
�������������������������������������������������������������������������͹��
���Uso       � P11                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GPE879Proc()

Local cForm0, cForm0OK, cFormE, cFormEOK, cFormL, cFormLOK, lCond
Local nTamLin, cLin, cCpo, nPoint, nX, nI, nJ, nZ
Local cLectura 		:= SPACE(1)
Local cFilialAnt 		:= SPACE(FWGETTAMFILIAL)
Local lRotBlank 		:= .F.
Local aPos				:= {,,,,,,,}
Local nAux				:= 0
Local nCount			:= 0
Local nPos				:= 1
Private nTotalHE    	:= 0
Private aRCCE			:= {}
Private aRCCS			:= {}
Private cfilialde   	:= substr(mv_par01,1,2)
Private cFilialate	:= substr(mv_par01,4,2)
Private cMes, cAno , cRTrab, cTpEmp, cPubl
Private nMaxEM 		:= 0
Private nDiasTra
Private aPerFechado 	:= {}
Private aPerAberto 	:= {}
Private aVerbasLIQ  	:= {}
Private aCodFol		:= {}
Private aInfoFil		:= {}
Private ndurac 		:= 0
Private aPerTodos		:= {}
Private DDTINI      	:= ctod("  /  /  ")
Private cValN			:= "     0,00"
Private nCodEmp		:= 0
Private cConvenc   	:= ""
Private ngrav      	:= .f.

If (Len(StrTran(Alltrim(cProcRange),'*','')) / nTamProc) == 1
	cMesAno := StrTran(Alltrim(cProcRange),'*','')
	lUmProc := .T.
Endif

cNomeArq:= "S023"

//monta os ARRAYS de posicoes. Posicao de inicio e tamanho.
nPoint := 1//Ponteiro contador para selecionar a posicao de inicio de cada campo corretamente.
DbSelectArea("RCB")
DbSetOrder(1)
cFilRCB:=xFilial("RCB")
DbSeek(cFilRCB + cNomeArq)
While cFilRCB == RCB_FILIAL .and. RCB_CODIGO == cNomeArq
	cCpo:= Alltrim(RCB_CAMPOS)
	Do Case
		Case cCpo == "ITEM"
			aPos[1]:={nPoint, RCB_TAMAN}
		Case cCpo == "DIGITOS"
			aPos[2]:={nPoint, RCB_TAMAN}
		Case cCpo == "CONTEUDO"
			aPos[3]:={nPoint, RCB_TAMAN}
	EndCase
	nPoint += RCB_TAMAN
	DbSkip()
Enddo

//�������������������������������������������������������������������������������������Ŀ
//�Guarda as posicoes inicio e tamanho, dentro das vaiaves com os respectivos conteudos.�
//���������������������������������������������������������������������������������������
cFilRCC:=xFilial("RCC")
DbSelectArea("RCC")
DbSetOrder(1)
DbSeek(xFilial()+cNomeArq)
Do While cFilRCC == RCC_FILIAL .and. RCC_CODIGO == cNomeArq
//    If SUBSTR(RCC_CONTEU,1,1) == nTipoArq
		cItem   	:= Alltrim(SubStr(RCC_CONTEU, aPos[1,1], aPos[1,2]))
		cDigitos 	:= Alltrim(SubStr(RCC_CONTEU, aPos[2,1], aPos[2,2]))
		CConteudo   := Alltrim(SubStr(RCC_CONTEU, apos[3,1], aPos[3,2]))
		AAdd(aRCCE,{cItem,cDigitos,Cconteudo})
//	EndIf
	DbSkip()
EndDo

#IFDEF TOP
   	RH6->(DbCloseArea() )
	cAliasX := "RH6"
    cQuery :="Select * from "+ RetSqlName("RH6")+" RH6 "
    cQuery += "WHERE " + "RH6."+RANGESX1("RH6_FILIAL"  ,MV_PAR01)+" AND "
    cQuery += "RH6.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH6.RH6_FILIAL,RH6.RH6_MAT"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasX,.T.,.T.)
#ELSE

	cAliasX := "RH6"
		//��������������������������������������������������������������������������Ŀ
		//� Verifica a ordem selecionada                                             �
		//����������������������������������������������������������������������������
	cIndCond:= "RH6_FILIAL + RH6_MAT"
	cIndTRB	:= "FILIAL + MAT"

		//cArqNtx  := CriaTrab(NIL,.F.)
		//IndRegua("SRA",cArqNtx,cIndCond,,,STR0039)				//"Selecionando Registros..."
	(cAliasX)->( DbGoTop() )

	//-- Adiciona no filtro o parametro tipo Range
	//-- Filial
	cFiltro := '(RH6->RH6_FILIAL  $ "' + mv_par01  + '")'
	oSection:SetFilter(cFiltro, cIndCond, , "RH6")
	DBGOTOP()
#ENDIF

//// anterior
//If nTipoArq $ "1"
DbSelectArea('SM0')
	DbSetOrder(1)
	DbSeek(cEmpAnt+cFilialDe,.T.)
	While !SM0->(EOF())
		//# Alterado pra melhorar performce
		If SM0->M0_CODIGO+SM0->M0_CODFIL > cEmpAnt+cFilialAte
			Exit
		EndIf

		aSM0 := {}
		For nI:=1 To Len(aRCCS)
			lCond := If(Empty(aRCCS[nI][3]),.T.,&(aRCCS[nI][3]))
			//Verificar se tem que fazer pesquisa em algum arquivo
			If lCond .And. !Empty(aRCCS[nI][6])
				DbSelectArea(aRCCS[nI][6])
				DbSetOrder(aRCCS[nI][7])
				lCond	:=	MsSeek(&(aRCCS[nI][8]))
			Endif

			If lCond//Verifica se existe uma condi��o valida
				cForm0 := &(aRCCS[nI][2])//Verifica o retorno da formula e converte para string caso seja numerico ou data.
				If Type("cForm0") == "N"
					cForm0OK := Str(Form0)
				Elseif Type("cForm0") == "D"
					cForm0OK := DtoC(Form0)
				Else
					cForm0OK := cForm0
				EndIf
			Else
				cForm0OK := " "//Se n�o existir uma condi��o valida, retorna vazio.
			EndIf

			If aRCCS[nI,5] > 0
				AAdd(aSM0,{aRCCS[nI,4],PADR(cForm0OK,aRCCS[nI,5])}) //Ajusta o tam. do result.(Longitude)
			Endif
		Next
		DbSelectArea('RH6') //Fucionario
//		DbSetOrder(1)
//		DbSeek(cfilialde,.T.)
		ProcRegua(RH6->(RecCount()))
		While !RH6->(EOF()) .and. RH6->RH6_Filial <= cFilialAte
			//# Alterado pra melhorar performce
			If RH6->RH6_FILIAL > cFilialAte
				Exit
			EndIf

/*/			If nTipoArq == "1" .and. AnoMes(SRA->RA_ADMISSA) <> (cAno+cMes)
				SRA->(DbSkip())
				Loop
			Endif

			If nTipoArq == "2" .and.AnoMes(SRA->RA_DEMISSA) <> (cAno+cMes)
				SRA->(DbSkip())
				Loop
			Endif
			If nTipoArq == "3" .and. AnoMes(SRA->RA_DATAALT) <> (cAno+cMes)
				SRA->(DbSkip())
				Loop
			Endif
			If nTipoArq == "6" .and. SRA->RA_SITFOLH <> "A"
				SRA->(DbSkip())
				Loop
			Endif */


			aRegistro := {}//Limpa o vetor a cada novo funcionario.
			nposini := 1
			IncProc(STR0007 + space(1) + RH6->RH6_MAT)

			For nJ:=1 To Len(aRCCE)//Le o vetor aRCCE(Empregados) e alimenta o vetor aRegistro.
				cFormEOK := " "//Se n�o existir uma condi��o valida, retorna vazio.
				cFormE := &(aRCCE[nJ][3])//Variavel que recebe o conteudo desse vetor calculado.
			   	If Type("cFormE") == "N"
					cFormEOK := Str(cFormE)
				Else
					cFormEOK := cFormE
				EndIf
				If Val(aRCCE[nJ,2]) > 0
					AAdd(aRegistro,{nposini,PADR(cFormEOK,Val(aRCCE[nJ,2]))})
				Endif
				nposini += Val(aRCCE[nJ,2])
			Next
			For nX:=1 To Len(aSM0) //Adicona o vetor de empresas aSM0{} ao vetro aRegistro{}.
				AAdd(aRegistro,aSM0[nX])
			Next
			aSort(aRegistro,,,{|aReg1,aReg2| aReg1[1] < aReg2[1]})//Ordena vetor.
			GPE879TXT()//Funcao que grava o registro por funcionario.
			ngrav := .t.
			nTotParc := 0

			RH6->(DbSkip())
		EndDo

		SM0->(DbSkip())
	EndDo
	if ngrav
		MsgAlert(STR0019+mv_par03) //Identifique se a Empresa � Publica # Atencao
    endif
//Endif

fClose(nHdl)//Fechamento do objeto Dialog

#IFDEF TOP
  DbCloseArea(cAliasX)
#EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPE875TXT �Autor  �Rafael P. Rizzatto  � Data �  19/04/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcion que graba tolo archivo del texto con el conteudo   ���
���          � dos arrays.                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GPE879TXT()
Local nX, cLin
    cLin := ""
	For nX :=1 To Len(aRegistro)
		cLin += Alltrim(aRegistro[nX,2])+IF(LEN(aRegistro)<> nX,chr(9),"")
	Next
	cLin += CRLF

    If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) //Testa por erros durante a gravacao da linha montada.
        If !MsgAlert(STR0008,STR0006) //"Ocorreu um erro na gravacao do arquivo. Continua?"###"Atencao!"
        Endif
    Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEM875   �Autor  �Luis Trombini       � Data �  21/09/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega janela de opcoes dos arquivos a serem gerados.      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � P11                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fTpoRot879( )

Local cTitulo	:= STR0016  //"tipo de relatorio"
Local cString	:= ""
Local MvParDef	:= ""
Local MvRetor	:= ""
Local nFor		:= 0
Local MvPar
Local lExiste   := .F.
Private aSit	:= {}

cAlias := Alias() 					// Salva Alias Anterior

If Upper(Alltrim(ReadVar() )) == "MV_PAR01"
	MvPar:=&(Alltrim(ReadVar()))	// Carrega o conteudo da variavel
	mvRet:=Alltrim(ReadVar())		// carrega o nome da variavel
Endif

CursorWait()

MvParDef:= "1"

aAdd(aSit, "Archivo de Dados del Empleado")

CursorArrow()

IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,,,.F.,1,1)
	CursorWait()
	For nFor := 1 To Len( MvPar )
	   	IF ( SubStr( mVpar , nFor , 1 ) # "*" )
			mvRetor += SubStr( mVpar , nFor , 1 )
	  	Endif
   	Next nFor
	MvRet := Alltrim(Mvretor)  //carrega o resultado da fopcoes
	CursorArrow()
EndIF

dbSelectArea(cAlias) // Retorna Alias

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fDir879m()�Autor  �Luis Trombini      � Data �  21/09/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     �Apresenta janela para usuario escolher diretorio/arquivo a  ���
���          �ser gerado.                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � P11                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function fDir879m()

Local mvRet		:= Alltrim(ReadVar())
Local cType 	:= ""
Local cArq		:= ""
Local aDir		:= {}
Local nDir		:= 0

cType:= STR0015 //"Arquivos Texto (*.TXT) |*.txt|"
//��������������������������������������������������������������Ŀ
//� Comando para selecionar um arquivo.                          �
//� Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.   �
//�            GETF_LOCALHARD - Inclui o Harddisk local.         �
//����������������������������������������������������������������
cArq 	:= cGetFile(cType, STR0017, 0,,.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY)  // "Selecione arquivo "
aDir	:= { { cArq } }


&mvRet := cArq

Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPER875   �Autor  �Luis Trombini      � Data �  21/09/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera tabelas necessarias para geracao de arquivos Magneticos���
���          �para o Equador.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � P11                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function GPEM879B()

Private lImpMnemo		:= .F.

Begin Sequence

		IF ( lImpMnemo := MsgNoYes(	OemToAnsi(	STR0012 + ;	//"O Sistema ira Atualizar a Tabela RCC para geracao de arquivos de texto."
											CRLF	+ ;
											STR0013 + ;	//"Faca um Backup (RCC) antes de Iniciar o Processo de Atualizacao."
											CRLF	+ ;
											CRLF	+ ;
											STR0014   ;	//"Confirma a Atualizacao da Tabela?"
					   					 ),;
				 				OemToAnsi( STR0009 ) ;	//"Aten��o"
							);
		)

		MsAguarde( { || CarTab879() } )

	EndIf


End Sequence



Return( NIL )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CarTab875   �Autor�Luis Trombini      � Data �  21/09/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � P11                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CarTab879()

Local aTabRCB   := {}
Local aTabRCC	:= {}
Local nI		:=	0
Private cFilRCC  := xFilial("RCC")

DbSelectArea("RCC")
DbSetOrder(1)

gper875del()        //se tabelas jah existem, apaga.


//Carrega informacoes da tabela S023 - Arquivos Magneticos
cNomeArq := "S023"

AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','001','TIPO IDENTIFICACION                                 1ALLTRIM(RH6->RH6_TIPID)                                                                                                                                                                             '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','002','IDENTIFICACION DEL RETENIDO                        10ALLTRIM(RH6->RH6_IDRET)                                                                                                                                                                             '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','003','NOMBRE DEL EMPLEADO                                40ALLTRIM(RH6->RH6_NOME)                                                                                                                                                                              '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','004','NR. TELEFONO                                       10ALLTRIM(RH6->RH6_NRTELE)                                                                                                                                                                            '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','005','DIRECCION                                          20ALLTRIM(RH6->RH6_DIRCAL)                                                                                                                                                                            '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','006','NUMERO DIRECCION                                   10ALLTRIM(RH6->RH6_DIRNUM)                                                                                                                                                                            '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','007','COD. PROVINCIA                                      3RH6->RH6_CODEST                                                                                                                                                                                     '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','008','COD. CIUDAD                                         5RH6->RH6_CODMUN                                                                                                                                                                                     '})

//grava as tabelas

	For nI := 1 To Len(aTabRCC)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabRCC[nI][01]
		Replace RCC_CODIGO With aTabRCC[nI][02]
		Replace RCC_FIL    With aTabRCC[nI][03]
		Replace RCC_CHAVE  With aTabRCC[nI][04]
		Replace RCC_SEQUEN With aTabRCC[nI][05]
		Replace RCC_CONTEU With aTabRCC[nI][06]
		MsUnLock()
	Next nI


	MsgInfo(STR0010 , STR0009) //Aviso#Tabelas Carregadas

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPER875DEL�Autor  �Luis Trombini       � Data �  21/09/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Apaga tabelas RCC correspondentes aos Arquivos Magneticos do���
���          �Equador .                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � P11                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function GPER875DEL()

Local nAux := 1
Local aNomeTab := {}

Aadd(aNomeTab,"S023")

For nAux:= 1 to 1
	If RCC->(dbSeek(cFilRCC + aNomeTab[nAux]),.T.)
    	While RCC->( !Eof() ) .And. RCC->(RCC_FILIAL+RCC_CODIGO) == cFilRCC+aNomeTab[nAux]
			IF RCC->( RecLock( "RCC" , .F. , .F. ) )
				RCC->( dbDelete() )
				RCC->( MsUnLock() )
			EndIF
			RCC->( DbSkip() )
		EndDo
	Endif
Next

Return( NIL )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetcIess  �Autor  �Luis Trombini       � Data �  21/09/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o Codigo da causa de dispenda do IESS              ���
���          �                                                            ���
���          �   PARAMETROS:                                              ���
���          �    cTabela     == Nome da tabela que sera pesquisada       ���
���          �    cOperador   == Tipo de comparacao de valores            ���
���          �    cCodRes     == Codigo da Rescisao                       ���
�������������������������������������������������������������������������͹��
���Uso       � P11                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function RetcIess(cTabela,cOperador,cCodres)

Local nPos := 0
Local cIess := 0

nPos := fPosTab(cTabela, cCodRes , cOperador, 4  )

If nPos > 0
 cIess := IF( FTABELA(cTabela, nPos , 12 ) <> NIL, FTABELA(cTabela,  nPos, 12 ) , 0 )
Endif

Return cIess


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fTpoProce �Autor  �Luis Trombini       � Data �  21/09/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega janela com opcoes dos Processos.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function fTpo879()

Local cTitulo	:= STR0016  //"tipo de relatorio"
Local cString	:= ""
Local MvParDef	:= ""
Local MvRetor	:= ""
Local nFor		:= 0
Local MvPar
Local lExiste   := .F.
Private aSit	:= {}

cAlias := Alias() 					// Salva Alias Anterior

If Upper(Alltrim(ReadVar() )) == "MV_PAR01"
	MvPar:=&(Alltrim(ReadVar()))	// Carrega o conteudo da variavel
	mvRet:=Alltrim(ReadVar())		// carrega o nome da variavel
Endif

CursorWait()

MvParDef:= "1"

aAdd(aSit, "Archivo Empleado")

CursorArrow()

	IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,,,.F.,1,1)
		CursorWait()
		For nFor := 1 To Len( MvPar )
		   	IF ( SubStr( mVpar , nFor , 1 ) # "*" )
				mvRetor += SubStr( mVpar , nFor , 1 )
		  	Endif
	   	Next nFor
		&MvRet := Alltrim(Mvretor)  //carrega o resultado da fopcoes
		CursorArrow()
	EndIF

dbSelectArea(cAlias) // Retorna Alias

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fProcm    � Autor � Luis Trombini         � Data �21/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Selecionar o Processo                               		    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fProcesso()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function fProcM879(l1Elem, lTipoRet, aElem)

Local cTitulo	:=""
Local nFor		:= 0
Local nElem		:= 0
Local MvPar
Local MvParDef	:=""
Local MvRetor	:= ""
Local nX3Tam	:= 0

Private aSit:={}
l1Elem := If (l1Elem = Nil , .F. , .T.)

DEFAULT lTipoRet 	:= .T.
DEFAULT aElem		:= {}

cAlias := Alias() 					// Salva Alias Anterior

IF lTipoRet
	MvPar:=&(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
EndIF

dbSelectArea("RCJ")
If dbSeek(cFilial)
	CursorWait()
	While !Eof() .And. RCJ->RCJ_FILIAL == cFilial
		If allTrim(RCJ->RCJ_CODIGO) != ""
			Aadd(aSit, RCJ->RCJ_CODIGO + " - " + Alltrim(RCJ->RCJ_DESCRI))
			MvParDef += RCJ->RCJ_CODIGO
		Endif
		dbSkip()
	Enddo
	If Len(aElem) > 0
		For nElem := 1 to Len(aElem)
			Aadd(aSit, aElem[nElem]) 				//"EXT - Valores Extras"
			MvParDef += SubStr(aElem[nElem], 1, 3)	//MvParDef += "EXT"
		Next nElem
	EndIf
	CursorArrow()
Endif

IF lTipoRet
	nX3Tam := GetSx3Cache("RCJ_CODIGO","X3_TAMANHO")
	IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,,,l1Elem, nX3Tam)  // Chama funcao f_Opcoes
		CursorWait()
		For nFor := 1 To Len( mVpar ) Step 3
			IF ( SubStr( mVpar , nFor , 3 ) # "***" )
				mvRetor += SubStr( mVpar , nFor , 3 )
			Endif
		Next nFor
	   	If( Empty(mvRetor) )
			mvRetor := Space(nX3Tam)
		EndIf
		&MvRet 	:= mvRetor
		CursorArrow()
	EndIF
EndIF

dbSelectArea(cAlias) // Retorna Alias

Return( IF( lTipoRet , .T. , MvParDef ) )


/****************************/
Static Function LimpiaStatic()
	aRemune	:=	Nil
	aDatasSR8:=	Nil
Return
