#INCLUDE "FINA373.ch"
#INCLUDE "PROTHEUS.CH"

Static lFWCodFil := .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FINA373   � Autor � Adrianne Furtado      � Data �01.07.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Controle de Emiss�o de DARF                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function FINA373()

//������������������������������������������������������������������������Ŀ
//�Define Variaveis                                                        �
//��������������������������������������������������������������������������

Private aRotina := MenuDef()
Private nValTot  := 0

If GetHlpLGPD({"A6_COD", "A6_AGENCIA", "A6_NUMCON"})
	Return .F.
Endif

mBrowse( 6, 1,22,75,"FI9",,,,,, FA373Legen())

Return(.T.)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Adrianne Furtado       � Data �06/07/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
Local aRotina

aRotina := {{ OemToAnsi(STR0021),"AxPesqui"  , 0 , 1, ,.F.},; //"Pesquisar"
			{ OemToAnsi(STR0001),"FINRSRF"  , 0 , 3},; //"Emitir Darf"
   			{ OemToAnsi(STR0002),"FA373Reem", 0 , 2},; //"Reemitir Darf"
			{ OemToAnsi(STR0003),"FA373Cons", 0 , 1},; //"Consulta Darf"
			{ OemToAnsi(STR0004),"FA373Canc", 0 , 5},; //"Cancelar Darf"
			{ OemToAnsi(STR0035),"FA373Legen('x')", 0 , 4, ,.F.} }  //"Legenda"
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � FA373Reem � Autor � Adrianne Furtado      � Data �06.07.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Reemissao de Darf.                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FA373Reem()

Local aDarf     	:= {}
Local aInfo     	:= {}
Local lQuery    	:= .F.
Local cAliasFI9 	:= "FI9"
Local dDataIni
Local dDataFim
Local cGuiaIni
Local cGuiaFim
Local cForIni
Local cForFim
Local nX        	:= 0
Local nY			 	:= 0
Local nValorImp 	:= 0
Local aAreaSm0  	:= SM0->(GetArea())
Local cFilCtr 	 	:= ""  //filial de controle
Local lAchouPai

Static aPergRet 	:= Array(13)

Local aStru  	:= {}
Local cQuery 	:= ""
Local cPerg   := "FINSRF2"  // Pergunta do Relatorio
Local lFI9_FILORI	:= FI9->(FieldPos("FI9_FILORI")) > 0
Local cSeekFil		:= ""

//�����������������������������������������Ŀ
//�Verifica as Perguntas Seleciondas        �
//�---------------------------------        �
//� mv_par01 - Emissao De ?  				�
//� mv_par02 - Emissao Ate?					�
//� mv_par03 - Guia De?						�
//� mv_par04 - Guia Ate?					�
//� mv_par05 - Fornecedor De?				�
//� mv_par06 - Fornecedor Ate?				�
//�������������������������������������������

