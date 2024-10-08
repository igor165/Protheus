#include "protheus.ch"
#include "topconn.ch"
#include "GPEM795.ch"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM795  � Autor � ABEL RIBEIRO            � Data �   29.08.08    ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Gera o arquivo Texto Declaracao de IRS                            ���
���          �                                                  				 ���
��������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                   ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � Portugal                                                          ���
��������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                    ���
��������������������������������������������������������������������������������Ĵ��
���Programador � Data     �   BOPS    �  Motivo da Alteracao                     ���
��������������������������������������������������������������������������������Ĵ��
���Tiago Malta �07/01/2010�00280/2010 �Alterado o conteudo da variavel cFilDe e  ���
���            �          �           �cFilAte para space(FWGETTAMFILIAL).		 ���
���Alex Fagunde�22/12/2010�29463/2010 �Atender Nova Interface Totvs 11.5 utili-  ���
���            �          �           �zando a funcao MsAdvSize.                 ��� 
���Tiago Malta �27/05/2011�29463/2010 � Alterado as posi��es dos objetos usando a���
���            �          �           � fun��o retcoords.                        ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/

Function GPEM795()       
Local cSays		  := OemToAnsi(STR0002)	//"Este programa gera o ficheiro de declara��o IRS  - Modelo 10"
Local oDlg
Local nOpca 	:= 0
Local bBtnCalcule							//bloco do bot�o OK
Local bPergunte								//bloco para o pergunte
Local oBtnCalcule
Local oBtnEnd
Local oBtnPergunte
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aButtons		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local aRetcoords

Private cCadastro := OemToAnsi(STR0001) // "Gera��o Arquivo IRS "   
Private aSays 	  := {}         
Private aLogProc  := {} 
Private cPathFile := ""
Private cExtRel   := ".##R"      
Private cTxtParam := ""
Private oTxtParam
nOpca 			  := 0

Private cFilDe := cFilAte := Space(FWGETTAMFILIAL)

Private cPerg      := Padr("GPEM795",10)
Pergunte("GPEM795",.F.)


DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13 BOLD
cTxtParam := OemToAnsi(Gpem795QbrPar(cPerg))
cBlkGet :=  "{ | u | If( PCount() == 0, cTxtParam,cTxtParam:= u ) }"
cBlKVld :=  "{|| .T. }"
cBlKWhen := "{|| .F. }"

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/

aAdvSize		:= MsAdvSize()  
aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 75	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aRetcoords      := RetCoords(1,4,0,15,1,0,,,aAdvSize)

DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0001 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // "Gera��o Arquivo IRS "
	/*/
	��������������������������������������������������������������������������Ŀ
	� Descricao da Janela                                                      �
	���������������������������������������������������������������������������� */
	@ aObjSize[1][1]+5 , aObjSize[1][2]+5 TO oDlg:nBottom*0.37,oDlg:nRight*0.49 OF oDlg PIXEL  //@ 11,12 TO 100,245 OF oDlg PIXEL
	@ aRetcoords[1][1] , aRetcoords[1][2] SAY cSays Of oDlg Pixel  FONT oFont1 // "Este programa gera o arquivo texto do Quadro de Pessoal"
	@ aRetcoords[2][1] , aRetcoords[2][2] SAY STR0011 Of oDlg Pixel FONT oFont1 // "Parametros:"
	oTxtParam := TMultiGet():New(aRetcoords[3][1] , aRetcoords[3][2],&cBlKGet,oDlg,200,50,,.F.,,,,.T.,,.F.,&(cBlkWhen),.F.,.F.,.F.,&(cBlkVld),,.F.,.F.,.T.)

	/*/
	��������������������������������������������������������������������������Ŀ
	� Funcoes em GpFiltro  - Blocos de Execucao dos filtros                    �
	� GpFiltro - Chama a janela principal do cadastro de filtros               �
	� GpFltAlsGet - Retorna a expressao para elaborar o filtro                 �
	����������������������������������������������������������������������������*/
	AADD(aButtons, {"LogOcorr" ,{ || GPM795Log() },STR0014,STR0014} )
	AADD(aButtons, {"Parametros" ,{ || Pergunte("GPEM795",.T.), cTxtParam := OemToAnsi(Gpem795QbrPar(cPerg)), oTxtParam:Refresh() },STR0016,STR0016} )
	
	bSet15		:= { || nOpca := 1, IF( GPM795Ok()( ),oDlg:End(), nOpca:=0 ) }
	bSet24		:= { || oDlg:End() }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons )


//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01 - Filial de                                         �
//� mv_par02 - Filial Ate                                        �
//� mv_par03 - Ano Exercicio                                     �
//� mv_par04 - Perc. de Volume de Negocios                       �
//� mv_par05 - Codigo Tabela de Atividades                       �
//� mv_par06 - Codigo Tabela Finan�as                            �
//� mv_par07 - Tipo de Declara��o                                �
//� mv_par08 - Taxas Liberatorias                                �
//� mv_par09 - Compensa��es IRS/IRC                              �
//� mv_par10 - Nome do Arquivo                                   �
//� mv_par11 - Local do Arquivo de Saida                         �
//� mv_par12 - NIF do Representante Legal                        �
//� mv_par13 - NIF do Tecnico Oficial de Contas                  �
//� mv_par14 - Data do fato Gerador                              �
//  mv_par15 - Vers�o do Arquivo                                 *
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Carrega variaveis mv_par99 para variaveis do sistema      	 �
//����������������������������������������������������������������  
IF nOpca == 1                                                                                                                                   

cFilIni       := mv_par01                   // Filial Inicial
cFilFim       := mv_par02                   // FIlial Final
cAno          := STR(MV_PAR03,4)            // Ano Exercicio
nPercVolNeg   := mv_par04                   // Perc. de Volume de Negocios
cCodTabAtiv   := mv_par05                   // Codigo Tabela de Atividades
cCodServFIna  := mv_par06                   // Codigo Tabela Finan�as
cTiPODecl	  := STR(MV_PAR07,1)            // Tipo de Declara��o
nTaxLibera	  := mv_par08                   // Taxas Liberatorias
nCompIRSIRC	  := mv_par09                   // Compensa��es IRS/IRC                                                        

cNIFRepres	  := mv_par12                   // NIF do Representante Legal                                                       
cNIFTecnico   := mv_par13                   // NIF do Tecnico Oficial de Contas  
cDtFatoGer    := mv_par14                   //Data do fato Gerador no Formato  AAAAMMDD
cVersao       := Strzero(mv_par15,2,0)      // Vers�o do Arquivo

cIdFiscal     := SUBSTR(SM0->M0_CGC,1,9)    //NIF do Sujeito Passivo
cCNAE         := Substr(SM0->M0_CNAE,1,5)   //Codigo CNAE
nRetIRC       := 0                          //Reten��es de IRC

	Processa({|lEnd| GPM795Proc(@lEnd),oemtoansi(STR0003)})    // Chamada do Processamento
Endif

Return Nil          
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPM795Proc� Autor � Abel Ribeiro	          � Data �   28.08.08    ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao do Arquivo TXT do IRS  	                                 ���
��������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                   ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � Portugal                                                          ���
��������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                    ���
��������������������������������������������������������������������������������Ĵ��
���Programador � Data     �   BOPS    �  Motivo da Alteracao                     ���
��������������������������������������������������������������������������������Ĵ��
���            �          �           �											 ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Static Function GPM795Proc(lEnd)
//==================================================================================================================
//Variaveis para tratamento via SQL
//==================================================================================================================
Local cQuery    := "" 
Local aRegFunc  :={}
Local nX        := 0   
Local nCont
Private cEOL    := CHR(13)+CHR(10)

//==================================================================================================================
//Variaveis para tratamento via LOG
//==================================================================================================================
Private cNomArq,nHdlArq
Private aInfo 	:= {}
Private aLog	:= {}
Private aTitle	:= {}
Private aTotRegs:= array(10) 
Private lTemArq         := .F.
//=================================================================================================================
//Variaveis totais Tipo A
Private nTotVlRenA     := 0					   //Valor Total do Rendimento
Private nTotVlRetA     := 0                    //Valor Total Retido
Private nTOTDescObrA   := 0                    //Valor Total Descontos Obrigatorios
Private nTOTQuotSindA  := 0                    //Valor Total Quotiza�oes Sindicais
Private nTotRendAntA   := 0                    //Valor Total rendimentos Anos Anteriores
			
//=================================================================================================================
//Variaveis totais Tipo B
Private nTotVlRenB    := 0	 		  		   //Valor Total do Rendimento
Private nTotVlRetB    := 0                     //Valor Total Retido
Private nTOTDescObrB  := 0                     //Valor Total Descontos Obrigatorios
Private nTOTQuotSindB := 0                     //Valor Total Quotiza�oes Sindicais

