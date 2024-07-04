#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "GPER640.CH"


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �GPER640   �Autor  �Silvia Taguti  	  � Data �  04/09/03    ���
���������������������������������������������������������������������������͹��
���Desc.     �Gera o arquivo de MTSS                                        ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Planilla - Uruguai                                           ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���Luiz Gustavo|26/01/2007�116748�Retiradas funcoes de ajuste de dicionario.|��  
���Silvia      |17/04/2007�123999�Acerto na busca de Trasferencia           |��  
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Programador  � Data     � FNC            �  Motivo da Alteracao                      ���
���������������������������������������������������������������������������������������ĳ��
���Rogerio R.   �29/07/2009�00000018278/2009�Compatibilizacao dos fontes para aumento do���
���             �          �                �campo filial e gest�o corporativa.         ���
���Alex         �05/11/2009�00000026596/2009�Adapta��o Gest�o Corporativa               ���
���             �          �                �Respeitar o grupo de campos de filiais.    ���
���Alex         �17/03/2010�00000004209/2010�Alterado o cCodigo passado como parametro  ���
���             �          �                �no FPHist82, considerando o RhTamFilial()  ���
���             �          �                �Verificado tambem os DbSeeks com Filiais.  ���
���Emerson Camp �08/03/2012�00000004153/2012�Implementado um ajustaSx1 para remover a   ���
���             �          �          TEOGYB�validacao de naovazio para os campos:      ���
���             �          �                �"De Filial?", "De CC?" e "De Matricula?"   ���
���LuisEnr�quez �25/01/2017�SERINN001-872   �Se realiza merge de 12.1.15 para:          ���
���             �          �                �-Se elimina funci�n AjustaSX1.             ���
���             �          �                �-Se realiz� modificiaci�n de creaci�n de   ���
���             �          �                � tablas temporales para utilizar la clase  ���
���             �          �                � FWTemporaryTable.                         ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Function GPER640()

	Private NomeProg 	:= "GPER640"
	Private WnRel		:=	"GPER640"    //Nome Default do relatorio em Disco
	Private cPerg    	:= "GPR640"
	Private Titulo		:= FunDesc()
	Private oTmpTable := Nil

	/*��������������������������������������������������������������Ŀ
	� Variaveis utilizadas para parametros                         �
	� mv_par01        //  Filial De                                �
	� mv_par02        //  Filial Ate                               �
	� mv_par03        //  Centro de Custo De                       �
	� mv_par04        //  Centro de Custo Ate                      �
	� mv_par05        //  Matricula De                             �
	� mv_par06        //  Matricula Ate                            �
	� mv_par07        //  Nome De                                  �
	� mv_par08        //  Nome Ate                                 �
	� mv_par09        //  Chapa De                                 �
	� mv_par10        //  Chapa Ate                                �
	� mv_par11        //  Situa��es                                �
	� mv_par12        //  Categorias                               � 
	� mv_par13        //  Periodo que desejado do relatorio.       �
	� mv_par14        //  Numero de Documento						 �
	� mv_par15        //  Centraliza Filiais  					 �
	� mv_par16        //  Filial Centra       					 �
	� mv_par17        //  Causa da Apresentacao					 �
	����������������������������������������������������������������*/

	If Pergunte("GPR640",.T.)
		RptStatus({|lEnd| GPER640Imp(@lEnd,wnRel,"SRA")},Titulo)
	EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER640Imp   �Autor �  Silvia Taguti       �Data� 04/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a impressao do Relatorio.                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function GPER640Imp(lEnd,wnRel,cAlias)

	Local nArquivo			:= 00
	Local cInicio  		:= ""
	Local cFim				:= ""
	Local cArqGravar 		:= ""
	Local cSitFunc			:= ""
	Local cFilialAnt 		:= Space(FWGETTAMFILIAL)
	Local cMatAnt    		:= Space(6)
	Local aCodFol			:= {}
	Local	lPerNome 		:= .T.		
	Local nIdade      	:= 0 
	Local cTpModif       
	Local cArqMov := cAliasMov := ""
	Local aOrdBag    := {}

	Private aInfoFil			:= {}
	Private nOrdinal  	:= 1
	Private cArqNome
	Private nHombr			:= 0
	Private nMujer      	:= 0
	Private cCodMod      := " "
	Private nMenor			:=0
	Private Reg01      	:=Array(27)
	Private aTotais      := {}
	Private aEmpresa	:= {}
	Private dDtModi := ctod("")
	Private cTurno
	Private aReg05  := {}
	Private dDtPesq		:= Ctod("")
	Private nNumFunc := 0
	Private aModSal  := {}
	Private aGeraReg3 := {}
	Private aPosicao 	:= {} 							//-- Armazena posicao do funcionario no Mes referencia ( qdo tem transferencia) 
	Private aAux_posicao:= {} 							//-- Armazena as Emp/filiais/mat/cc por onde o funcionario ja passou e que ja foram analisadas 
	Private nTipoCaged	:= 1
	Private cAliasSRA:= "SRA"

	cFilDe    		:= mv_par01
	cFilAte   		:= mv_par02
	cCcDe     		:= mv_par03
	cCcAte    		:= mv_par04
	cMatDe    		:= mv_par05
	cMatAte   		:= mv_par06
	cNomeDe   		:= mv_par07
	cNomeAte  		:= mv_par08
	cChapaDe  		:= mv_par09
	cChapaAte 		:= mv_par10
	cSituacao 		:= mv_par11
	cCategoria		:= mv_par12
	cPeriodo   		:= mv_par13
	nDocumento		:= mv_par14
	lCentraliza  	:= If( mv_par15 == 1 , .T. , .F. )
	cFilCentral    := mv_par16      //Se for centralizado os dados para o cabec seram dessa filial
	//lCompleto    	:= If( mv_par17 == 1 , .T. , .F. )
	cCausa         := mv_par17

	//Se nao for centralizado, soh e gerado o relatorio de uma filial
	If !lCentraliza .And. !Empty(cFilDe) 
		cFilAte := cFilDe
	Endif

	If Empty(cArqGravar) .And.	lPerNome 
		cArqGravar := cGetFile(STR0001,OemToAnsi(STR0002),,"C:\",.T.,GETF_LOCALHARD) //"Arquivo Texto|*.TXT"###"Salvar Pesquisa..."
		nArquivo := fOpen(cArqGravar,1)
		If nArquivo == -1 .And. !Empty(cArqGravar)
			nArquivo := fCreate(cArqGravar)
		Else
			lPerNome := .F.		
		Endif
	EndIf

	//�������������������������������������������������������������������������Ŀ
	//� Cria o arquivo DBF temporiario para geracao do arquivo texto			�
	//���������������������������������������������������������������������������
	cArqNome := "MTSS.DBF"
	cArqNome := RetArq( __LocalDriver, cArqNome, .t. )
	Gp640Cria( cArqNome )		

	dbSelectArea( "SRA" )
	dbSetOrder( 1 )

	dbGoTop()
	dbSeek(cFilDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim    := cFilAte + cMatAte

	SetRegua(SRA->(RecCount()))

	cFilialAnt 	:= Space(FWGETTAMFILIAL)
	cMatAnt    	:= Space(6)

	While !EOF() .And. &cInicio <= cFim .And.(SRA->RA_FILIAL+SRA->RA_MAT <> cFilialAnt+cMatAnt)

		IncRegua()  // Incrementa a regua
		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
		Endif
		/*
		��������������������������������������������������������������������������������Ŀ
		|        Inicio Consistencia da Parametrizacao do Intervalo de Impressao         |
		����������������������������������������������������������������������������������*/
		If (SRA->RA_CHAPA < cChapaDe).Or. (SRA->Ra_CHAPa > cChapaAte).Or. ;
		(SRA->RA_NOME < cNomeDe)  .Or. (SRA->Ra_NOME > cNomeAte)  .Or. ;
		(SRA->RA_MAT < cMatDe)    .Or. (SRA->Ra_MAT > cMatAte)    .Or. ;
		(SRA->RA_CC < cCcDe)      .Or. (SRA->Ra_CC > cCcAte)
			SRA->(dbSkip(1))
			Loop
		EndIf

		//��������������������������������Ŀ
		//� Verifica Data Demissao         �
		//����������������������������������
		cSitFunc := SRA->RA_SITFOLH
		dDtPesq:= CTOD("01/" + Right(cPeriodo,2) +  "/" + Left(cPeriodo,4),"DDMMYY")
		If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. AnoMes(SRA->RA_DEMISSA) > AnoMes(dDtPesq))
			cSitFunc := " "
		Endif
		/*��������������������������������������������������������������Ŀ
		� Consiste situacao e categoria dos funcionarios			        |
		����������������������������������������������������������������*/
		If !( cSitFunc $ cSituacao ) .OR. !( SRA->RA_CATFUNC $ cCategoria )
			SRA->(dbSkip())
			Loop
		Endif

		If AnoMes(SRA->RA_ADMISSA) >= cPeriodo
			SRA->(dbSkip())
			Loop
		EndIf

		If SRA->RA_FILIAL # cFilialAnt
			If ! Fp_CodFol(@aCodFol,Sra->Ra_Filial) .Or.  ! fInfo(@aInfoFil,Sra->Ra_Filial)
				Exit
			Endif
			GeraReg01()             					//Cabecalho do Relatorio
			//Caso o relatorio seja centralizado deve ser gerado o registro tipo 5
			//Gravar os dados das outras filiais
			If lCentraliza .And. SRA->RA_FILIAL <> cFilCentral
				GeraReg05()				
			Endif
			cFilialAnt := SRA->RA_FILIAL
		Endif

		dbSelectArea( "SR6" )
		If dbSeek( xFilial("SR6") + SRA->RA_TNOTRAB)
			cTurno := Padr(SR6->R6_DESC,50)
		Else
			cTurno := Replicate(" ",50)
		Endif

		//	If !lCompleto
		VerAlteracao(cPeriodo,@cCodMod,@dDtModi)
		//	Endif

		If SRA->RA_SEXO $ "1|M"
			nHombr++
		Else
			nMujer++
		Endif
		If !Empty(SRA->RA_NASC)
			nIdade  := Int((ctod("01/"+Right(cPeriodo,2)+"/"+Left(cPeriodo,4)) - SRA->RA_NASC) / 365)
			If nIdade <= 18
				nMenor++
			Endif
		Endif
		GrvMTSS()
		cCodMod := " "
		dDtModi := ctod("")
		dBSelectArea("SRA")
		dbSkip()
	Enddo

	Reg01[25] := Str(nHombr,5)
	Reg01[26] := Str(nMujer,5)
	Reg01[27] := Str(nMenor,5)

	dbSelectArea( "MTSS" )
	If Reccount() = 0
		nOpc := Aviso( STR0004, STR0005, { STR0006 } ) //##"Alerta"##"Nao ha registro de movimentacao no periodo"##"OK"
		fDelMTSS(nArquivo)
		Return Nil
	Endif
	GPEREG01(nArquivo)
	dbgotop()
	While !Eof()
		GPEREG02(nArquivo) 		
		dbSkip()
	Enddo	

	//While !Eof()
	GPEREG03(nArquivo)	
	//	dbSkip()
	//Enddo	
	GPEREG04(nArquivo)
	If lCentraliza
		GPEREG05(nArquivo)
	Endif
	dbSelectArea( "MTSS" ) 

	dbCloseArea()

	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil 
	EndIf

	Fclose( nArquivo)

	dbSelectArea( "SRA" )
	dbSetOrder(1)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GERAREG01 �Autor  �Silvia Taguti       � Data �  09/04/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Geracao do Cabecalho                        ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GERAREG01()
	Local cChave

	If (lCentraliza .And. SRA->RA_FILIAL == cFilCentral) .or. !lCentraliza
		Reg01[01]:= SRA->RA_FILIAL
		Reg01[02]:= Substr(aInfoFil[08],1,12)                 			//RUC
		Reg01[03]:= Padr(aInfoFil[03],50)                          	//Razao Social
		Reg01[04]:= Padr(aInfoFil[04],50)                      			//Endereco
		Reg01[05]:= aInfoFil[06]                                   		//Estado
		Reg01[06]:= Substr(aInfoFil[07],1,6)                    		//Cep
		Reg01[07]:= If(!Empty(aInfoFil[10]),PadR(aInfoFil[10],20),Replicate("X",20)) //Telef
		Reg01[08]:= If(!Empty(aInfoFil[11]),Substr(aInfoFil[11],1,10),Replicate("9",10)) //Fax
		Reg01[09]:= If(!Empty(aInfoFil[20]),Substr(aInfoFil[20],1,2),"99")	//Nat.Juridica
		
		If FpHist82(xFilial("SRX"),"99",SRA->RA_FILIAL+"01") .or. FpHist82(xFilial("SRX"),"99", RhTamFilial(Space(FWGETTAMFILIAL))+"01")
			cChave 	:=	SRX->RX_TIP
			Reg01[10]:= Substr(SRX->RX_TXT,1  ,15)							//Numero de BPS
			Reg01[11]:= Substr(SRX->RX_TXT,16 ,8)        					//Data do BPS
			Reg01[12]:= Val(SubStr(SRX->RX_TXT,24 ,15)) 					// Numero de MTSS
			dbSelectArea( "SRX" )
			If dbSeek(xFilial("SRX") + cChave + SRA->RA_FILIAL+"02" ) .Or. dbSeek(xFilial("SRX")+ cChave + RhTamFilial(Space(FWGETTAMFILIAL)) + "02" )
				Reg01[13]:= Substr(SRX->RX_TXT, 1 , 8)						//Data Inicio Atividades
				Reg01[14]:= Padl(Val(Substr(SRX->RX_TXT, 9 , 4)),4)    //Localidade
				Reg01[15]:= Padl(Val(Substr(SRX->RX_TXT, 13, 5)),5)    //Seccion Policial
				Reg01[16]:= Padl(Val(Substr(SRX->RX_TXT,18, 5)),5)		//Qt.Donos,Socios Homens
				Reg01[17]:= Padl(Val(Substr(SRX->RX_TXT,23, 5)),5)		//Qt.Donas,Socias Mulheres
				Reg01[18]:= Padl(Val(Substr(SRX->RX_TXT,28, 3)),3)   	//Grupo Atividade
				Reg01[19]:= Padl(Val(Substr(SRX->RX_TXT,31, 5)),5)     	//SubGrupo Atividade
				Reg01[20]:= Padl(Val(Substr(SRX->RX_TXT,36, 2)),2)     	//Cod.Conv.Coletiva
				Reg01[21]:= Substr(SRX->RX_TXT, 38, 8)                 	//Dt.Venc.Conv.Coletiva
				dbSelectArea( "SRX" )
				If dbSeek(xFilial("SRX") + cChave + SRA->RA_FILIAL+"03" ) .Or. dbSeek(xFilial("SRX")+ cChave + RhTamFilial(Space(FWGETTAMFILIAL))+ "03" )
					Reg01[22]:=Padr(Substr(SRX->RX_TXT,1,50),50)	      //Atividade do Estabelecimento
					dbSelectArea( "SRX" )
					If dbSeek(xFilial("SRX") + cChave + SRA->RA_FILIAL+"04" ) .Or. dbSeek(xFilial("SRX")+ cChave + RhTamFilial(Space(FWGETTAMFILIAL))+ "04" )
						Reg01[23]:= Substr(SRX->RX_TXT,1,25)	 	//e-mail
					Endif
				EndIf
			Endif
		Endif

		dbSelectAreA("SX5")
		If dbSeek(xFilial("SX5")+"OF"+aInfoFil[06])
			Reg01[24] := Padl(Val(Substr(X5DESCRI(),1,4)),4)				//Codigo do Departamento
		Else
			Reg01[24] := "9999"														//Codigo do Departamento
		Endif
	Endif

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEREG01  �Autor  �Microsiga           � Data �  09/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera o arquivo do Texto do Registro 01 - Cabecalho         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GPEREG01(nArquivo)

	Local cCabec                       

	cCabec	:= "1"																//Tipo de Registro
	cCabec 	+= IIf(Reg01[12] <> Nil,Str(Reg01[12],15),Space(15))		//Numero de MTSS		
	cCabec 	+= StrZero(nDocumento,4)									 	//Numero de Documento
	cCabec 	+= padl(Val(Reg01[01]),3)						        		//Ordinal
	cCabec 	+= If(Reg01[13] == Nil,"       0", If(!Empty(stod(Reg01[13])),Reg01[13],"       0")) 	//Data Inicio Atividades
	cCabec 	+= If(Reg01[11] == Nil,"       0", If(!Empty(stod(Reg01[11])),Reg01[11],"       0"))  //Dta do BPS
	cCabec	+= Reg01[10]														//Numero de BPS 
	cCabec	+= Reg01[02]														//RUC
	cCabec 	+= Reg01[03]														//Razao Social
	cCabec	+= Reg01[04]														//Endereco
	cCabec	+= Reg01[06]														//Codigo Postal
	cCabec	+= Reg01[24]               	            				//Codigo de Departamento
	cCabec	+= Reg01[14]												      //Codigo de Localidad
	cCabec	+= Reg01[15]														//Seccion Policial
	cCabec	+= Reg01[07]														//Telefone 
	cCabec	+= Reg01[08]														//Fax
	cCabec	+= Reg01[09]														//Cod.Natureza Juridica
	cCabec	+= Reg01[16]														//Qt.Donos,Socios Homens
	cCabec	+= Reg01[17]														//Qt.Donas,Socias Mulheres
	cCabec	+= Reg01[25]	                                   		//Personal Pendiente Hombre
	cCabec	+= Reg01[26]   	                            			//Personal Pendiente Mujer
	cCabec	+= Reg01[25]      	                          			//Personal Registrado Hombre
	cCabec	+= Reg01[26]         	                       			//Personal Registrado Mujer
	cCabec	+= Reg01[22]														//Atividade Estabelecimento
	cCabec	+= Reg01[18]               	               			//Codigo de Grupo de Ativid.
	cCabec	+= Reg01[19]  		            	                		//Codigo de Subgrupo de Ativid.
	cCabec	+= Reg01[20]														//Codigo de Convenios Coletivos
	cCabec	+= If(!Empty(stod(Reg01[21])),Reg01[21],"       0")	//Dt Venc.Conv.Coletivo
	cCabec	+= Reg01[27]									      			//Qt.de Menores
	cCabec	+= Replicate("0",14)		       								//Filler1
	cCabec	+= Replicate("0",52)   	               					//Filler2
	cCabec	+= Reg01[23]            		                			//e-mail
	cCabec	+= If(lCentraliza,"S","N")	                        	//Centralizacao de Filiais
	cCabec	+= "0"                     	            				//Filler3
	cCabec	+= cCausa                     	           				//Causa da Apresentacao 

	If !GRAVA( cCabec,nArquivo )
		Return .f.
	Endif
 
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp640Cria � Autor � Silvia Taguti         � Data � 05/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria arquivo temporario de trabalho do MTSS 				     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp640Cria( cArqNome )						              		  ���
�������������������������������������������������������������������������Ĵ��
���Par�metros� cArqNome - Nome do arquivo que sera criado				     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Gp640Cria( cArqNome )
	Local aStru := {}
	Local aOrdem := {}

	aStru 	:= { 	{ "MTS_FILIAL", "C", FWGETTAMFILIAL, 00 }, ;
	{ "MTS_MAT"   , "C", 006, 00 }, ;
	{ "MTS_NUM"   , "N", 006, 00 }, ;
	{ "MTS_RG"    , "C", 015, 00 }, ;
	{ "MTS_APELLI", "C", 020, 00 }, ;
	{ "MTS_NOMBRE", "C", 020, 00 }, ;
	{ "MTS_SEXO"  , "C", 001, 00 }, ;
	{ "MTS_DTNASC", "C", 008, 00 }, ;
	{ "MTS_DTADMI", "C", 008, 00 }, ;
	{ "MTS_CODMOD", "C", 002, 00 }, ;
	{ "MTS_CATEG" , "C", 020, 00 }, ;
	{ "MTS_HORAR" , "C", 050, 00 }, ;
	{ "MTS_CODPAI", "C", 005, 00 }, ;
	{ "MTS_DTMOD" , "C", 008, 00 }, ;
	{ "MTS_TPREM" , "C", 003, 00 }, ;
	{ "MTS_REMUNE", "N", 013, 02 }}
	
	oTmpTable := FWTemporaryTable():New("MTSS")
	oTmpTable:SetFields( aStru )
	aOrdem	:=	{"MTS_FILIAL","MTS_MAT"}  
	oTmpTable:AddIndex("IN1", aOrdem)
	oTmpTable:Create()
Return Nil     

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GrvMTSS  � Autor � Silvia Taguti         � Data � 09/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava dados no arquivo MTSS                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GrvMTSS(cTipoMov)							                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GrvMTSS()

	Local cSexo 
	Local cCodRem

	cSexo := If(SRA->RA_SEXO $ "1|M","M","F")

	If SRA->RA_CATFUNC == "M"
		cCodRem := "M  "
	ElseIf SRA->RA_CATFUNC == "H"
		cCodRem := "H  "
	ElseIf SRA->RA_CATFUNC == "D"
		cCodRem := "D  "
	ElseIf SRA->RA_CATFUNC == "C"
		cCodRem := "AC "	
	Endif			
	nNumFunc += 1 

	dbSelectArea( "MTSS" )
	RecLock( "MTSS", .T. )

	Replace	MTS_FILIAL	With 	SRA->RA_FILIAL
	Replace	MTS_MAT   	With 	SRA->RA_MAT  
	Replace	MTS_NUM   	With  nNumFunc
	Replace	MTS_RG    	With  SRA->RA_RG
	Replace	MTS_APELLI	With  SRA->RA_PRISOBR
	Replace	MTS_NOMBRE	With  SRA->RA_PRINOME
	Replace	MTS_SEXO  	With  cSexo
	Replace	MTS_DTNASC	With  Dtos(SRA->RA_NASC)
	Replace	MTS_DTADMI	With	Dtos(SRA->RA_ADMISSA)
	Replace	MTS_CODMOD	With  cCodMod
	Replace	MTS_CATEG	With  Substr(DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL),1,20)
	Replace	MTS_HORAR 	With  cTurno
	Replace	MTS_CODPAI	With  Str(Val(SRA->RA_CODPAIS),5)
	Replace	MTS_DTMOD 	With  Dtos(dDtModi)
	Replace  MTS_TPREM   With  cCodRem
	Replace  MTS_REMUNE  With  SRA->RA_SALARIO            
	MsUnlock()
Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEREG02     �Autor �  Silvia Taguti       �Data� 04/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a geracao do Arquivo de Texto Registro 02- Funcionarios���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GPEREG02(nArquivo)

	Local cLinha		:= ""
	Local nX 	:= 0
	cLinha	:= "2"
	cLinha 	+= Str(Reg01[12],15)													  	//Numero de MTSS		
	cLinha 	+= StrZero(nDocumento,4)											 	//Numero de Documento
	cLinha 	+= padl(Val(Reg01[01]),3)										      //Ordinal
	cLinha 	+= Padl(MTSS->MTS_NUM,6)										      //Numero del Empleado
	cLinha 	+= MTSS->MTS_RG         		         	                 	//Documento Identidade
	cLinha	+= MTSS->MTS_APELLI	         		      	             	//Primeiro Sobrenome
	cLinha  += MTSS->MTS_NOMBRE                 		   	           	//Primeiro Nome
	cLinha	+= MTSS->MTS_SEXO                         			        	//Sexo
	cLinha	+= MTSS->MTS_DTNASC                             			 	//Data de Nascimento
	cLinha 	+= MTSS->MTS_DTADMI														//Data de Admissao
	cLinha	+=	MTSS->MTS_CODMOD         			                     	//Codigo de Modificacao
	cLinha	+= MTSS->MTS_CATEG                  			              	//Categoria
	cLinha	+= MTSS->MTS_HORAR                           			     	//Horario
	cLinha	+= "0"             			                               	//Filler
	cLinha	+= Replicate("0",14)      			                        	//Filler
	cLinha	+= MTSS->MTS_CODPAI      	     			                  	//Codigo do Pais
	cLinha	+= If(!Empty(MTSS->MTS_DTMOD),MTSS->MTS_DTMOD,"       0") 	//Data de Modificacao
	cLinha	+= Replicate("0",52)                           				  	//Filler

	If !GRAVA( cLinha,nArquivo )
		Return .f.
	Endif
	//Caso nao tenha modificacoes no periodo pegar o salario do cadastro
	If Ascan(aModSal,{ |X| x[1] == MTSS->MTS_FILIAL .and. x[2]== MTSS->MTS_MAT })= 0
		AADD(aModSal,{MTSS->MTS_FILIAL,MTSS->MTS_MAT,dDataBase,MTSS->MTS_REMUNE,1})
	Endif

	For nX := 1 to Len(aModSal)
		If aModSal[nX,1]== MTSS->MTS_FILIAL .And. aModSal[nX,2]== MTSS->MTS_MAT
			AADD(aGeraReg3,{MTSS->MTS_FILIAL,MTSS->MTS_MAT,Padl(MTSS->MTS_NUM,6),MTSS->MTS_TPREM,aModSal[nX,3],aModSal[nX,4],aModSal[nX,5]})
			//Filial, Matricula, Numero,Cod.Remuneracion,Data,Valor
		Endif
	Next   