If Pergunte(cPerg,.T.)
	dDataIni  := MV_PAR01
	dDataFim  := MV_PAR02
	cGuiaIni  := MV_PAR03
	cGuiaFim  := MV_PAR04
	cForIni   := MV_PAR05
	cForFim   := MV_PAR06

	//�������������������������������������������������������������Ŀ
	//� Abre o SE2 com outro alias para ser localizado o titulo 	 �
	//� principal do imposto                   							 �
	//���������������������������������������������������������������
	If !( ChkFile("SE2",.F.,"NEWSE2") )
		Return(Nil)
	EndIf

	dbSelectArea("FI9")
	dbSetOrder(1)

	lQuery := .T.
	aStru  := FI9->(dbStruct())
	cAliasFI9 := "REIMP"

	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("FI9")+" FI9 "
	cQuery += "WHERE FI9.FI9_FILIAL='"+xFilial("FI9")+"' AND "
	cQuery += "FI9.FI9_EMISS >='" +DToS(dDataIni)+"' AND "
	cQuery += "FI9.FI9_EMISS <='" +DToS(dDataFim)+"' AND "
	cQuery += "FI9.FI9_IDDARF >='"+cGuiaIni+"' AND "
	cQuery += "FI9.FI9_IDDARF <='"+cGuiaFim+"' AND "
	cQuery += "FI9.FI9_FORNEC >='"+cForIni +"' AND "
	cQuery += "FI9.FI9_FORNEC <='"+cForFim +"' AND "
	cQuery += "FI9.FI9_STATUS ='A' AND "
	cQuery += "FI9.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(FI9->(IndexKey()))

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFI9)
	For nX := 1 To Len(aStru)
		If aStru[nX][2]<>"C"
			TcSetField(cAliasFI9,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX

	SE2->(DbSetOrder(1))

	While (!Eof() .And. xFilial("FI9")==(cAliasFI9)->FI9_FILIAL .And.;
			(cAliasFI9)->FI9_IDDARF <= cGuiaFim )

		If (cAliasFI9)->FI9_STATUS == 'A' .And.;
			(cAliasFI9)->FI9_EMISS  >= dDataIni .And.;
			(cAliasFI9)->FI9_EMISS  <= dDataFim .And.;
			(cAliasFI9)->FI9_FORNEC >= cForIni .And.;
			(cAliasFI9)->FI9_FORNEC <= cForFim
			
			If lFI9_FILORI .And. !Empty((cAliasFI9)->FI9_FILORI)
				cSeekFil	:= xFilial("SE2",(cAliasFI9)->FI9_FILORI)
			Else
			 	cSeekFil	:= xFilial("SE2")
			EndIf

			If SE2->(DBSeek(cSeekFil+(cAliasFI9)->(FI9_PREFIXO+FI9_NUM+FI9_PARCEL+FI9_TIPO)))

				cFilCtr := FI9->FI9_FILCTR

				dbSelectArea("SA2")
				MsSeek(xFilial("SA2")+(cAliasFI9)->(FI9_FORNECE+FI9_LOJA))

				nX := aScan(aDarf,{|x|	x[1] == SE2->E2_CODRET .And.;
												x[2] == SE2->E2_VENCREA .And.;
												x[4] == SA2->A2_COD .And.;
												x[8] == (cAliasFI9)->FI9_IDDARF })

				//Verifica��o necess�ria, pois a DARF pode ter sido emitida aglutinando somente por COD. RETEN��O e nao FORNECEDOR
				If nX == 0
					nY := aScan(aDarf,{|x|	x[1] == SE2->E2_CODRET .And. x[2] == SE2->E2_VENCREA .And. x[8] == (cAliasFI9)->FI9_IDDARF })
				Endif

				// Obtem o valor do imposto
				nValorImp := (cAliasFI9)->FI9_VALOR

				If nX == 0  .and. nY==0
	        	    If Alltrim((cAliasFI9)->(FI9_FORNECE+FI9_LOJA)) == ''
						lAchouPai := .F.
					Else
						lAchouPai := .T.
					EndIf
					aadd(aDarf,{SE2->E2_CODRET,;
									SE2->E2_VENCREA,;
									xMoeda(nValorImp,SE2->E2_MOEDA,1),;
									SA2->A2_COD,;
									SA2->A2_NOME,;
									lAchouPai,;
									SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA),(cAliasFI9)->FI9_IDDARF,,;
									(cAliasFI9)->FI9_APURA, (cAliasFI9)->FI9_REFER})
				Else
					If nX>0
						aDarf[nX][3] += xMoeda(nValorImp,SE2->E2_MOEDA,1)
					Else
						aDarf[nY][3] += xMoeda(nValorImp,SE2->E2_MOEDA,1)
					Endif
				EndIf
			EndIf
		EndIf
		dbSelectArea(cAliasFI9)
		dbSkip()

	EndDo
	NEWSE2->(dbCloseArea())
	If lQuery
		dbSelectArea(cAliasFI9)
		dbCloseArea()
		dbSelectArea("SE2")
	EndIf

	// Se for informada a filial centralizadora, posiciona nela para impressao dos dados como CGC, Nome, Etc.
	If !Empty(cFilCtr)
		SM0->(MsSeek(cEmpAnt+cFilCtr))
		cFilCtr := ""
	Endif
	For nX := 1 To Len(aDarf)
		aadd(aInfo,{{SM0->M0_NOMECOM,SM0->M0_TEL},;
			aDarf[nX][10],;
			TransForm(SM0->M0_CGC,"@r 99.999.999/9999-99"),;
			aDarf[nX][1],;
			aDarf[nX][11],;
			aDarf[nX][2],;
			aDarf[nX][3],;
			0,;
			0,;
			aDarf[nX][3],;
			aDarf[nX][5],;
			aDarf[nX][6],;
			aDarf[nX][7]})
	Next nX

	aInfoAux := AClone(aInfo)
	If ExistBlock("FA373SCL")
		aInfo := ExecBlock("FA373SCL", .F., .F.,{aInfo})
		If ValType(aInfo) <> "A"
			aInfo := AClone(aInfoAux)
		Endif
	Endif

	If Len(aInfo) > 0
		aPergRet[9] := "1."
		aPergRet[5] := "1."
		PrtDarf(aInfo, aPergRet)
	Else
		Aviso(STR0005,STR0006,{STR0007}) //"Mensagem"###"Nao h� dados no intervalo informado"###"Ok"
	EndIf
	SM0->(RestArea(aAreaSm0))
EndIf

Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � FA373Cons � Autor � Adrianne Furtado      � Data �06.07.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta de Darf.                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FA373Cons()
Local aSize := {}
Local oDlg
Local cIdDarf := Space(20)
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de baixas								  �
//����������������������������������������������������������������
Local cTitulo := OemToAnsi(STR0031) //"DARF - Consulta"
Local aButtons := {}
local l373Cons:= existblock("F373CONS")

Private oGet
Private oSayFor
Private oValTot	:= 0
Private aHeader	:= {}
Private aCols		:= {}