//=================================================================================================================
//Variaveis totais Tipo E
Private nTotVlRenE    := 0					   //Valor Total do Rendimento
Private nTotVlRetE    := 0                     //Valor Total Retido
Private nTOTDescObrE  := 0                     //Valor Total Descontos Obrigatorios
Private nTOTQuotSindE := 0                     //Valor Total Quotiza�oes Sindicais
//=================================================================================================================
//Variaveis totais Tipo EE
Private nTotVlRenEE    := 0                    //Valor Total do Rendimento
Private nTotVlRetEE    := 0                    //Valor Total Retido
Private nTOTDescObrEE  := 0                    //Valor Total Descontos Obrigatorios
Private nTOTQuotSindEE := 0                    //Valor Total Quotiza�oes Sindicais
//=================================================================================================================
//Variaveis totais Tipo F
Private nTotVlRenF    := 0                     //Valor Total do Rendimento
Private nTotVlRetF    := 0                     //Valor Total Retido
Private nTOTDescObrF  := 0                     //Valor Total Descontos Obrigatorios
Private nTOTQuotSindF := 0                     //Valor Total Quotiza�oes Sindicais
//=================================================================================================================
//Variaveis totais Tipo G                                           
Private nTotVlRenG    := 0                     //Valor Total do Rendimento
Private nTotVlRetG    := 0                     //Valor Total Retido
Private nTOTDescObrG  := 0                     //Valor Total Descontos Obrigatorios
Private nTOTQuotSindG := 0                     //Valor Total Quotiza�oes Sindicais
//=================================================================================================================
//Variaveis totais Tipo H
Private nTotVlRenH    := 0                     //Valor Total do Rendimento
Private nTotVlRetH    := 0                     //Valor Total Retido
Private nTOTDescObrH  := 0                     //Valor Total Descontos Obrigatorios
Private nTOTQuotSindH := 0                     //Valor Total Quotiza�oes Sindicais
Private nTotCPO09a11  := 0                     //Valor Total de valores Retidos (Campos 01 a 08) + 09 + 10 - 11)
Private nTotCPO01a08  := 0                     //Valor Total de valores Retidos (Campos 01 a 08) 
Private nTotReg       := 0                     //Total de Registros no Arquivo
Private	nTotGERREND   := 0                  //valor total de Rendimentos no Ano
Private	nTotGerRetAno := 0                  //valor total de valores retidos no ano
Private	nTotGerVLRANT := 0                  //Valor total de Rendimentos Anos Anteriores
Private	nTotGerDescObr   := 0                  //Valor total de Descontos Obrigat�rios
Private	nTotGerQuotSind  := 0                  //Valor total de Quotiza��es Sindicais

dPeriodoDe := CTOD("01/01/"+cAno)              //Data do Periodo Inicial da inForma��es
dPeriodoAte:= CTOD("31/12/"+cANO)              //Data do Periodo Final das Informa��es

aFill(aTotRegs,0)                              //Inicializa variaveis Do Sistema

cLin1   := f795GrvCab('001') // Chama rotina de geracao do cabecalho - Registro Tipo 001
cLin2   := f795GrvCab('002') // Chama rotina de geracao do cabecalho - Header da Declara��o
cLin3   := f795GrvCab('003') // Chama rotina de geracao do cabecalho - HEader da Declara��o Anual 
cLin4   := f795GrvCab('004') // Chama rotina de geracao do cabecalho - Detalhe da Declara��o Anual 

cExt    := IIF(!".TXT"$Upper(mv_par10),".txt","")
cNomArq := AllTrim(mv_par11)+AllTrim(Upper(mv_par10))+cExt
nHdlArq := fCreate(cNomArq)
If nHdlArq == -1
	MsgStop(STR0018+cNomArq+STR0019,STR0008) // ###"O arquivo de nome "###" nao pode ser gravado! Verifique os parametros."###"Atencao!"
	Return
Endif

fWrite(nHdlArq,cLin1,Len(cLin1))
fWrite(nHdlArq,cLin2,Len(cLin2))
fWrite(nHdlArq,cLin3,Len(cLin3))
fWrite(nHdlArq,cLin4,Len(cLin4))

lTemArq := .T.


	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery 		:= .T.
			cAlias 	:= "TRAB"
			aStru 	:= RGO->(dbStruct())
            cQuery  := "SELECT DISTINCT RGO_FILIAL,RGO_ANO,RGO_MAT,RGO_NIF,RGO_LOCREN,RGO_TIPREN,RGO.RGO_VLRREN,RGO.RGO_VLRRET,RGO.RGO_VLRANT,RGO.RGO_NRANOS,RGO.RGO_DESOBR,RGO.RGO_QUOTSI "
            cQuery  += " FROM " + RetSqlName("RGO") + " RGO " 
            cQuery  += " WHERE RGO.D_E_L_E_T_='' "
			cQuery  += " AND RGO_ANO = '"+cANO+" ' "     
			cQuery  += " AND RGO_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"'"
			cQuery  += " ORDER BY RGO_FILIAL,RGO_MAT,RGO_TIPREN "
			 
			
            cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

			For nX := 1 To len(aStru)
				If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
					TcSetField(cAlias,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAlias)	
		Else
	#ENDIF
		(cAlias)->(MsSeek(RGO->RGO_FILIAL+RGO->RGO_MAT+RGO->RGO_NIF+RGO->RGO_TIPREN,.T.))
	#IFDEF TOP
		EndIf
	#ENDIF
    
    (cAlias)->(DbGoTop())

    ProcRegua((cAlias)->(RecCount()))