Return 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEREG03     �Autor �  Silvia Taguti       �Data� 04/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a geracao do Arquivo Texto do Registro 03- Valores Func���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GPEREG03(nArquivo)

	Local cLinha		:= "" 
	Local cSalario
	Local nY

	For nY := 1 to Len(aGeraReg3)
		cSalario := Str(Val(StrTran(Str(aGeraReg3[nY,6],13,2),".","")),13)
		cLinha	:= "3"
		cLinha 	+= Str(Reg01[12],15)				    					  	//Numero de MTSS		
		cLinha 	+= StrZero(nDocumento,4)								 	//Numero de Documento
		cLinha 	+= padl(Val(Reg01[01]),3)						      	//Ordinal
		cLinha 	+= aGeraReg3[nY,3]       							      //Numero del Empleado
		cLinha 	+= padl(aGeraReg3[nY,7],3)								//Ordinal de Remuneracao
		cLinha	+= aGeraReg3[nY,4]              						   //Codigo de Remuneracao
		cLinha   += Dtos(aGeraReg3[nY,5])									//Data de Remuneracao
		cLinha	+= "0"															//Filler1
		cLinha	+= cSalario          						  		      //Valor da Remuneracao
		cLinha 	+= Replicate("0",14)											//Filler2		
		cLinha	+= Replicate("0",52)											//Filler3

		If !GRAVA( cLinha,nArquivo )
			Return .f.
		Endif
	Next