Aadd(aButtons,{"S4WB010N",{|| Fr373Rel(cIdDarf)},STR0022})
AADD(aButtons,{"PMSCOLOR", {|| Fa373Legen(FI9->(RECNO()))}, STR0035 ,STR0035 }) //"Legenda"###"Legenda"
aSize := MsAdvSize(,.F.,400)
DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDLg:lMaximized := .T.

	oPanel1 := TPanel():New(0,0,'',oDlg, oDlg:oFont,.T.,,,,,45,.T.,.T. )  // altura 45

	oPanel1:Align := CONTROL_ALIGN_TOP

	oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,20,20,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	@	003,010 TO 040,145 OF oPanel1 Pixel
	@	003,147 TO 040,500 OF oPanel1 Pixel

	@	015,015 Say STR0008 Of oPanel1 Pixel   //"DARF"
	If l373Cons
		@   015,038	MSGET oGet1 VAR cIdDarf := (Execblock("F373CONS",.f.,.f.)) SIZE 68,10 Picture "@!" OF oPanel1 PIXEL
	EndIf
	@   015,038	MSGET oGet1 VAR cIdDarf SIZE 68,10 Picture "@!" OF oPanel1 PIXEL

DEFINE SBUTTON FROM 015,110	TYPE 1 ACTION (If(!Empty(cIdDarf), nOpca:=F73SlDarf(@oDlg,1,@cIdDarf,@oPanel1,@oPanel2),;
															 nOpca:=0)) ENABLE OF oPanel1

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If( valtype(oget)=="O",if(oGet:TudoOk() .And. Len(aCols) > 0,oDlg:End(),nOpca := 0), nOpca := 0)},{||oDlg:End()},,aButtons)

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �F73SlDarf  � Autor � Adrianne Furtado     � Data � 08.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � GetDados   da Consulta de DARF					          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto onde se encaixara a GetDados  			  ���
���			 � ExpN1 = Opcao selecionada na tela                  		  ���
���			 � ExpC1 = C�digo de identifica��o da DARF					  ���
���			 � ExpO2 = Panel 1                             				  ���
���			 � ExpO1 = Panel 2             				 				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA290                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function F73SlDarf(oDlg,nOpca,cIdDarf,oPanel1,oPanel2)

cIdDarf := If(nOpca=0,"   ",cIdDarf)

aCols := F73RtDarf(cIdDArf)

If !Empty(aCols)

	//������������������������������������������������������Ŀ
	//� Mostra tela com os diversos titulos						�
	//��������������������������������������������������������

	nOpca := 0

	If ValType(oGet) <> "O"
		@ 014,160	SAY STR0009 OF oPanel1 SIZE 80,14 Pixel//"Fornecedor : "
		oSayFor := TSay():New( 014, 200, {|| SubStr(FI9->FI9_FORNEC+' - '+FI9->FI9_LOJA+' - '+SA2->A2_NREDUZ,1,200) }, oPanel1,,,,,,.T.,,,200,14,,,,,,)
		@ 014,415	Say STR0011 OF oPanel1 SIZE 80,14 Pixel //"Cod. Retencao: "
		@ 014,465	Say FI9->FI9_CODRET OF oPanel1 SIZE 80,14  Pixel
		@ 027,160	Say STR0010 OF oPanel1 Pixel SIZE 80,14 //"Emissao: "
		@ 027,200	Say FI9->FI9_EMISS OF oPanel1 SIZE 100,14  Pixel			
		@ 027,416	Say STR0012 OF oPanel1 Pixel SIZE 80,14 //"Valor Total: "
		@ 027,453	Say nValTot Picture "@E 9,999,999,999.99" OF oPanel1 PIXEL SIZE 80,14 //FONT oFnt COLOR CLR_HBLUE //FONT oDlg2:oFont					
		oGet:= MSGetDados():New(90,1,172,312,4,,,,,.F.,,.T.,900,,,,)
		oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet:oBrowse:bChange := {|| F373FORN(@oSayFor) }
	Else
		oGet:ForceRefresh()
	EndIf
Else
	Aviso(STR0019,STR0020,{STR0007}) //"Atencao""N�o h� dados para o c�digo informado."
Endif

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � F73RtDarf � Autor � Adrianne Furtado	  � Data � 08/07/09   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Formata Array com os titulos da DARF						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Fina373													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function F73RtDarf(cIdDArf)
Local Ni

//--- Tratamento Gestao Corporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
//
Local cFilFwFI9 := IIF( lGestao , FwFilial("FI9") , xFilial("FI9") )