IF (cAlias)->(!Eof())
    

	Do While (cAlias)->(!Eof()) 
       
        dbSelectArea( "SRA" )
        dbSetOrder(1)
        dbSeek( (cAlias)->RGO_FILIAL  + (cAlias)->RGO_MAT , .T. )
        
        cNIF := (cAlias)->RGO_NIF    
              
        IF Alltrim((cAlias)->RGO_TIPREN) == "A"
		    nTotRendAntA  += (cAlias)->RGO_VLRANT 
		    nTotVlRenA    += (cAlias)->RGO_VLRREN 
		    nTotVlRetA    += (cAlias)->RGO_VLRRET
		    nTotDescObrA  += (cAlias)->RGO_DESOBR
		    nTOTQUOTSINDA += (cAlias)->RGO_QUOTSI
		ElseIF Alltrim((cAlias)->RGO_TIPREN) == "B"
       	       nTotRendAntB += (cAlias)->RGO_VLRANT 
			   nTotVlRenB   += (cAlias)->RGO_VLRREN 
			   nTotVlRetB   += (cAlias)->RGO_VLRRET
			   nTotDescObrB += (cAlias)->RGO_DESOBR
			   nTOTQUOTSINDB+= (cAlias)->RGO_QUOTSI
		ELSEIF Alltrim((cAlias)->RGO_TIPREN) == "EE"
    	       nTotRendAntEE += (cAlias)->RGO_VLRANT 
			   NTotVlRenEE   += (cAlias)->RGO_VLRREN 
			   nTotVlRetEE   += (cAlias)->RGO_VLRRET
			   nTotDescObrEE += (cAlias)->RGO_DESOBR
			   nTOTQUOTSINDEE += (cAlias)->RGO_QUOTSI
		ELSEIF Alltrim((cAlias)->RGO_TIPREN) == "F"
   		        nTotRendAntF += (cAlias)->RGO_VLRANT 
		        nTotVlRenF   += (cAlias)->RGO_VLRREN 
		        nTotVlRetF   += (cAlias)->RGO_VLRRET
		        nTotDescObrF += (cAlias)->RGO_DESOBR
		        nTOTQUOTSINDF+= (cAlias)->RGO_QUOTSI
		ELSEIF Alltrim((cAlias)->RGO_TIPREN) == "G"
  		        nTotRendAntG += (cAlias)->RGO_VLRANT 
		        nTotVlRenG  += (cAlias)->RGO_VLRREN 
		        nTotVlRetG  += (cAlias)->RGO_VLRRET
		        nTotDescObrG+= (cAlias)->RGO_DESOBR
		        nTOTQUOTSINDG+= (cAlias)->RGO_QUOTSI
		 ELSEIF Alltrim((cAlias)->RGO_TIPREN) == "H"
  		        nTotRendAntH += (cAlias)->RGO_VLRANT 
		        nTotVlRenH   += (cAlias)->RGO_VLRREN 
		        nTotVlRetH   += (cAlias)->RGO_VLRRET
		        nTotDescObrH += (cAlias)->RGO_DESOBR
		        nTOTQUOTSINDH += (cAlias)->RGO_QUOTSI
		 ENDIF
			 
      	
		nTotCpo01a08 := (nTotVlRetA + nTotVlRetB + nTotVlRetE + nTotVlRetEE + nTotVlRetF + nTotVlRetG + nTotVlRetH)	            // VALOR TOTAL RETIDO ANO
		
		nTotRendAno  := (nTotVlRenA + nTotVlRenB + nTotVlRenE + nTotVlRenEE + nTotVlRenF + nTotVlRenG + nTotVlRenH)	            // VALOR TOTAL Rendimento ANO      

		nTotCpo09a11 := (nTotCpo01a08 + nTaxLibera - nCompIRSIRC )                                                                                                          
		
	
		AAdd(aRegFunc,{(cAlias)->RGO_FILIAL,(cAlias)->RGO_MAT,(cAlias)->RGO_NIF,cAno,(cAlias)->RGO_TIPREN,(cAlias)->RGO_VLRANT,(cAlias)->RGO_NRANOS,(cAlias)->RGO_VLRREN,(cAlias)->RGO_VLRRET,(cAlias)->RGO_DESOBR,(cAlias)->RGO_QUOTSI,(cAlias)->RGO_LOCREN,SRA->RA_NOME})

	    
        nTotReg ++                     										//Total de Registros
             
        nTotGERREND     += (cAlias)->RGO_VLRREN                            //valor total de Rendimentos no Ano
        nTotGERRetAno   += (cAlias)->RGO_VLRRET                            //valor total de valores retidos no ano
		nTotGERVLRANT   += (cAlias)->RGO_VLRANT                            //Valor total de Rendimentos Anos Anteriores
	 	nTotGERDescObr  += (cAlias)->RGO_DESOBR                            //Valor total de Descontos Obrigat�rios
		nTotGERQuotSind += (cAlias)->RGO_QUOTSI                            //Valor total de Quotiza��es Sindicais
		
	 	(cAlias)->( dbSkip())

	Enddo


    //=====================================================
    //Gravacao do TRAILLER DECLARA��O ANUAL - Registro: 005
    //=====================================================

    cGrava := "005001"
    cGrava += SPACE(166)                 // Tipo do Registro
    cGrava += cEOL
    
    fWrite(nHdlArq,cGrava,Len(cGrava))
    
    
	//=====================================================
    //Gravacao do HEADER ANEXO J Modelo 10 - Registro: J01                                                
    //=====================================================
    cGrava := "J01"								   // Tipo do Registro
    cGrava += cIDFiscal                            // N.NIF do sujeito Passivo 
    cGrava += cANO                                 // Ano do Exercicio
    cGrava += STRZERO(nTotVlRetA  * 100,13)         // Valor Total Retido Tipo A
    cGrava += STRZERO(nTotVlRetB  * 100,13)         // Valor Total Retido Tipo B
    cGrava += STRZERO(nTotVlRetE  * 100,13)         // Valor Total Retido Tipo E
    cGrava += STRZERO(nTotVlRetEE * 100,13)        // Valor Total Retido Tipo EE
    cGrava += STRZERO(nTotVlRetF  * 100,13)         // Valor Total Retido Tipo F
    cGrava += STRZERO(nTotVlRetG  * 100,13)         // Valor Total Retido Tipo G 
    cGrava += STRZERO(nTotVlRetH  * 100,13)         // Valor Total Retido Tipo H
    cGrava += STRZERO(nRETIRC     * 100,13)            // Valor Total Reten�oes de IRC
    cGrava += STRZERO(nTaxLibera  * 100,13)         // Valor Total das Taxas Liberat�rias
    cGrava += STRZERO(nCompIRSIRC * 100,13)        // Valor de Compensa��o IRS / IRC
    cGrava += SPACE(26)
    cGrava += cEOL
    
    fWrite(nHdlArq,cGrava,Len(cGrava))
    
    cLog := STR0035 + ": "+strzero(ntotReg,5,0)      //"Registros Gerados: "
    Aadd(aTitle,cLog)  
    Aadd(aLog,{})
    aTotRegs[4] := len(aLog)       

    //=====================================================
    //Gravacao do HEADER ANEXO J Modelo 10 - Registro: J02
    //=====================================================
    FOR nCont := 1 to LEN(aRegFunc)
                    
        cGrava := "J02"									 // Tipo do Registro
        cGrava += STRZERO(nCONT,7,0)                     // Nr. Sequencial da Linha
        cGrava += aRegFunc[nCont,3]						 // NIF do Sujeito Passivo
        cGrava += STRZERO(aRegFunc[nCont,6]*100,14)		 // Rendimentos de anos anteriores - valores
        cGrava += STRZERO(aRegFunc[nCont,7],2,0)	     // Rendimentos de anos anteriores - N� de anos
        cGrava += STRZERO(aRegFunc[nCont,8]*100,14)		 // Rendimentos do ano 
        cGrava += aRegFunc[nCont,5]     				 // Tipo de Rendimento
        cGrava += aRegFunc[nCont,12]+" "				 // Local de obten��o do rendimento
        cGrava += STRZERO(aRegFunc[nCont,9] *100,13)	 // Import�ncias retidas
        cGrava += STRZERO(aRegFunc[nCont,10]*100,13)     // Descontos obrigat�rios
        cGrava += STRZERO(aRegFunc[nCont,11]*100,13)     // Quotiza��es sindicais
        cGrava += SPACE(79)
   	    cGrava += cEOL
         
        fWrite(nHdlArq,cGrava,Len(cGrava))
   	    Aadd(aLog[aTotRegs[4]], STR0036 + " "+aRegFunc[nCont,2] + " - " + aRegFunc[nCont,13]+ STR0037 + aRegFunc[nCont,5] ) // //"Nome Funcion�rio: "### "Tipo Rendimento: " 
    NEXT                           
    
    //======================================================  
    //Gravacao do TRAILLER ANEXO J Modelo 10 - Registro: J99
    //======================================================
    cGrava := "J99"                                       // Tipo do Registro
    cGrava += STRZERO(nTotCPO01a08 * 100,15)              // Valor Total das Reten��es Tipo A,B,E,EE,F,G,H 
    cGrava += STRZERO(nTotCpo09a11 * 100,15)              // Valor Total das Reten��es + Taxas Liberat�rias - Valores de Compensa��o de IRC
    cGrava += STRZERO(nTotGERRetAno  * 100,15)            // Total de import�ncias retidas nos registros J02
    cGrava += STRZERO(nTotGERREND * 100,15)             // Total de rendimentos do ano nos registros J02
    cGrava += STRZERO(nTotGERVLRANT * 100,15)             // Total de rendimentos de anos anteriores nos registros J02
    cGrava += STRZERO(nTotGERDescObr * 100,14)            // Total Descontos obrigat�rios
    cGrava += STRZERO(nTotGERQuotSind * 100,14)            // Total Quotiza��es sindicais
    cGrava += STRZERO(nTOTREG,7)                          // Total de Registros Tipo J02
    cGrava += SPACE(59)
    cGrava += cEOL
    
    fWrite(nHdlArq,cGrava,LEN(cGrava))
    //======================================================
    //Gravacao do TRAILLER ANEXO J Modelo 10 - Registro: 006
    //======================================================
    cGrava := "006"										  // Tipo do Registro
    cGrava += STRZERO(nTotREG+5,9)                        // Total de Registros J02 + Registros Tipo 003,004,005,J01,J99
    cGrava += SPACE(160)
    cGrava += cEOL
    
    fWrite(nHdlArq,cGrava,LEN(cGrava))
    
    //======================================================
    //Gravacao do TRAILLER ARQUIVO Modelo 10 - Registro: 999
    //======================================================
    cGrava := "999"										 // Tipo do Registro 
    cGrava += STRZERO(nTotREG+7,9)                       // Total de Registros J02 + Registros Tipo 002,003,004,005,006,J01,J99 
    cGrava += SPACE(160)        
    cGrava += cEOL
    
    fWrite(nHdlArq,cGrava,LEN(cGRAVA))
    
    // Fecha o arquivo gerado somente se houver registros validos
    If lTemArq
	   fClose(nHdlARq)
    Endif

    If aTotRegs[1] == 0 .and. aTotRegs[2] == 0 .and. aTotRegs[3] == 0 .and. ;
       aTotRegs[5] == 0 
       
      

	   If aTotRegs[6] == 0
		  cLog := STR0031  // "Arquivo texto da Declara��o de IRS - Modelo 10 Gerado com sucesso!"
		  Aadd(aTitle,cLog)  
		  Aadd(aLog,{})
		  aTotRegs[6] := len(aLog)
	   EndIf	
	   Aadd(aLog[aTotRegs[6]], STR0032 ) // "Nao foi encontrada nenhuma inconsistencia durante a geracao."
    EndIf   
    If aTotRegs[7] == 0
	   cLog := STR0033                   // "Informa��es para gerar o arquivo texto do IRS - Modelo 10."
	   Aadd(aTitle,cLog)  
	   Aadd(aLog,{})
	   aTotRegs[7] := len(aLog)
    EndIf