Return 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEREG04     �Autor �  Silvia Taguti       �Data� 17/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a geracao do Arquivo Texto do Registro 04- Observacoes ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GPEREG04(nArquivo)

	Local cLinha		:= ""
	Local aObserv     := {}
	Local nObs 			:= 0
	Local cMatObs      
	Local nPos
	Local nX 			:= 0

	dbSelectArea("SRX")

	If FpHist82(xFilial("SRX"),"98",SRA->RA_FILIAL+cPeriodo) .Or. FpHist82(xFilial("SRX"),"98",RhTamFilial(Space(FWGETTAMFILIAL))+cPeriodo)
		While !Eof() .And. SRX->RX_TIP == "98" .And. Left(SRX->RX_COD,FWGETTAMFILIAL) == SRA->RA_FILIAL;
		.And. cPeriodo==Substr(SRX->RX_COD,3,6) 
			nObs++     
			cMatObs := If(!Empty(Substr(SRX->RX_TXT,1,6)),Substr(SRX->RX_TXT,1,6),"!!!")
			If cMatObs <> "!!!"
				nPos :=Ascan(aGeraReg3,{ |X| X[2]== cMatObs })
				If nPos > 0
					cMatObs := aGeraReg3[nPos,3]
				Endif
			Endif
			AADD(aObserv,{Substr(SRX->RX_COD,09,02),cMatObs,Substr(SRX->RX_TXT,7,53)})
			dbSkip()
		Enddo
	Endif

	For nX := 1 to Len(aObserv)
		cLinha	:= "4"                                             		//Registro
		cLinha 	+= Str(Reg01[12],15)								  					//Numero de MTSS		
		cLinha 	+= StrZero(nDocumento,4)								 			//Numero de Documento
		cLinha 	+= padl(Val(Reg01[01]),3)						      			//Ordinal
		cLinha 	+= Str(Val(aObserv[nX][1]),3)									//Numero de Observacion
		cLinha 	+= PadR(aObserv[nX][3],70)										//Observacion	
		cLinha	+= If(aObserv[nX][2]	== "!!!",Space(06),aObserv[nX][2])	//Empleado Observacion
		cLinha 	+= Replicate("0",52)													//Filler2		
		cLinha	+= Replicate("0",14)													//Filler3

		If !GRAVA( cLinha,nArquivo )
			Return .f.
		Endif
	Next