PRIVATE aCOLS
aCols := {}
nValTot := 0
//��������������������������������������������������������������Ŀ
//� Montagem da matriz aHeader											  �
//����������������������������������������������������������������
If Len(aHeader) == 0
	AADD(aHeader,{" ","TMP_LEGE","@BMP",5,0," ",	"","C","","" })
	If !Empty( cFilFwFI9 )
		AADD(aHeader,{ OemToAnsi(STR0013),"FI9_FILIAL"	,"@!"             ,TamSx3("FI9_FILIAL")[1] ,0,"","�","C","SE2" } )          //"Filial"
	EndIf
	AADD(aHeader,{ OemToAnsi(STR0014),"FI9_PREFIX"	,"@!"                 ,TamSx3("FI9_PREFIX")[1] ,0,"","�","C","SE2" } )          //"Prefixo"
	AADD(aHeader,{ OemToAnsi(STR0015),"FI9_NUM"		,"@!"                 ,TamSx3("FI9_NUM")[1],0,"","�","C","SE2" } )     			//"N�mero"
	AADD(aHeader,{ OemToAnsi(STR0016),"FI9_PARCEL"	,PesqPict("FI9","FI9_PARCEL"),TamSx3("FI9_PARCEL")[1],0,"","�","C","FI9" } ) 	//"PArcela"
	AADD(aHeader,{ OemToAnsi(STR0017),"FI9_TIPO"	,"@!"                 ,TamSx3("FI9_TIPO")[1],0,"","�","C","SE2" } )          //"Tipo"
	AADD(aHeader,{ OemToAnsi(STR0042),"FI9_FORNEC"	,"@!"                 ,TamSx3("FI9_FORNEC")[1] ,0,"","�","C","SE2" } )          //"Fornecedor"
	AADD(aHeader,{ OemToAnsi(STR0043),"FI9_LOJA"		,"@!"                 ,TamSx3("FI9_LOJA")[1],0,"","�","C","SE2" } )     			//"Loja"
	AADD(aHeader,{ OemToAnsi(STR0018),"FI9_VALOR"	,"@E 9,999,999,999.99",TamSx3("FI9_VALOR")[1],TamSx3("E2_VALOR")[2],"Fa290AtuVl()","�","N","SE2"})//"Valor"
EndIf

DbSelectArea("FI9")
DbSetOrder(1)
DbSeek(xFilial("FI9")+cIdDArf)

//������������������������������������������������������Ŀ
//� Grava aCols com os titulos componentes da DARF		 �
//��������������������������������������������������������

nUsado := Len(aHeader)

//While !(cAliasTrb)->(EOF())
While FI9->(!Eof()) .And.  FI9->(FI9_FILIAL + FI9_IDDARF)  == xFilial("FI9")+cIdDArf
	AADD(aCols,Array(nUsado+1))
	For nI := 1 To nUsado
		If nI == 1
			aCols[Len(aCols)][nI] := If(FI9->FI9_STATUS == "A","ENABLE","DISABLE")
		Else
			aCols[Len(aCols)][nI] := FI9->(FieldGet(FieldPos(aHeader[nI][2])))
		EndIf
		If nI == nUsado
			nValTot += aCols[Len(aCols)][nI]
		EndIf
	Next nI
	aCols[Len(aCols)][nUsado+1] := .F.
	FI9->(dbSkip())
Enddo

FI9->(DbSeek(xFilial("FI9")+cIdDarf))
SA2->(DBSetOrder(1))
SA2->(DbSeek(xFilial("SA2")+FI9->(FI9_FORNEC+FI9_LOJA )))

Return(aCols)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Fr373Rel  � Autor � Adrianne Furtado      � Data � 13.07.09���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do relatorio com a DARF selecionada              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fr373Rel(cidDarf)                                          ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fr373Rel(cIdDarf)

Local oReport
Private cChaveInterFun := ""

If TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef(cIdDArf)
	oReport:PrintDialog()
Else
	Fr373RlR3(cIdDarf)
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ReportDef� Autor � Adrianne Furtado      � Data � 13.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � "Conferencia DARF 			                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef(void)                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(cIdDarf)

Local oReport
Local oSection

//--- Tratamento Gestao Corporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
//
Local cFilFwFI9 := IIF( lGestao , FwFilial("FI9") , xFilial("FI9") )

oReport := TReport():New("FINR373",STR0025+ cIdDarf,,; //"RELACAO DAS NATUREZAS"
                         {|oReport| ReportPrint(oReport,cIdDarf)},STR0023+STR0024)

nTamCod := 0

oSection := TRSection():New(oReport,"Confer�ncia DARF - Nr. " + cIdDarf,{"FI9","SA2"})

//oParent / cName / cAlias / cTitle / cPicture / nSize / lPixel / bBlock codeblock
If !Empty( cFilFwFI9 )
	TRCell():New(oSection,"FI9_FILIAL" 	,"FI9")
EndIf
TRCell():New(oSection,"FI9_PREFIX" 	,"FI9")
TRCell():New(oSection,"FI9_NUM"  	,"FI9")
TRCell():New(oSection,"FI9_PARCEL" 	,"FI9")
TRCell():New(oSection,"FI9_TIPO"    ,"FI9")
TRCell():New(oSection,"FI9_FORNEC"  ,"FI9","Fornecedor",/*cpicture*/,TamSX3("A2_COD")[1]+TamSX3("A2_LOJA")[1]+TamSX3("A2_NOME")[1]+4,/*lPixel*/,{|| SA2->A2_COD+"-"+ SA2->A2_LOJA+" - "+SA2->A2_NOME})
TRCell():New(oSection,"FI9_VALOR"   ,"FI9")