Else      
	  If aTotRegs[3] == 0
	     cLog := STR0004                 //"Nao ha dados a serem exibidos"
		 Aadd(aTitle,cLog)  
		 Aadd(aLog,{})
		 aTotRegs[3] := len(aLog)       
	  EndIf	
	  Aadd(aLog[aTotRegs[3]], STR0005 ) // //"Verifique os par�metros
Endif

fMakeLog(aLog,aTitle,,,"GPEM795",STR0034,"G","L",,.F.) // "Log Ocorr�ncias Arquivo Texto Declara��o IRS - Modelo 10"
(cAlias)->( dbCloseArea())    
Return
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Funcao    �GPM795GetFile �Autor  �Abel Ribeiro      � Data �  07/08/08  ���
��������������������������������������������������������������������������͹��
���Desc.     �Visualizacao do Relatorio de Log de Processamento.           ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function GPM795GetFile()
Local cArq
mvRet := Alltrim(ReadVar())
cArq := Space(80)
cTipo := STR0009+".txt"+")   | *."+"txt"+"  " // "Arquivos de Declaracao IRS Modelo 10 (*.txt)   | *.txt  "
cGetFile := cGetFile("",OemToAnsi(STR0010),0,,.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY) //"Selecione o Diretorio"
If Empty(cGetFile)
	Return(.F.)