Return 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GERAREG05 �Autor  �Microsiga           � Data �  12/04/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava dados das filiais quando o relatorio for centralizado���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                       
Function GeraReg05()

	Local nOrdinal := 0
	Local cLocalFil   := Space(4)
	Local cDataIn     := Space(08)
	Local cDataFim    := Space(08)
	Local cCodDep     := ""
	Local cObs        := SPace(70)
	Local cEstado

	If FpHist82(xFilial("SRX"),"99",SRA->RA_FILIAL+"02") .or. FpHist82(xFilial("SRX"),"99",RhTamFilial(Space(FWGETTAMFILIAL))+"02")
		cDataIn  := Substr(SRX->RX_TXT, 1, 8)							//Data Inicio
		cLocalFil:= Padl(Val(Substr(SRX->RX_TXT, 9, 4)),4)                  //Localidade
	Endif
	If FpHist82(xFilial("SRX"),"99",SRA->RA_FILIAL+"04") .or. FpHist82(xFilial("SRX"),"99",RhTamFilial(Space(FWGETTAMFILIAL))+"04")
		cDataFim := Substr(SRX->RX_TXT,36,8)                  //Data Fechamento da Sucursal
	Endif                                   

	dbSelectAreA("SX5")
	If dbSeek(xFilial("SX5")+"OA"+aInfoFil[06])
		cCodDep := Str(Val(Substr(X5DESCRI(),1,4)),4)				//Codigo do Departamento
	Else
		cCodDep := "9999"														//Codigo do Departamento
	Endif
	cEstado := If(Empty(stod(cDataFim)),"A","C") 

	AADD(aReg05,{Str(nOrdinal+1,3),Str(Val(SRA->RA_FILIAL),3),Padr(aInfoFil[04],50),cCodDep,cLocalFil,cObs,cDataIn,cDataFim,cEstado}) 

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEREG05     �Autor �  Silvia Taguti       �Data� 17/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a geracao do Arquivo Texto do Registro 05- Sucursales  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GPEREG05(nArquivo)
	Local cLinha		:= ""
	Local nX := 0

	For nX := 1 to Len(aReg05)
		cLinha	:= "5"                                     	 		 			//Registro
		cLinha 	+= Str(Reg01[12],15)								  						//Numero de MTSS		
		cLinha 	+= StrZero(nDocumento,4)									 			//Numero de Documento
		cLinha 	+= Padr(aReg05[nX][1],3)							      			//Ordinal
		cLinha 	+= Padr(aReg05[nX][2],3)												//Filial
		cLinha	+=	aReg05[nX][3]   		  							  					//Endereco
		cLinha	+=	"999999"             												//Numero o Km
		cLinha	+= aReg05[nX][4]          	         	      	 				//Codigo de Departamento
		cLinha	+= aReg05[nX][5]												     		//Codigo de Localidad
		cLinha 	+= aReg05[nX][6]															//Observacion	
		cLinha 	+= Replicate("0",52)														//Filler1		
		cLinha	+= Replicate("0",14)														//Filler2
		cLinha 	+= If(!Empty(stod(aReg05[nX][7])),aReg05[nX][7],"       0")//Data de Inicio
		cLinha 	+= If(!Empty(stod(aReg05[nX][8])),aReg05[nX][8],"       0")//Data de Fin
		cLinha 	+= aReg05[nX][9]                      	      		      	//Estado : Aberta ou Fechada

		If !GRAVA( cLinha,nArquivo )
			Return .f.
		Endif
		cLinha := ""
	Next