oBreak1 := TRBreak():New( oSection,oSection:Cell("FI9_FORNEC") ,STR0029)

TRFunction():New(oSection:Cell("FI9_VALOR")	, , "SUM"  , oBreak1, , , , .F. ,.F.,.F.  )

oBrkGeral := TRBreak():New(oSection, { || FI9->(!Eof()) },,,,.F.)	//	" T O T A I S "

TRFunction():New(oSection:Cell("FI9_VALOR")	, , "SUM"  , oBrkGeral, , , , .F. ,.F.,.F.  )

Return oReport
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Adrianne Furtado       � Data �13.07.2009���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport, cIdDarf)

Local oSection  := oReport:Section(1)
Local cAliasFI9 := "FI9"

//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
dbSelectArea("FI9")
dbSetOrder(1)

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//������������������������������������������������������������������������Ŀ
//�Query do relat�rio da secao 1                                           �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()

cAliasFI9 := GetNextAlias()

BeginSql Alias cAliasFI9
SELECT *

FROM %table:FI9% FI9

WHERE FI9_FILIAL = %xFilial:FI9% AND
	FI9_IDDARF   = %Exp:cIdDarf% AND
	FI9_STATUS   = "A" AND
	FI9.%notDel%

ORDER BY %Order:FI9%

EndSql
oReport:Section(1):EndQuery()

TRPosition():New(oSection,"SA2",1,{|| xFilial("SA2") + (cAliasFI9)->FI9_FORNECE+(cAliasFI9)->FI9_LOJA})
//������������������������������������������������������������������������Ŀ
//�impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������

oReport:SetMeter(FI9->(LastRec()))

dbSelectArea(cAliasFI9)
While !oReport:Cancel() .And. !(cAliasFI9)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	oReport:IncMeter()

	lFirst := .T.

	While !oReport:Cancel() .And. !(cAliasFI9)->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oSection:Init()

		oSection:PrintLine()

		dbSkip()
	EndDo
	oSection:Finish()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:IncMeter()
EndDo

(cAliasFI9)->(DbCloseArea())

Return NIL



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Fr373RlR3         � Adrianne Furtado      � Data � 13.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Impressao do relatorio com a DARF selecionada              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Fr373Rel(ExpC1) 										  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = String contendo o c�digo da DARF                	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA373				                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fr373RlR3(cIdDarf)

Local cDesc1	:= STR0023 //"Este relatorio ir�demonstrar os titulos de impostos "
Local cDesc2	:= STR0024 //"contidos na DARF selecionada."
Local cDesc3	:= ""
Local wNrel
Local Tamanho	:= "G"
Local CbCont	:= 0
Local CbTxt		:= Space(10)
Local cString	:= "FI9"
Local nColPrefixo
Local nColNumero
Local nColParcela
Local nColTipo
Local nColFornece
Local nColValor
Local nSubTot	:= 0
Local aRelat := aClone(aCols)

//--- Tratamento Gestao Corporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
//
Local cFilFwFI9 := IIF( lGestao , FwFilial("FI9") , xFilial("FI9") )