Endif
&mvRet := cGetFile
Return(.T.)
/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpem795QbrPar�Autor� Abel Ribeiro           �Data�22/08/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna o texto dos parametros separado em linhas      		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�������������������������������������������������������������������������/*/
Function Gpem795QbrPar(cPerg)
nLinha := 1
nStrPar := 1
cTxtPar := ""
cTxtSX1 := ""
dbSelectArea("SX1")
dbSetOrder(1)
dbSeek(cPerg)
While !Eof() .And. SX1->X1_GRUPO == cPerg
	cTxtSX1 += AllTrim(SX1->X1_PERGUNT)+":'"
	cVarX1 := AllTrim(SX1->X1_VAR01)
	If SX1->X1_TIPO == "C"
		cContX1 := AllTrim(&cVarX1)
	ElseiF SX1->X1_TIPO == "N"
		cContX1 := AllTrim(Str(&cVarX1,SX1->X1_TAMANHO,SX1->X1_DECIMAL))
	ElseiF SX1->X1_TIPO == "D"
		cContX1 := Dtoc(&cVarX1)
	Endif
	cTxtSX1 +=  cContX1+"' ; " 
	dbSkip()
EndDo
While nStrPar <= Len(cTxtSX1)
	If nLinha > 6
		Exit
	Endif
	cTxtPar += Substr(cTxtSX1,nStrPar,80)+Chr(13)
	nStrPar+=80  
	nLinha++
EndDo
While nLinha <= 6
	cTxtPar += Chr(13)
	nLinha++
EndDo
Return(cTxtPar)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Funcao    �GPM795Log     �Autor  �Abel Ribeiro      � Data �  07/08/08  ���
��������������������������������������������������������������������������͹��
���Desc.     �Visualizacao do Relatorio de Log de Processamento.           ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GPM795Log()
cPathFile := ""
cExtRel := ".##R"
cPathFile := ( __RelDir + "GPEM795" + cExtRel )
If File(cPathFile)
	OurSpool( "GPEM795" )
	Ms_Flush()
Else
	MsgStop(STR0012) // "N�o existe Log de Processamento para exibir"
Endif
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GPM775Ok  �Autor  �Microsiga           � Data �  22/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GPM795Ok()
Return (MsgYesNo(OemToAnsi(STR0017),OemToAnsi(STR0008))) //"Confirma configura��o dos par�metros?"###"Aten��o"   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �f795LogTipo    �Autor  �Abel RIbeiro        � Data �04/09/08���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina p/ verificar se campos dos registros  estao corretos���
�������������������������������������������������������������������������͹��
���Uso       � Cria Log de Inconsistencia de registros conforme o tipo    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function f795LogTipo(cTipo,cIDFISCAL,cNIFREPRES,cNIFTecnico,cCODSERVFINA,cCNAE,cDTFatoGER,nPERCVOLNEG,cCODTABATIV)
If cTipo == '002'
	cTxtOco := ""
	cTxtOco += STR0020 	  // "Nro. de Identifica��o Fiscal"
	If aTotRegs[1] == 0
	   cLog := STR0021 // "Inconsist�ncias nas informa��es do Contato"
	   Aadd(aTitle,cLog)  
	   Aadd(aLog,{})
	   aTotRegs[1] := len(aLog)       
	   Aadd(aLog[aTotRegs[1]], cTxtOco ) 
	Endif
ElseIf cTipo == '003'
	   cTxtOco := ""
	   cTxtOco += Iif(Empty(cNIFREPRES),STR0022,"") 		// "NIF Representante Legal da Empresa"
	   cTxtOco += Iif(Empty(mv_par03),STR0023,"") 			// "Ano de referencia "
	   cTxtOco += Iif(Empty(cNIFTECNICO),STR0024,"")    	// "NIF do Tecnico Oficial  "
	   cTxtOco += Iif(Empty(cCodServFIna),STR0025,"") 		// "Cod. Servi�o de Finan�as "
	   cTxtOco += Iif(Empty(cCNAE),STR0026,"") 	        	// "Codigo CNAE "
	   cTxtOco += Iif(Empty(cDTFatoGER),STR0027,"") 		// "Data do fato Gerador "
	   cTxtOco += Iif(Empty(nPERCVOLNEG),STR0028,"") 		// "Percentual de Volume de Negocios "
	   cTxtOco += Iif(Empty(cCODTABATIV),STR0029,"") 		// "Cod. Tabela de atividades "

	   If aTotRegs[2] == 0
		  cLog := STR0030 // "Inconsistencias nos Parametros "
		  Aadd(aTitle,cLog)  
		  Aadd(aLog,{})
		  aTotRegs[2] := len(aLog)
		  Aadd(aLog[aTotRegs[2]], cTxtOco ) 
	   Endif 
ENDIF	
RETURN
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �f795GrvCab� Autor � Abel Ribeiro          � Data �03/09/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cabecalho dos arquivos a serem gerados                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function f795GrvCab(cTipo)
If cTipo == '001'
	cCab := cTipo 				       // Tipo de Registro
	cCab += "ASCII"           	       // Tipo do Arquivo
	cCab += cVersao 			       // Vers�o do Arquivo Fixo
	cCab += GRAVADATA(DDATABASE,.F.,8) // Data de Gera��o do Arquivo 
	cCab += Space(154) 			   // Espacos em Branco   
	cCab += cEOL
ElseIf cTipo == '002' 

	   cCab := cTipo 				        // Tipo de Registro
	   cCab += "DANUAL"           	        // String Fixa Tipo Declara��o
	   cCab += cIDFISCAL 			        // Nro. do NIF da EMpresa Responsavel
	   cCab += GRAVADATA(dPeriodoDe,.F.,8)  // Data de Periodo Inicial das Informa��es 
	   cCab += GRAVADATA(dPeriodoAte,.f.,8) // Data de Periodo Final   das Informa��es   
	   cCab += cAno                         // Ano do Exercicio   
	   cCab += "EUR"                        // Moeda corrente	
	   cCab += Space(131) 			        // Espa�os em Branco
	   cCab += cEOL
	   IF EMPTY(cIDFISCAL)                  //Testa para ver se o NIF da Empresa Esta, vazio se sim
	      f795LogTipo(cTipo,cIDFISCAL,NIL,NIL,NIL,NIL,NIL,NIL,NIL)      //Adiciona no LOg
       ENDIF
ElseIf cTipo == '003' 

	   cCab := cTipo 				              // Tipo de Registro
	   cCab += STRZERO(cCodServFIna,4,0) 	      // Codigo do Servi�o de Finan�as informado nos parametros
	   cCab += cCNAE			                  // Nro. do CNAE FISCAL
	   cCab += STRZERO(nPercVolNeg,3,0)           // % do Volume de Negocios informado nos parametros 
	   cCab += STRZERO(cCodTabAtiv,4,0)           // Cod. da Tabela de atividades   
	   cCab += "00000"                            // FIXO    
	   cCab += cTiPODecl                          // Tipo de Declara��o 1 ou 2 informada nos parametros 
	   cCab += "0"                                // FIXO    
	   cCab += GRAVADATA(cDtFatoGer,.F.,8)	      // Data do fato Gerador, informado nos parametros
	   cCab += TRANSFORM(cNIFRepres,"999999999")  // NIF do Representante Legal da Empresa
	   cCab += TRANSFORM(cNIFTecnico,"999999999") // NIF do t�cnico Oficial da empresa
	   cCab += Space(120) 	   		              // Espa�os em Branco
	   cCab += cEOL
	   IF EMPTY(cCNAE) .or. EMPTY(cCodServFINA) .or. EMPTY(cCodTabAtiv) .or. ;
	      EMPTY(cNIFRepres) .or.  EMPTY(cNIFTecnico) .or. EMPTY(cDTFATOGER)
	      f795LogTipo(cTipo,NIL,cNIFREPRES,cNIFTecnico,cCODSERVFINA,cCNAE,cDTFatoGER,nPERCVOLNEG,cCODTABATIV)      //Adiciona no LOg
       ENDIF                      
ElseIf cTipo == '004'
	   cCab := cTipo 				              // Tipo de Registro
	   cCab += REPLICATE("0",9)   	              // ZEROS FIXO 
	   cCab += "1"			                      // Fixo
	   cCab += REPLICATE("0",6)                   // ZEROS FIXO  
	   cCab += Space(153) 	   		              // Espa�os em Branco
	   cCab += cEOL
ElseIf cTipo == 'J01'
       cCab := cTIPO							  // Tipo do Registro
       cCab += cIDFiscal                          // N.NIF do sujeito Passivo 
       cCab += cANO                               // Ano do Exercicio
       cCab += STRZERO(nTotVlRetA  * 100,13)      // Valor Total Retido Tipo A
       cCab += STRZERO(nTotVlRetB  * 100,13)      // Valor Total Retido Tipo B
       cCab += STRZERO(nTotVlRetE  * 100,13)      // Valor Total Retido Tipo E
       cCab += STRZERO(nTotVlRetEE * 100,13)      // Valor Total Retido Tipo EE
       cCab += STRZERO(nTotVlRetF  * 100,13)      // Valor Total Retido Tipo F
       cCab += STRZERO(nTotVlRetG  * 100,13)      // Valor Total Retido Tipo G 
       cCab += STRZERO(nTotVlRetH  * 100,13)      // Valor Total Retido Tipo H
       cCab += STRZERO(nRETIRC     * 100,13)      // Valor Total Reten�oes de IRC
       cCab += STRZERO(nTaxLibera  * 100,13)      // Valor Total das Taxas Liberat�rias
       cCab += STRZERO(nCompIRSIRC * 100,13)      // Valor de Compensa��o IRS / IRC
       cCab += SPACE(25)
       cCab += cEOL

ENDIF
Return(cCab)