Return 


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � VerAlteracao �Autor �  Silvia Taguti       �Data� 15/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se houve alteracao no salario do funcionario,     ���
���          � Transferencia do Funcionario ou Demissao no Periodo        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function VerAlteracao(cPeriodo,cCodMod,dDtModi)

	Local dDataT    := ctod("")
	Local cDtIni
	Local nModif   := 0
	Local aSituacao := {} 			//-- Armazena a situacao do funcionario no mes referencia, ou seja,  se esta demitido, se foi transferido, etc.

	nMes := Val(Substr(cPeriodo,5,2))-12
	nAno := Val(Substr(cPeriodo,1,4))

	If nMes == 0
		nMes := 1
		nAno := nAno - 1
	Endif
	If nMes < 0
		nMes := 12 - ( nMes * -1 )
		nAno := nAno - 1
	Endif
	cDtIni := StrZero(nAno,4)+StrZero(nMes,2)

	//�����������������������������Ŀ
	//�Verifica alteracao de salario�
	//�������������������������������
	If SR7->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
		While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SR7->R7_FILIAL+SR7->R7_MAT               
			If SRA->RA_FILIAL+SRA->RA_MAT == SR7->R7_FILIAL+SR7->R7_MAT               
				dbSelectArea("SR3")
				dBseek(SR7->R7_FILIAL+SR7->R7_MAT+DTOS(SR7->R7_DATA)+SR7->R7_TIPO)
				While ! Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT = SR3->R3_FILIAL+SR3->R3_MAT .And. ;
				SR3->R3_DATA = SR7->R7_DATA .And. SR7->R7_TIPO = SR3->R3_TIPO
					If AnoMes(SR3->R3_DATA) < cDtIni .or. AnoMes(SR3->R3_DATA) > cPeriodo
						dbSkip()
						Loop
					Endif  
					nModif += 1
					AADD(aModSal,{SRA->RA_FILIAL,SRA->RA_MAT,SR3->R3_DATA,SR3->R3_VALOR,nModif})
					SR3->(dbSkip())
				Enddo	
			Endif	
			SR7->(dbSkip())
			Loop
		EndDo
	EndIf                         
	//������������������������������������������������������
	//�Verifica se o funcionario foi transferido no periodo�
	//������������������������������������������������������
	fVerTran(SRA->RA_FILIAL,SRA->RA_MAT,SRA->RA_CC,ctod("01/"+Right(cPeriodo,2)+"/"+Left(cPeriodo,4),"ddmmyyyy"),aEmpresa,@dDataT,SRA->RA_DEMISSA,@aSituacao)

	//�������������������������������������������������Ŀ
	//�Verifica se o funcionario foi demitido no periodo�
	//���������������������������������������������������
	If AnoMes(SRA->RA_DEMISSA) >= cDtIni .And. AnoMes(SRA->RA_DEMISSA) <= cPeriodo
		cCodMod := "E"
		dDtModi := SRA->RA_DEMISSA
	Endif
	
Return 

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Grava    � Autor � Silvia Taguti      	  � Data � 17/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava registro no arquivo texto	  						        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Grava( cRegistro)          								        ���
�������������������������������������������������������������������������Ĵ��
���Par�metros� 															              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Grava( cRegistro,nArquivo)

	If nArquivo != -1
		fSeek(nArquivo,0,2)
		Fwrite(nArquivo,cRegistro+CHR(13)+CHR(10))
	Endif

Return ( .T. )

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fDelMTSS  � Autor � Silvia Taguti         � Data � 19/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Deleta os arquivos temporarios do MTSS                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fDelMTSS(nArquivo)                                	        ���
�������������������������������������������������������������������������Ĵ��
���Par�metros� 															              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fDelMtss(nArquivo)

	dbSelectArea( "MTSS" )
	dbCloseArea()
	FErase( "MTSS.DBF" )
	FErase( "MTSS.IDX" )
	Fclose( nArquivo )

Return Nil