Private Li			:= 80
Private M_pag		:= 1
Private Titulo		:= STR0025+ cIdDarf //"Conferencia DARF - Nr. "
Private cabec1		:= ""
Private cabec2		:= ""
Private aReturn	:= {STR0026, 1, STR0027, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private nomeprog	:= "FINA373"
Private nLastKey	:= 0

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel := "FR373Rel"
wnrel := SetPrint(cString,wNrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho,"",.F.)
If nLastKey == 27
	Return(Nil)
EndIf

SetDefault(aReturn,cString)
If nLastKey == 27
	Return(Nil)
EndIf

//��������������������������������������������������������������Ŀ
//� Considerar filiais                                           �
//����������������������������������������������������������������
nColPrefixo	:= 9
nColNumero	:= 18
nColParcela	:= 33
nColTipo	:= 40
nColFornece := 46
nColValor	:= 123

Cabec1 := STR0028 	//"Filial  Prefixo  Numero         Parc   Tipo  Fornecedor+Loja+Nome              										  Valor do Titulo"
//"Filial  Prefixo  Numero         Parc   Tipo  Fornecedor+Loja+Nome              										   Valor do Titulo"
//12      123      1234567890123  123    123   12345678901234567890" - "1234" - "1234567890123456789012345678901234567890    99,999,999.99  
//1       9        18             33     40    46                      					  								   123

Cabec2 := ""
If Len(aRelat) > 0
	//Imprime titulos baixados
	DbSelectArea("SA2")
	SA2->(DBSetOrder(1))
	DbSelectArea("FI9")
	FI9->(DBSetOrder(1))

	FI9->(DbSeek(xFilial("FI9") + cIdDarf + "A"))
	While FI9->(!Eof()) .And. FI9->(FI9_FILIAL+FI9_IDDARF +FI9_STATUS ) == xFilial("FI9") + cIdDarf + "A"
		If Li >= 58
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
			Li := Prow()+1
		EndIf
		
		SA2->(DBSeek(xFilial("SA2") + FI9->FI9_FORNEC+FI9->FI9_LOJA))
		If !Empty( cFilFwFI9 )
			@Li,001 		PSAY FI9->FI9_FILIAL //aRelat[nA][2]
		EndIf	
		@Li,nColPrefixo	PSAY FI9->FI9_PREFIX //aRelat[nA][3]
		@Li,nColNumero	PSAY FI9->FI9_NUM //aRelat[nA][4]
		@Li,nColParcela	PSAY FI9->FI9_PARCEL //aRelat[nA][5]
		@Li,nColTipo	PSAY FI9->FI9_TIPO //aRelat[nA][6]
		@Li,nColFornece	PSAY FI9->FI9_FORNEC +" - "+FI9->FI9_LOJA +" - " + SA2->A2_NOME
		@Li,nColValor	PSAY FI9->FI9_VALOR Picture "@e 99,999,999.99" //aRelat[nA][7]
		nSubTot += FI9->FI9_VALOR //aRelat[nA][7]
		Li++
		FI9->(DBSkip())
	EndDo
	If Li >= 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
		Li := Prow()+1
	EndIf
	Li ++
	@Li,001					PSAY STR0029 +" -->> " //"Valor Total "
	@Li,nColValor			PSAY nSubTot		Picture "@e 99,999,999.99"

	Li +=2
 	@ Li,000 PSAY __PrtThinLine()
	Li += 2

	Roda(CbCont,CbTxt,Tamanho)
Endif

If aReturn[5] = 1
	Set Printer To
	DbCommitAll()
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return(Nil)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � FA373Canc � Autor � Adrianne Furtado     � Data �14.07.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cancelamento de Darf.                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FA373Canc()
Local aSize := {}
Local oDlg
Local cIdDarf := Space(20)
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de baixas								  �
//����������������������������������������������������������������
Local cTitulo := OemToAnsi(STR0030) //"DARF - Cancelamento"
Local aButtons := {}
Local lF373CAN := ExistBlock("F373CAN")

Private oGet
Private oSayFor
Private oValTot	:= 0
Private aHeader	:= {}
Private aCols		:= {}
Private nValTot  := 0

AADD(aButtons,{"PMSCOLOR", {|| Fa373Legen(FI9->(RECNO()))}, STR0035 ,STR0035 }) //"Legenda"###"Legenda"
aSize := MsAdvSize(,.F.,400)
DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDLg:lMaximized := .T.

	oPanel1 := TPanel():New(0,0,'',oDlg, oDlg:oFont,.T.,,,,,45,.T.,.T. )  // altura 45

	oPanel1:Align := CONTROL_ALIGN_TOP

	oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,20,20,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	@	003,010 TO 040,145 OF oPanel1 Pixel
	@	003,147 TO 040,500 OF oPanel1 Pixel

	@	015,015 Say STR0008 Of oPanel1 Pixel   //"DARF"
	If lF373CAN
		@   015,038	MSGET oGet1 VAR cIdDarf :=(Execblock("F373CAN",.f.,.f.))SIZE 68,10 Picture "@!" OF oPanel1 PIXEL
	EndIf
	@   015,038	MSGET oGet1 VAR cIdDarf SIZE 68,10 Picture "@!" OF oPanel1 PIXEL

DEFINE SBUTTON FROM 015,110	TYPE 1 ACTION (If(!Empty(cIdDarf), nOpca:=F73SlDarf(oDlg,1,@cIdDarf,oPanel1,oPanel2),;
																nOpca:=0)) ENABLE OF oPanel1

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If( valtype(oget)=="O",if(oGet:TudoOk() .And. Len(aCols) > 0,If(FA373Del(cIdDarf),oDlg:End(),nOpca := 0),nOpca := 0), nOpca := 0)},{||oDlg:End()},,aButtons)

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA373Legen � Autor � Adrianne Furtado     � Data � 14.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA373                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FA373Legen(nReg)
Local uRetorno := .T.
Local aLegenda := {}

aLegenda := {	{"BR_VERDE", 	STR0033	},; //"Ativo"
		   		{"BR_VERMELHO", 	STR0034	}} //"Baixado"

If nReg = Nil	// Chamada direta da funcao
	dbSelectArea("FI9")
	uRetorno := {}
	Aadd(uRetorno,{ 'FI9_STATUS == "A"' , "BR_VERDE" }) // "Ativo"
	Aadd(uRetorno,{ 'FI9_STATUS == "B"' , "BR_VERMELHO"})	// "Baixado"
Else
	BrwLegenda(OemToAnsi(STR0031),STR0035,aLegenda) //"Legenda"
Endif

Return uRetorno

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FA373Del � Autor � Adrianne Furtado      � Data � 14.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FA373Del                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FA373Del(cidDarf)
Local cRet
Local lTemBx := .F.
Local nI
Local aRecno  := {}
Local nIniFLj
Local nTamFLj
Local cAliasSE2 := ""
Local cQuery	:= ""
Local lFI9_FILORI	:= FI9->(FieldPos("FI9_FILORI")) > 0
Local cSeekFil		:= ""

nIniFLj := TamSx3("E2_PREFIXO")[1] + TamSx3("E2_NUM")[1] + TamSx3("E2_PARCELA")[1] + TamSx3("E2_TIPO")[1] + 1
nTamFLj := TamSx3("E2_FORNECE")[1] + TamSx3("E2_LOJA")[1]

DbSelectArea("FI9")
DbSetOrder(1)
DbSeek(xFilial("FI9")+cIdDArf)
While !Eof() .and. FI9->(FI9_FILIAL + FI9_IDDARF) == xFilial("FI9")+cIdDarf .and. !lTemBx
	If FI9->FI9_STATUS = "B"
		lTemBx := .T.
	End
	DbSkip()
EndDo

If lTemBx
	//"A DARF Nr. " ### " possui t�tulos que j� foram baixados. Nao ser� poss�vel apagar."
	Aviso (STR0019,STR0036 + cIdDarf+ STR0037,{STR0007}) //"Ok"
EndIf

//"A DARF Nr. " ### " ser� completamente apagada. deseja continuar?" "Sim" "N�o"
If !lTemBx .and. Aviso (STR0019,STR0036 + cIdDarf+STR0038,{STR0039,STR0040}) == 1
	FI9->(DbSeek(xFilial("FI9")+cIdDArf))
    SE2->(DbSetOrder(1))
	
	// Tratamento para cancelamento de DARF que possuem titulos de filiais distintas
	cAliasSE2 := GetNextAlias()
			
	cQuery := "SELECT E2_FILIAL "
	cQuery += "FROM "+RetSqlName("SE2")+" SE2 "
	cQuery += "WHERE "
	cQuery += "SE2.E2_IDDARF = '"+FI9->FI9_IDDARF+"' AND "				
	cQuery += "SE2.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SE2->(IndexKey()))
			
	cQuery := ChangeQuery(cQuery)
			
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSE2,.F.,.T.)

	//Posiciono nos registros do SE2 e apago o IDDarf
	While !Eof() .and. FI9->(FI9_FILIAL +FI9_IDDARF) == xFilial("FI9")+cIdDarf
	
		If lFI9_FILORI .And. !Empty(FI9->FI9_FILORI)
		 	cSeekFil := xFilial("SE2",FI9->FI9_FILORI)
		Else
		 	cSeekFil :=  xFilial("SE2")
		EndIf
			
		If !SE2->(DbSeek(cSeekFil+FI9->(FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO)))
		
			// Se nao encontrou registro pela xFilial, procura em outras filiais
			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbGoTop())
			While (cAliasSE2)->( ! Eof() )
				If SE2->(DbSeek((cAliasSE2)->E2_FILIAL+FI9->(FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO)))
					Exit
				Else
					(cAliasSE2)->(dbSkip())
				EndIf
			EndDo
		EndIf
		If !Empty(SE2->E2_TITPAI)
			While FI9->(FI9_FORNECE+FI9_LOJA) <> SubStr(SE2->E2_TITPAI,nIniFLj,nTamFLj)
				SE2->(DbSkip())
			EndDo
		EndIf
		RecLock( "SE2", .F. )
		SE2->E2_IDDARF	:= ""
		MsUnlock()
		Aadd(aRecno, FI9->(Recno()))
		FI9->(DbSkip())
	EndDo
	//Posiciono nos registros do FI9 e apago-os
	For nI := 1 To Len(aRecno)
		FI9->(DbGoTo(aRecno[nI]))
		RecLock( "FI9", .F. )
		DbDelete()
		DbCommit()
		MsUnlock()
	Next nI
	cRet := .T.
	Aviso (STR0019,STR0041,{STR0007}) //"Registros apagados com sucesso."		"Ok"
	(cAliasSE2)->(DbCloseArea())
	MsErase(cAliasSE2)
Else
	cRet := .F.
EndIf

Return cRet


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FA373Del � Autor � Adrianne Furtado      � Data � 15.07.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava status de baixado "B" no registro FI9                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FA373Del                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FA373Bx(lBaixa)
// lBaixa = .T. -> est� baixando o t�tulo
// lBaixa = .F. -> est� cancelando a baixa do t�tulo

// SE2 est� posicionado

Local cChave  		:= ""
Local cParcela		:= ""
Local cSeek         := ""
Local cCPOPARC 		:= ""
Local cOrigens 		:= ""
Local cFilterSE2 	:= SE2->(DbFilter())
Local nIniFLj		:= 0
Local nTamFLj		:= 0
Local aArea			:= {}
Local lAglut 		:= (Alltrim(SE2->E2_ORIGEM)=="FINA376")  //CASO SEJA TITULO AGLUTINADO
Local lFINTPDARF	:= ExistBlock("FINTPDARF")
Local lFI9_FILORI	:= FI9->(FieldPos("FI9_FILORI")) > 0
Local cFilSeek		:= If(lFI9_FILORI, SE2->E2_FILORIG, xFilial("FI9") )
Local nOrder		:= 3 
Local lAchou		:= .F.

If AllTrim(SE2->E2_IDDARF) <> ""
	aArea := SE2->(GetArea())
	cChave += SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
	cSeek := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM)
	
	nIniFLj := TamSx3("E2_PREFIXO")[1] + TamSx3("E2_NUM")[1] + TamSx3("E2_PARCELA")[1] + TamSx3("E2_TIPO")[1] + 1
	nTamFLj := TamSx3("E2_FORNECE")[1] + TamSx3("E2_LOJA")[1]

	If !Empty(SE2->E2_TITPAI)
		cChave := SubStr(SE2->E2_TITPAI,nIniFLj, nTamFLj) + cChave
	Else
		//PIS. COFINS. CSLL. IR.
		If AllTrim(SE2->E2_NATUREZ) = SuperGetMV( "MV_PISNAT" )
			cCpoParc := "E2_PARCPIS"
		ElseIf AllTrim(SE2->E2_NATUREZ) = SuperGetMV( "MV_COFINS" )
			cCpoParc := "E2_PARCCOF"
		ElseIf AllTrim(SE2->E2_NATUREZ) = SuperGetMV( "MV_CSLL" )
		    cCpoParc := "E2_PARCSLL"
		ElseIf AllTrim(SE2->E2_NATUREZ) = &( SuperGetMV( "MV_IRF" ) )
			cCpoParc := "E2_PARCIR"
		EndIf
		cParcela := SE2->E2_PARCELA

		SE2->(DbClearFilter())

		If lFINTPDARF
			cOrigens := Execblock("FINTPDARF",.f.,.f.)
		Endif

		SE2->(DBSetOrder(1))
		SE2->(DBSeek(cSeek))
		cChave := SE2->(E2_FORNECE+E2_LOJA) + cChave

		If !( Empty( SE2->E2_TITPAI ) .and. ( ("GPE" $ SE2->E2_ORIGEM ) .OR. (lFINTPDARF .and. SE2->E2_ORIGEM $ cOrigens)) ) .OR. Alltrim(SE2->E2_ORIGEM)=="FINA376"

			While !SE2->(Eof()) .and. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == cSeek .and. SE2->(&cCpoParc) <> cParcela .AND. !lAglut
				lAglut := (Alltrim(SE2->E2_ORIGEM)=="FINA376")  //CASO SEJA TITULO AGLUTINADO
				SE2->(DbSkip())
			EndDo
		Endif

		DbSelectArea("SE2")
		If !Empty(cFilterSE2)
			Set Filter To &cFilterSE2
		Endif

	EndIf
	DbSelectArea("FI9")
	
	If lFI9_FILORI
		nOrder	:= 4 //FI9_FILORI+FI9_FORNEC+FI9_LOJA+FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO
	Else
		nOrder	:= 3 //FI9_FILIAL+FI9_FORNEC+FI9_LOJA+FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO
	EndIf
	
	FI9->(DbSetOrder(nOrder)) 
	If FI9->(DBSeek(cFilSeek+cChave))
		lAchou 	:= .T.
	Else
		FI9->(DbSetOrder(3)) //FI9_FILIAL+FI9_FORNEC+FI9_LOJA+FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO
		If FI9->(DBSeek(xFilial("FI9")+cChave))
			lAchou	:= .T.
		EndIf
	EndIf
	
	If lAchou
		RecLock( "FI9", .F. )
		If lBaixa
			FI9->FI9_STATUS := "B"
		Else
			FI9->FI9_STATUS := "A"
		EndIf
		MsUnlock()
	Endif

	RestArea(aArea)
EndIf

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � F373FORN � Autor � Leonardo Castro       � Data � 14.10.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Posiciona FI9 no registro selecionado no aCols             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � F373FORN                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/    
Function F373FORN(oSayFor)
Local nAT       := oGet:oBrowse:nAT
Local lGestao   := FWSizeFilial() > 2 // Indica se usa Gestao Corporativa
Local cFilFwFI9 := IIF( lGestao , FwFilial("FI9") , xFilial( "FI9" ) )
Local cChave    := ""

If Empty( cFilFwFI9 )
	cChave := aCols[nAT,6] + (aCols[nAT,7]) + aCols[nAT,2] + aCols[nAT,3] + aCols[nAT,4] + aCols[nAT,5] 
Else
	cChave := aCols[nAT,7] + (aCols[nAT,8]) + aCols[nAT,3] + aCols[nAT,4] + aCols[nAT,5] + aCols[nAT,6]
EndIf

//Posiciona no FI9 o registro selecionado na GetDados
FI9->(DbSetOrder(3))
FI9->(DbSeek(xFilial("FI9")+ cChave )) 
SA2->(DBSetOrder(1))
SA2->(DbSeek(xFilial("SA2")+FI9->(FI9_FORNEC+FI9_LOJA )))

oSayFor:Refresh()
oSayFor:CtrlRefresh()

Return Nil
