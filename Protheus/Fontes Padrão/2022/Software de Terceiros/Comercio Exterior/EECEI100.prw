#Include "EEC.CH"  
#Include "EECEI100.CH"
#Include "RWMAKE.CH"
#Include "FILEIO.CH"
#Include "AVERAGE.CH"
//#Include "AVFRM.CH"
#Define FAT_CERT "CO" //Fatura Comercial - Certificado de Origem
#Define DECL_EXP "DE" //Declara��o do Produto
#Define CO_FIERGS"CF" //Certificado de Origem FIERGS

#Define ST_A     "A"  //Arquivos aprovados
#Define ST_E     "E"  //Arquivos enviados
#Define ST_N     "N"  //Arquivos n�o enviados
#Define ST_R     "R"  //Arquivos rejeitados

#DEFINE DESPACHANTE"5"
#DEFINE ACORDO     "6"
#DEFINE EXPORTADOR "7"
#DEFINE UN_MEDIDA  "8"
#DEFINE PRODUTO    "9"
#DEFINE NORMA      "A"
#DEFINE PAIS       "B"

#define ENTER CHR(13)+CHR(10)

#define HWSDL "http://wwwapp.sistemafiergs.org.br:8888/slows_teste/services/wsslo?wsdl"	//WSDL Homologa��o
#define PWSDL "http://wwwapp.sistemafiergs.org.br:8888/slows/services/wsslo?wsdl"		//WSDL Produ��o

#define DATETIME DTOC(DATE()) + " " + TIME()
#define LINHA    CRLF + REPLICATE("-", 99) + CRLF

// LGS - 29/02/2016 - Criptografia dados FIERGS
#xTranslate ENCRYPF(<param>) => Encode64(FWAES_Encrypt(<param>,"d759e3r2@"))
#xTranslate DECRYPF(<param>) => OemToAnsi(FWAES_Decrypt(Decode64(<param>),"d759e3r2@"))

/*
Programa  : EECEI100.PRW
Objetivo  : Integra��o FIESP
Par�metros: 
Retorno   : L�gico (.T. ou .F.)
Autor     : Wilsimar Fabr�cio da Silva
Data      : Novembro de 2009
Obs.      : Fluxo de funcionamento do programa:
            1. Par�metros para a gera��o do arquivo
            2. Valida��o e verifica��o da exist�ncia do arquivo, para n�o sobrepor arquivos existente j� que o
               nome do arquivo ser� o CNPJ do exportador.
            3. Cria��o dos arrays aHeader, aDetail e aTrailler conforme layout Fiesp para a linha correspondente.
               Estes arrays ser�o a base para a cria��o do array aCols com as informa��es finais que ser�o usadas para
               a gera��o do arquivo de integra��o.
               A estrutura dos arrays visa possibilitar a an�lise e a customiza��o, manipulando os arrays para a defini��o
               dos tamanhos dos campos (aHeader, aDetail e aTrailler) e altera��o dos valores capturados pelas fun��es
               extratoras de informa��es em customiza��es, atrav�s da busca da identifica��o do registro.


               Estrutura dos arrays aHeader, aDetail e aTrailler:
                                              {
                                               1 - T�tulo (definido pela Fiesp)
                                               2 - Campo correspondente no dicion�rio de dados do sistema
                                               3 - Picture
                                               4 - Tamanho (quantidade de d�gitos definido pela Fiesp)
                                               5 - Decimais (definido pela Fiesp)
                                               6 - Tipo (caracteres num�ricos ou alfanum�ricos, definido pela Fiesp)
                                               7 - Arquivo (tabela)
                                               8 - Valor fixo, informado pela FIESP ou que ser� tratato antes de ser
                                                   preenchido no aCols
                                              }
               Estrutura do array aCols:
                                              {
                                               x.1 - Identifica��o do registro
                                               x.n - Informa��es da linha
                                              }
            	3.1. Fun��es staticas para posicionamento de registros, valida��o das informa��es e preenchimento de dados
            	     (na posi��o 7) que devem ser manipulados antes da gera��o do arquivo.
            4. Cria��o dos aCols (Fatura e Produtos) com base no aHeader, aDetail e aTrailler.
            5. Cria��o dos diret�rios.
            6. Cria��o do arquivo texto.

            O recebimento do n�mero do processo e o local para a gera��o do arquivo TXT se dar� por meio de par�metros.
*/

#Define TITULO   1
#Define CAMPO    2
#Define PICT     3
#Define TAM      4
#Define DEC      5
#Define TIPO     6
#Define ARQ      7
#Define FIXO     8
#Define ACAO_NA  "NA" //C�digo da a��o que indica a gera��o de um novo arquivo
#Define ACAO_EA  "EA" //C�digo da a��o que indica o envio de um novo arquivo
#Define ACAO_RA  "RA" //C�digo da a��o que indica o retorno do arquivo enviado
#Define ACAO_VA  "VA" //C�digo da a��o que indica a visualiza��o do arquivo

/*
Fun��o    : EECEI100
Objetivo  : Chamada da central de integra��es para o in�cio das opera��es
Par�metros: 
Retorno   : 
Autor     : Wilsimar Fabr�cio da Silva
Data      : 11/11/2009
Obs.      :
*/

Function EECEI100(cCOrigem) //LGS-31/08/2015 - Informa qual o certificado de origem foi chamado.
Local aSaveArea:= GetArea(),;
      aOrd     := SaveOrd({"EE9", "EEC", "EEI", "E09", "E10", "EXN", "SA1", "SA2", "SA5", "SAH", "SB1", "SG1",;
                           "SYA", "SY9", "SYQ", "E11"})
Local aServ   := {},;
      aAcao   := {},;
      aItens  := {},;
      aIds    := {},;
      aCampos1:= {},;
      aCampos2:= {},;
      aCampos3:= {},;
      aCampos4:= {}
Local bAcao,;
      bOk,;
      bCancel
Local cAlias:= "E09"
Local nSetOrder := 1 //Define o SetOrder para a Tabela
Local cTitulo:= ""   //LGS-31/08/2015
local aIdsVis := {}
Private aCols    := {},;
        aDados   := {},;
        aDeclProd:= {},;
        aGets    := {},;
        aTela    := {}
Private cDirGerado := "\Comex\CO\FIESP\gerados\",;
        cDirEnviado:= "\Comex\CO\FIESP\enviados\",;
        cAcordoCom := "",;
        cOpTriang  := "0",;     //Apenas opera��es comuns (n�o atenderemos opera��es triangulares, a princ�pio)
        cCadastro  := STR0091,; //Cadastro da Declara��o de Produtos - FIESP
        cTitMsg    := ""
Private nClassif   := 0         //Vari�vel usada apenas para a declara��o de produtos
Private lECool := EasyGParam("MV_EECCOOL",,"COOL") == "ECOOL"  // RMD - 27/08/2014
Private lFiergs:= .F.
Private cYUDESP:= AvKey(EasyGParam("MV_EEC0047",,""),"YU_DESP")//LGS-02/02/2016
Default cCOrigem :="FIESP"

Begin Sequence

   //Campos que ser�o exibidos na Work de arquivos n�o enviados
   aCampos1:= {"E09_ARQUIV", "E09_PREEMB", "E09_USUACR", "E09_DATACR", "E09_HORACR"}
   //Campos que ser�o exibidos na Work de arquivos enviados
   aCampos2:= {"E09_ARQUIV", "E09_PREEMB", "E09_USUAEN", "E09_DATAEN", "E09_HORAEN"}
   
   Do Case
      Case cCOrigem == "FIESP"
           cTitulo := STR0066
           If !lECool   // RMD - 27/08/2014	
	   			//Declara��o do produto
	   			/* Vetor de itens
	   			1. Descri��o do Item
	   			2. ID para controle interno
	   			3. Status (conte�do dos campos do �ndice informado)
	   			4. aCampos
	   			5.
	   			6.
	   			7. */
	   			AAdd(aItens, {STR0065, ST_N, ST_N + DECL_EXP,aCampos1,,}) //N�o Enviados
	   			AAdd(aItens, {STR0064, ST_E, ST_E + DECL_EXP,aCampos2,,}) //Enviados
	   			AAdd(aItens, {STR0121, ST_A, ST_A + DECL_EXP,        ,,}) //Aceitos
	   			AAdd(aItens, {STR0122, ST_R, ST_R + DECL_EXP,        ,,}) //Rejeitados
	   			/* Vetor de servi�os
	   			1.  Descri��o do Servi�o
	   			2.  Alias da Tabela de Servi�o.
	   			3.  ID para controle interno.
	   			4.  aItens
	   			5.  aCampos MsSelect
	   			6.  Indice (n�mero do �ndice da tabela
	   			7.  Imagem 1
	   			8.  Imagem 2 */
	   			AAdd(aServ, {STR0060, cAlias, DECL_EXP, aItens,, nSetOrder, "Folder5", "Folder6"}) //Declara��o do Produto
	   		EndIf
	   		//Fatura Comercial - Certificado de Origem
	   		//Vetor de itens
	   		aItens:= {}
	   		AAdd(aItens, {STR0065, ST_N, ST_N + FAT_CERT,aCampos1,,}) //N�o Enviados
	   		AAdd(aItens, {STR0064, ST_E, ST_E + FAT_CERT,aCampos2,,}) //Enviados
	   		AAdd(aItens, {STR0121, ST_A, ST_A + FAT_CERT,        ,,}) //Aceitos
	   		AAdd(aItens, {STR0122, ST_R, ST_R + FAT_CERT,        ,,}) //Rejeitados
	   		//Vetor de servi�os
	   		AAdd(aServ, {STR0061, cAlias, FAT_CERT, aItens,, nSetOrder, "Folder5", "Folder6"}) //Fatura Comercial - C.Origem
	   		
      Case cCOrigem == "FIERGS"
           aRotina := MenuDef("EI100FIERG")
           cTitulo := "Integra��o FIERGS"
           lFiergs := .T.
           cDirGerado := "\Comex\CO\FIERGS\gerados\"
           cDirEnviado:= "\Comex\CO\FIERGS\enviados\"
           cCadastro  := STR0173 //"Cadastro do Certificado de Origem - FIERGS"
           /* Vetor de itens
           1. Descri��o do Item, 2. ID para controle interno, 3. Status (conte�do dos campos do �ndice informado)
           4. aCampos,				5.,								 6.,	      					7. */
           aItens:= {}
           AAdd(aItens, {STR0065, ST_N, ST_N + CO_FIERGS,aCampos1,,}) //N�o Enviados
           //AAdd(aItens, {STR0064, ST_E, ST_E + CO_FIERGS,aCampos2,,}) //Enviados
           AAdd(aItens, {STR0121, ST_A, ST_A + CO_FIERGS,        ,,}) //Aceitos
           AAdd(aItens, {STR0122, ST_R, ST_R + CO_FIERGS,        ,,}) //Rejeitados
           /* Vetor de servi�os
           1.  Descri��o do Servi�o,			2.  Alias da Tabela de Servi�o.,			3.  ID para controle interno.,		4.  aItens
           5.  aCampos MsSelect,				6.  Indice (n�mero do �ndice da tabela,	7.  Imagem 1,							8.  Imagem 2 */
           AAdd(aServ, {STR0172, cAlias, CO_FIERGS, aItens,, nSetOrder, "Folder5", "Folder6"}) //Declara��o do Produto
   EndCase 
                            
   /* Vetor de a��es
      1. Descricao da Op��o
      2. Id
      3. Array com os IDs dos itens e servi�os que possuem a op��o
      4. Codblock com as fun��es
      5. Status
      6. Imagem 1
      7. Imagem 2 */

   //A��o: Gera��o de um novo arquivo //LRS - 24/04/2015 - Todas as op��es colocadas em um unico Array
   aIds:= {DECL_EXP , DECL_EXP  + ST_N, DECL_EXP  + ST_E, DECL_EXP  + ST_A, DECL_EXP  + ST_R,;
           FAT_CERT , FAT_CERT  + ST_N, FAT_CERT  + ST_E, FAT_CERT  + ST_A, FAT_CERT  + ST_R,;
           CO_FIERGS, CO_FIERGS + ST_N, CO_FIERGS + ST_E, CO_FIERGS + ST_A, CO_FIERGS + ST_R,;
           "RAIZ",;           
           DECL_EXP  + ST_N, FAT_CERT  + ST_N,;
           DECL_EXP  + ST_E, FAT_CERT  + ST_E,;
           CO_FIERGS + ST_E, CO_FIERGS + ST_E,;
           DECL_EXP  + ST_N, DECL_EXP  + ST_E, DECL_EXP  + ST_A, DECL_EXP  + ST_R,;
           FAT_CERT  + ST_N, FAT_CERT  + ST_E, FAT_CERT  + ST_A, FAT_CERT  + ST_R,;
           CO_FIERGS + ST_N, CO_FIERGS + ST_E, CO_FIERGS + ST_A, CO_FIERGS + ST_R}
   aIdsVis := aClone(aIds)
   If cCOrigem == "FIERGS"
      aIds := {CO_FIERGS, CO_FIERGS + ST_N, "RAIZ" }
      aIdsVis := {CO_FIERGS, CO_FIERGS + ST_N, "RAIZ",  CO_FIERGS + ST_A, CO_FIERGS + ST_R}
   EndIf
           
   bAcao:= {|| EI100GeraArq(cCOrigem), AvAtuCentrInt("", aServ)}
   AAdd(aAcao, {STR0067, ACAO_NA, aIds, bAcao, ST_N, "", ""})	//Novo Arquivo
   
   bAcao:= {|| EI100EnviaArq(cCOrigem), AvAtuCentrInt("", aServ)}
   AAdd(aAcao, {STR0063, ACAO_EA, aIds, bAcao, ST_E, "", ""})	//Enviar Arquivo
 
   If cCOrigem == "FIESP"
      bAcao:= {|| EI100RetFiesp(cCOrigem), AvAtuCentrInt("", aServ)}
      AAdd(aAcao, {STR0124, ACAO_RA, aIds, bAcao,, "", ""})		//Retornar Arquivo
   EndIf
      
   bAcao:= {|| EI100VisualArq(cCOrigem)}
   AAdd(aAcao, {STR0159, ACAO_VA, aIdsVis, bAcao,, "", ""})		//Visualizar Arquivo 
   
   If cCOrigem == "FIERGS"
      bAcao:= {|| EI100Configs(cCOrigem)}
      AAdd(aAcao, {"Configura��es", "CFG", aIds, bAcao,, "", ""})		//Configura��es
   EndIf
      
   AvCentIntegracao(aServ, aAcao, STR0068, STR0069, STR0070, STR0069, STR0070, /*STR0066*/cTitulo, bOk, bCancel,,,,,,,.F.) //LRS - 24/04/2015 - Colocado .F. para n�o atualizar as op��es e n�o travar o click de uma op��o .
   
End Sequence

RestArea(aSaveArea)
RestOrd(aOrd)
Return

/*
Fun��o    : EI100GeraArq
Objetivo  : Controlar a gera��o dos arquivos de integra��o
Par�metros: 
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 12/11/2009
Obs.      : O array aCols, por ser private, sempre zer� zerado no in�cio desta opera��o.
*/

Function EI100GeraArq(cOrigem)
Local bGeraTxt
Local cPreemb    := "",;
      cIntegracao:= "",;
      cNomeArq   := "",;
      cDiretorio := ""
Local lRet:= .T.
Local oDlg
Local cMsg	:= ""
Local cArqID := ""
Local aSemSX3 := {}, aOrd := {}
Private cAcordo := "" //Utilizado para o FIERGS
Private aCTRange:={} //Utilizado para o FIERGS
Default cOrigem := "FIESP"
 
Begin Sequence

   aCols:= {}
   aDados:= {}

   /*Tipo de arquivo de integra��o que ser� gerado:
     Fatura Comercial - Certificado de Origem ou
     Declara��o do Produto */
   cIntegracao:= TipoIntegracaoEI100()
   
   If Empty(cIntegracao)
      lRet:= .F.
      MsgInfo(STR0239,STR0240) //"N�o � poss�vel executar esta a��o na pasta selecionada." ### "Aten��o"
      Break
   EndIf

   Do Case

      //Se � declara��o do produto
      Case cIntegracao == DECL_EXP

         cTitMsg:= STR0060 //Declara��o do Produto

         //Par�metros para a gera��o do arquivo de integra��o
         If !Pergunte("EI100D", .T., STR0060) //Declara��o do Produto
            lRet:= .F.
            Break
         EndIf

         cPreemb  := MV_PAR01
         nClassif := MV_PAR02

         If !ValidGeraArqEI100(cIntegracao, cPreemb, @cNomeArq)
            lRet:= .F.
            Break
         EndIf

         //Cria��o do layout do arquivo DECL_EXP (layout para envio de informa��es da Declara��o dos Produtos).
         If !DeclExpLayoutEI100()
            lRet:= .F.
            Break
         EndIf


      //Se � fatura comercial - certificado de origem
      Case cIntegracao == FAT_CERT

         cTitMsg:= STR0061 //Fatura Comercial - C.Origem

         //Par�metros para a gera��o do arquivo de integra��o
         If !Pergunte("EI100A", .T., STR0061) //Fatura Comercial - C.Origem
            lRet:= .F.
            Break
         EndIf
         cPreemb   := MV_PAR01
         //RMD - 11/08/14 - E-Cool
         cRegional := MV_PAR02
         //LRS - 14/09/2016 
         IF MV_PAR03 == 1
            cIdioma  := "EN"
         Elseif MV_PAR03 == 2
            cIdioma  := "PT"
         Elseif MV_PAR03 == 3
            cIdioma  := "ES"
         EndIF

         //Verifica��o do acordo comercial com base nos c�digos das normas dos itens do processo.
         //Esta fun��o carrega o c�digo da norma de origem na vari�vel private cAcordoCom.
         If !VerifAcordoEI100(cPreemb)
            lRet:= .F.
            Break
         EndIf


      	 If !lECool  // RMD - 27/08/2014
         
	         //Valida��es para a gera��o do arquivo.
	         If !ValidGeraArqEI100(cIntegracao, cPreemb, @cNomeArq)
	            lRet:= .F.
	            Break
	         EndIf
	
	         //Cria��o do layout do arquivo FAT_CERT (layout para envio de informa��es de Certificados de Origem e Fatura Comercial).
	         If !FatCertLayoutEI100()
	            lRet:= .F.
	            Break
	         EndIf

        EndIf
      
      Case cIntegracao == CO_FIERGS

         cTitMsg:= STR0172 //"Certificado de Origem - FIERGS"
                          
         If Empty( cYUDESP )
            cMsg += STR0175
         Else
            SY5->(DbSetOrder(1))
            IF !SY5->(DbSeek(xFilial("SY5")+ AvKey( cYUDESP ,"Y5_COD") ))
               cMsg += STR0176 + cValToChar(Alltrim(cYUDESP))
            EndIf
         EndIf
         If !Empty(cMsg)
            EECView(cMsg,STR0174)
            Break
         EndIf
         
         //Embarque selecionado para gera��o do certificado - FIERGS
         cPreemb := TelaFIERGS()
                 
         //TEM OS ACORDOS COMERCIAIS E AS NORMAS
         aSemSX3 := {}   
         AAdd(aSemSX3, {"WK_CODNOR" , AVSX3("EE9_CODNOR",AV_TIPO),AVSX3("EE9_CODNOR",AV_TAMANHO),AVSX3("EE9_CODNOR",AV_DECIMAL) })
         AAdd(aSemSX3, {"WK_ACCOME" , AVSX3("EEI_ACCOME",AV_TIPO),AVSX3("EEI_ACCOME",AV_TAMANHO),AVSX3("EEI_ACCOME",AV_DECIMAL) })
         aAdd(aSemSx3, {"DBDELETE"  ,"L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work

         cArqWKNR:= E_CriaTrab(,aSEMSX3,"WorkNR")
         IndRegua("WorkNR",cArqWKNR+TEOrdBagExt(),"WK_ACCOME+WK_CODNOR")
         //IndRegua("WorkNR",cArqWKNR+OrdBagExt(),"WK_CODNOR+WK_ACCOME")
         
         //TEM OS ACORDOS COMERCIAIS
         aSemSX3 := {}
         AAdd(aSemSX3, {"WKFLAG"    ,"C",2,0 })
         AAdd(aSemSX3, {"WK_ACCOME" , AVSX3("EEI_ACCOME",AV_TIPO),AVSX3("EEI_ACCOME",AV_TAMANHO),AVSX3("EEI_ACCOME",AV_DECIMAL) })
         cArqWKAC:= E_CriaTrab(,aSEMSX3,"WorkAC")
         IndRegua("WorkAC",cArqWKAC+TEOrdBagExt(),"WK_ACCOME")
         
         If !Empty(cPreemb)
            //Par�metros para a gera��o do arquivo de integra��o(Pergunte)
            If !EI100Param(cPreemb)
               lRet := .F.
               Break
            Else
               If !EI100NormaTec(aCTRange) //LGS - 04/03/2016
                  WorkNR->(E_EraseArq(cArqWKNR))
                  WorkAC->(E_EraseArq(cArqWKAC))
                  lRet := .F.
                  Break
               Else
                  WorkNR->(DbGoTop())
                  Do While WorkNR->(!Eof())
                     If WorkNR->WK_ACCOME <> AvKey(cAcordo,"EEI_ACCOME")
                        WorkNR->(RecLock("WorkNR",.F.))
                        WorkNR->DBDELETE := .T.
                        WorkNR->(dbDelete())
                        WorkNR->(__dbPack())
                        WorkNR->(MsUnlock())
                     EndIf
                     WorkNR->(DbSkip())
                  EndDo
               EndIf               
            EndIf            
            cUnAnalise := MV_PAR02
            cUnRetirada:= MV_PAR03
            cCapTecnico:= MV_PAR04
         Else
            lRet := .F.
            WorkNR->(E_EraseArq(cArqWKNR))
            WorkAC->(E_EraseArq(cArqWKAC))
            Break
         EndIf
         //cPreemb    := MV_PAR01
         
         If !ValidGeraArqEI100(cIntegracao, cPreemb, @cNomeArq, "CP" + SubStr(cCapTecnico,1,2) + "ACO" + AllTrim(cAcordo) ) //Envia o capitulo
            WorkNR->(E_EraseArq(cArqWKNR))
            WorkAC->(E_EraseArq(cArqWKAC))
            lRet := .F.
            Break
         EndIf
         
         cArqID := StrTran(@cNomeArq, "CP" + SubStr(cCapTecnico,1,2), "")
        
      OtherWise
         lRet:= .F.
         Break      
      
   EndCase

   //Verifica��o da exist�ncia dos diret�rios para a grava��o dos arquivos de integra��o
   //Caso negativo, os diret�rios ser�o criados.
   cDiretorio:= cDirGerado + EI100Name(AllTrim(cPreemb)) + "\"
   If !CriaDiretorioEI100(cDiretorio)
      lRet:= .F.
      Break
   EndIf

   Do Case
      Case cOrigem == "FIESP"     
         
         If !lECool   // RMD - 27/08/2014
            //Cria��o do(s) arquivo(s) de integra��o. O nome do arquivo � o CNPJ do exportador.
            //O conte�do da vari�vel cNomeArq � preenchido na fun��o ValidGeraArqEI100.
            bGeraTxt:= {|| lRet:= FiespCriaTxtEI100(cDiretorio, cNomeArq, aCols)}
            Processa(bGeraTxt, STR0058, STR0059, .T.) //Gera��o de arquivo / Gerando o arquivo para a integra��o..
         Else
            //Gera o arquivo do E-Cool
            bGeraTxt:= {|| cNomeArq := GetCertECOOL(cDiretorio, cIntegracao) }
            Processa(bGeraTxt, STR0058, STR0059, .T.) //Gera��o de arquivo / Gerando o arquivo para a integra��o...
            lRet := !Empty(cNomeArq)
         EndIf
      
      Case cOrigem == "FIERGS"
         //Colocar um loop aqui para criar todos os xml quebrando por norma.....
         //Gera o arquivo do FIERGS
         bGeraXML:= {|| lRet:= FiergsCriaXML(cDiretorio, cNomeArq, AllTrim(cPreemb), AllTrim(cUnAnalise), AllTrim(cUnRetirada), aCTRange)}
         Processa(bGeraXML, STR0058, STR0059, .T.)    //Gera��o de arquivo / Gerando o arquivo para a integra��o...
         WorkNR->(E_EraseArq(cArqWKNR))
         WorkAC->(E_EraseArq(cArqWKAC))      
   EndCase

   If lRet
      //Grava��o dos dados da gera��o do arquivo na tabela de hist�rico
      FiespAtuE09EI100(cNomeArq, cIntegracao, cPreemb, cArqID, cOrigem) //LGS-03/11/2015
      //Grava��o da chave da tabela E09 na tabela E10, correspondente ao primeiro arquivo criado para a integra��o
      FiespAtuE10EI100(cNomeArq, cPreemb)
   EndIf

End Sequence

If !lRet
   MsgInfo(STR0090, cTitMsg) //O arquivo de integra��o n�o foi gerado.
EndIf

Return lRet

/*
Fun��o    : EI100EnviaArq
Objetivo  : Controlar o envio de arquivos, exibi��o da tela ao usu�rio e mover o arquivo de integra��o
            do diret�rio gerados para o diret�rio enviados.
Par�metros: 
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 12/11/2009
Obs.      :
*/

Function EI100EnviaArq(cOrigem)
Local bOk     := {|| lRet:= AtualizaStatusEI100(ST_E), oDlg:End()},;
      bCancel := {|| lRet:= .F., oDlg:End()},;
      bGet    := {|x| If(PCount() > 0, cExibeArq:= x, cExibeArq)},;
      bEnvCO  := {|| lRet:= .T., oDlg:End()}
Local cArquivo   := "",;
      cDirOrigem := "",;
      cDirDestino:= "",;
      cAlias     := Alias(),;
      cPreemb    := "",;
      cExibeArq  := ""
Local lRet:= .T.
Local nInferior:= 100,;
      nDireita := 500
Local oDlg
Local lTela    := .T.
Private oTMultMSG, cSBMsg := cSBJusFat := "" //LGS-23/10/2015 - Utilizado no FIERGS

Default cOrigem := "FIESP"

Begin Sequence

   If cOrigem == "FIESP"
      If TipoIntegracaoEI100() == DECL_EXP //Se � declara��o do produto
         cTitMsg:= STR0060 //Declara��o do Produto
      Else //Se � fatura comercial - certificado de origem
         cTitMsg:= STR0061 //Fatura Comercial - C.Origem
      EndIf
   Else
      cTitMsg:= STR0172 //"Certificado Origem FIERGS"
   EndIf
   
   cIntegracao:= TipoIntegracaoEI100()
   If Empty(cIntegracao)
      lRet:= .F.
      MsgInfo(STR0239,STR0240) //"N�o � poss�vel executar esta a��o na pasta selecionada." ### "Aten��o"
      Break
   EndIf
   
   If (cAlias)->(EasyRecCount()) == 0
      MsgInfo(STR0081, cTitMsg) //N�o existem arquivos a serem enviados para este servi�o.
      lRet:= .F.
      Break
   EndIf
   
   //Posiciona a tabela EEC no embarque correspondente
   EEC->(DBSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
   EEC->(DBSeek(xFilial() + AvKey((cAlias)->E09_PREEMB, "EEC_PREEMB")))
   cPreemb    := AllTrim((cAlias)->E09_PREEMB)
   cArquivo   := AllTrim((cAlias)->E09_ARQUIV)
   cDirOrigem := cDirGerado + EI100Name(cPreemb) + "\"
   cDirDestino:= GetTempPath() + cOrigem + "\" //"fiesp\"
   
   //Cria��o do diret�rio destino
   If !CriaDiretorioEI100(cDirDestino)
      lRet:= .F.
      Break
   EndIf
   
   //Copia o arquivo para o diret�rio tempor�rio do terminal do usu�rio
   If File(cDirDestino + cArquivo)
      FErase(cDirDestino + cArquivo)
   EndIf
   
   If !CpyS2T(cDirOrigem + cArquivo, cDirDestino)
      If File(cDirOrigem + cArquivo)
         MsgInfo(STR0079, cTitMsg) //N�o foi poss�vel copiar o arquivo de integra��o para o terminal do usu�rio.
      Else
         MsgInfo(STR0115, cTitMsg) //Arquivo de origem n�o encontrado.
      EndIf
      lRet:= .F.
      Break
   EndIf
   
   //Posicionamento da tabela E09
   E09->(DBSetOrder(2)) //E09_FILIAL + E09_ARQUIV + E09_PREEMB + E09_STATUS
   E09->(DBSeek(xFilial() + AvKey(cArquivo, "E09_ARQUIV") + AvKey(cPreemb, "E09_PREEMB")))
   //Tela para exibi��o do caminho do arquivo de integra��o
   cExibeArq:= cDirDestino + cArquivo
   
   Do Case
      Case cOrigem == "FIESP"
         
         Define MsDialog oDlg Title STR0066 From 0, 0 To nInferior, nDireita Pixel Of oMainWnd //Integra��o FIESP - COOL
         		TSay():New(40, 10, {|| STR0080}, oDlg,,,,,, .T.) //Arquivo:
         		TGet():New(39, 32, bGet, oDlg, 190, 08,,,,,,,, .T.)
         		//@ 28, 223 BMPButton Type 14 Action WinExec("Explorer " + cDirDestino)
         Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel,, {{"", {||  WinExec("Explorer " + cDirDestino)}, STR0241, STR0241}}) Centered
         
         //Ap�s a atualiza��o do status, o arquivo ser� movido para o diret�rio enviados.
         If lRet
            //Apagando o arquivo tempor�rio
            FErase(cDirDestino + cArquivo)
            //Cria��o do diret�rio de destino
            cDirDestino:= cDirEnviado + EI100Name(cPreemb) + "\"    //NCF - 07/01/2015
            If !CriaDiretorioEI100(cDirDestino)
               lRet:= .F.
               Break
            EndIf
            /*************
            Arquivo de integra��o
            ***********************/
            //Apagando o arquivo, caso seja reenvio
            FErase(cDirDestino + cArquivo)
            //Cria��o do arquivo de integra��o para onde o atual ser� copiado
            hFile:= EasyCreateFile(cDirDestino + cArquivo)
            FClose(hFile)
            //Movendo o arquivo para o diret�rio \enviados\
            If !__CopyFile(cDirOrigem + cArquivo, cDirDestino + cArquivo)
               MsgInfo(STR0082, cTitMsg) //N�o foi poss�vel mover o arquivo para o diret�rio 'Enviados'.
               lRet:= .F.
               Break
            EndIf
            //Apagando o arquivo de origem
            FErase(cDirOrigem + cArquivo)
            If !lECool    // RMD - 27/08/2014
               /*************
               Arquivo de visualiza��o
               ***********************/
               //Altera��o do nome do arquivo
               cArquivo:= SubStr(cArquivo, 1, At(".", cArquivo) -1) + ".txt"
               //Apagando o arquivo, caso seja reenvio
               FErase(cDirDestino + cArquivo)
               //Cria��o do arquivo de visualiza��o para onde o atual ser� copiado
               hFile:= EasyCreateFile(cDirDestino + cArquivo)
               FClose(hFile)
               //Movendo o arquivo para o diret�rio \enviados\
               If !__CopyFile(cDirOrigem + cArquivo, cDirDestino + cArquivo)
                  MsgInfo(STR0082, cTitMsg) //N�o foi poss�vel mover o arquivo para o diret�rio 'Enviados'.
                  lRet:= .F.
                  Break
               EndIf
               //Apagando o arquivo de origem
               FErase(cDirOrigem + cArquivo)
               //Apagando o diret�rio...
               DirRemove(cDirOrigem)
            EndIf
         EndIf

      Case cOrigem == "FIERGS"
         Do While lTela
         DEFINE MSDIALOG oDlg TITLE STR0177 FROM 000, 000  TO 350, 465 COLORS 0, 16777215 PIXEL
              oPanel:= tPanel():New(01,01,"",oDlg,,,,,,100,100)
              oPanel:Align := CONTROL_ALIGN_ALLCLIENT
         		
         		@ 004, 004 GROUP oGroup1 TO 153, 231 PROMPT STR0178 OF oPanel PIXEL
         		
         		TSay():New(013, 008, {|| STR0080}, oPanel,,,,,, .T.) //Arquivo:
         		TGet():New(023, 008, bGet, oPanel, 219, 010,,,,,,,,.T.,,,,,,,.T.)
         		
         		TSay():New(038, 008, {|| STR0179}, oPanel,,,,,, .T.)//Status:
         		oTMultMSG := TMultiget():New(048,008,{|u|if(Pcount()>0,cSBJusFat:=u,cSBJusFat)},oPanel,219,039,,,,,,.T.,,,,,,.F.,,,,,.T.)
         		
         		TSay():New(090, 008, {|| STR0180}, oPanel,,,,,, .T.)//Status:
         		oTMultMSG := TMultiget():New(100,008,{|u|if(Pcount()>0,cSBMsg:=u,cSBMsg)},oPanel,219,047,,,,,,.T.,,,,,,.T.,,,,,.T.)
         		
         		@ 158, 148 BUTTON STR0181 ACTION Eval(bEnvCO ) SIZE 039,012 PIXEL OF oPanel //Enviar
         		@ 158, 193 BUTTON STR0182 ACTION Eval(bCancel) SIZE 039,012 PIXEL OF oPanel //Sair
         
         ACTIVATE MSDIALOG oDlg Centered
         
         If lRet
            
            bProc := {|| EI100EnvXML(cExibeArq,cOrigem,cSBJusFat,cDirOrigem+cArquivo) }
            Processa(bProc,STR0183,STR0184,.T.)
			
			cDirDestino:= cDirEnviado + EI100Name(cPreemb) + "\"    //NCF - 07/01/2015
            If !CriaDiretorioEI100(cDirDestino)
               lRet:= .F.
               Break
            EndIf            

            If File(cDirOrigem+cArquivo)
               Do While .T.
                  If AvCpyFile(cDirOrigem+cArquivo,cDirDestino+cArquivo)
                     Exit
                  EndIf
               EndDo
            EndIf
            
			cArquivo := StrTran(cArquivo, "xml", "ret")
            hFile := EasyCreateFile(cDirOrigem + cArquivo , FC_READONLY)
            
            cLog := cArquivo + ENTER + DATETIME + ENTER + ENTER
            cLog += STR0185 + ENTER + cSBMsg + ENTER            
            
            If FWrite(hFile, cLog, Len(cLog)) < Len(cLog)
               MsgInfo(STR0186,STR0187)
               FClose(hFile)
               If File(cDirOrigem+cArquivo)
                  Do While .T.
                     If AvCpyFile(cDirOrigem+cArquivo ,cDirDestino+cArquivo)
                        Exit
                     EndIf
                  EndDo
               EndIf				
			   FErase(cDirOrigem + cArquivo)
            EndIf
            FClose(hFile)
            If File(cDirOrigem+cArquivo)
               Do While .T.
                  If AvCpyFile(cDirOrigem+cArquivo ,cDirDestino+cArquivo)
                     Exit
                  EndIf
               EndDo
            EndIf	   
         Else
            lTela := .F.
         EndIf
         
         EndDo  
   EndCase

End Sequence
Return lRet

/*
Fun��o    : EI100RetFiesp
Objetivo  : Gravar o status do retorno da integra��o ap�s o envio do arquivo para a Fiesp.
            Esta fun��o exibir� ao usu�rio as op��es de alterar o status do arquivo para aceito
            ou rejeitado.
            Quando for o retorno da declara��o do produto, ser� realizada a grava��o da data de validade.
Par�metros: 
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 27/11/2009
Obs.      :
*/

Function EI100RetFiesp(cOrigem)
Local bOk    := {|| lOk:= .T., oDlg:End()},;
      bCancel:= {|| lOk:= .F., oDlg:End()},;
      bRadio := {|x| If(PCount() > 0, nRadio:= x, nRadio)},;
      bGet   := {|x| If(PCount() > 0, cObs:= x, cObs)}
Local cAlias    := Alias(),;
      cTitulo   := "",;
      cObs      := "",;
      cTipoInteg:= ""
Local lRet:= .F.,;
      lOk := .F.
Local nRadio   := 1,;
      nInferior:= 250,;
      nDireita := 500,;
      nCont
Local oDlg,;
      oMultiGet
Default cOrigem := "FIESP"

Begin Sequence

   If (cAlias)->(EasyRecCount()) == 0
      MsgInfo(STR0081, cTitMsg) //N�o existem arquivos a serem enviados para este servi�o.
      lRet:= .F.
      Break
   EndIf

   cTipoInteg:= TipoIntegracaoEI100()
   If Empty(cTipoInteg)
      lRet:= .F.
      MsgInfo(STR0239,STR0240) //"N�o � poss�vel executar esta a��o na pasta selecionada." ### "Aten��o"
      Break
   EndIf
   
   If cTipoInteg == DECL_EXP //Se � declara��o do produto
      cTitMsg:= STR0060 //Declara��o do Produto
   Else //Se � fatura comercial - certificado de origem
      cTitMsg:= STR0061 //Fatura Comercial - C.Origem
   EndIf

   cTitulo:= STR0123 + AllTrim((cAlias)->E09_PREEMB) //Grava��o do retorno da integra��o Fiesp - processo: #####
   Define MsDialog oDlg Title cTitulo From 0, 0 To nInferior, nDireita Pixel Of oMainWnd

      TRadMenu():New(35, 10, {STR0121, STR0122}, bRadio, oDlg,,,,,,,, 50, 40,,,, .T.) //Aceitos, Rejeitados
      TSay():New(65, 10, {|| STR0037}, oDlg,,,,,, .T.) //Observa��es
      oMultiGet:= TMultiGet():New(75, 10, bGet, oDlg, 231, 30,,,,,, .T.)
      oMultiGet:lWordWrap:= .T.

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.) Centered


   If lOk
   
      //Atualiza��o do status da tabela E09
      E09->(DBSetOrder(2)) //E09_FILIAL + E09_ARQUIV + E09_PREEMB + E09_STATUS
      E09->(DBSeek(xFilial() + (cAlias)->E09_ARQUIV + (cAlias)->E09_PREEMB))

      Do Case
         Case nRadio == 1 //Aceitos

            //Se � declara��o de produtos, ser� exibida a tela para atualiza��o da data de validade - E10
            If cTipoInteg == DECL_EXP
               lRet:= AtuValidadeEI100((cAlias)->E09_PREEMB, (cAlias)->E09_ARQUIV)
            Else
               lRet:= .T.
            EndIf

            If lRet
               Begin Transaction
                  E09->(RecLock("E09", .F.))
                  E09->E09_STATUS:= ST_A
                  E09->E09_OBSERV:= StrTran(cObs, ENTER, " ")
                  E09->(MsUnlock())
               End Transaction
            EndIf

         Case nRadio == 2 //Rejeitados

            Begin Transaction
               E09->(RecLock("E09", .F.))
               E09->E09_STATUS:= ST_R
               E09->E09_OBSERV:= cObs
               E09->(MsUnlock())
            End Transaction
            lRet:= .T.

            //Se � declara��o de produtos, o campo E10_CHVE09 deve ser apagado para que seja gerado um
            //novo arquivo de integra��o, a partir do mesmo processo ou do de outro.
            If cTipoInteg == DECL_EXP

               //Carregar array aDeclProd com os produtos do processo posicionado a serem atualizados
               EI100VerifDeclProd(DECL_EXP, (cAlias)->E09_ARQUIV, (cAlias)->E09_PREEMB)

               /* Array aDeclProd:
                  Posi��o 1. o c�digo do produto,
                  Posi��o 2. o RecNo correspondente � tabela EE9
                  Posi��o 3. o RecNo correspondente � tabela E10 */
               For nCont:= 1 To Len(aDeclProd)
                  E10->(DBGoTo(aDeclProd[nCont][3]))

                  Begin Transaction
                     E10->(RecLock("E10", .F.))
                     E10->E10_CHVE09:= ""
                     E10->(MsUnlock())
                  End Transaction
               Next
            EndIf

         OtherWise
            lRet:= .F.
      End Case

      If lRet
         MsgInfo(STR0126, cTitMsg) //Opera��o finalizada com sucesso.
      EndIf
   EndIf

End Sequence
Return lRet

/*
Fun��o    : AtualizaStatusEI100
Objetivo  : Alterar o status do arquivo no banco de dados.
Par�metros: Status a ser gravado.
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 13/11/2009
Obs.      : O registro deve estar posicionado na tabela
*/
Static Function AtualizaStatusEI100(cStatus,cOri,cJustFat)
Local lRet:= .F.

Default cOri := "FIESP" 
Default cJustFat := ""

Begin Sequence

   If cStatus == ST_E .And. cOri == "FIESP"
      If !MsgYesNo(STR0071, cTitMsg) //Esta opera��o alterar� o status do arquivo para 'Enviado'. Deseja prosseguir?
         lRet:= .F.
         Break
      EndIf
   EndIf

   Begin Transaction
      E09->(RecLock("E09", .F.))
      If cStatus == ST_E
         E09->E09_USUAEN:= cUserName
         E09->E09_DATAEN:= dDataBase
         E09->E09_HORAEN:= Time()
      EndIf
      
      If cOri == "FIERGS" .And. E09->(FieldPos("E09_INFJUS")) # 0
         cCompJust := MSMM(E09->E09_INFJUS,AVSX3("E09_JUSTI",AV_TAMANHO),,,LERMEMO)
         If cCompJust # cJustFat
            M->E09_JUSTI := cJustFat
            MSMM(E09->E09_INFJUS,,,,EXCMEMO)
            MSMM(,AVSX3("E09_JUSTI",AV_TAMANHO),,M->E09_JUSTI,INCMEMO,,,"E09","E09_INFJUS")
         EndIf
      EndIf
      
      E09->E09_STATUS:= cStatus
      E09->(MsUnlock())
   End Transaction
   lRet:= .T.

End Sequence
Return lRet


/*
Fun��o    : ValidGeraArqEI100
Objetivo  : Verificar se j� existe arquivo gerado para este processo (com base na tabela E09).
            Caso possua arquivo com o status enviado, o usu�rio ser� informado e o arquivo n�o ser� gerado.
            Caso possua arquivo com o status n�o enviado, o usu�rio ser� informado e o sistema solicitar�
            a confirma��o do usu�rio antes da gera��o do arquivo. O arquivo gerado substituir� o existente,
            inclusive as informa��es da tabela.
            Caso o status do arquivo seja aceito ou n�o gerado e for declara��o do produto, a valida��o estar�
            por conta da data de validade da declara��o existente, sendo realizada na fun��o EI100VerifDeclProd.
            Quando o status do arquivo for aceito e for fatura comercial/ certificado de origem, o usu�rio ser�
            informado que o processo possui integra��o conclu�da e n�o gerar� novo arquivo.
            Arquivos com o status rejeitado ser�o recriados com o mesmo crit�rio de uma primeira gera��o.
            Esta fun��o tamb�m posiciona a tabela EEC e gera o nome do arquivo.
Par�metros: cIntegra��o: tipo de arquivo a ser gerado (FAT_CERT ou DECL_EXP)
            cChave: n�mero do embarque ou ...... que comp�e a chave da tabela E09 juntamente com o campo E09_ARQUIV
            cNomeArq: recebida por par�metro para que seja carregado como conte�do o CNPJ do exportador, valor
            que comp�e o nome do arquivo.
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 12/11/2009
Obs.      :
*/
Static Function ValidGeraArqEI100(cIntegracao, cChave, cNomeArq, cCPTec)
Local cFornecedor:= "",;
      cExtArq    := ".rem"
Local lRet:= .T.

Begin Sequence

   EEC->(DBSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
   If !EEC->(DBSeek(xFilial() + AvKey(cChave, "EEC_PREEMB")))
      lRet:= .F.
      Break
   EndIf
   
   //Montagem do nome do arquivo
   If !Empty(EEC->EEC_EXPORT)
      cFornecedor:= EEC->EEC_EXPORT + EEC->EEC_EXLOJA
   Else
      cFornecedor:= EEC->EEC_FORN + EEC->EEC_FOLOJA
   EndIf   

   SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
   If !SA2->(DBSeek(xFilial() + cFornecedor))
      MsgInfo(STR0003 + AllTrim(cFornecedor), cTitMsg) //Exportador/ produtor n�o encontrado: ###
      lRet:= .F.
      Break
   EndIf

   If Empty(SA2->A2_CGC)
      MsgInfo(STR0072 + AllTrim(cFornecedor), cTitMsg) //O CNPJ do exportador n�o foi informado. Atualize o cadastro: ###
      lRet:= .F.
      Break
   EndIf

   If cIntegracao == CO_FIERGS
      cNomeArq:= cIntegracao + cValToChar(cCPTec+".xml")
   Else
      cNomeArq:= AllTrim(SA2->A2_CGC) + cIntegracao + cExtArq
   EndIf
   
   If cIntegracao == CO_FIERGS
      cArqXML:= ""
      cQuery := ""     // LGS - 03/11/2015
      cQuery += "Select E09_ARQUIV, E09_PREEMB, E09_STATUS, E09_ID, E09_DATACR, E09_USUACR From " + RetSqlName("E09")
      cQuery += " Where D_E_L_E_T_ <> '*' And E09_PREEMB = '" + AvKey(AllTrim(cChave),"E09_PREEMB") + "' And "
      cQuery += " E09_ARQUIV Like '%" + cNomeArq + "' And E09_STATUS <> '" + ST_R + "'"
      
      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_E09", .T., .T.)

      WK_E09->(DbGoTop())
      Do While WK_E09->(!Eof())
         If WK_E09->E09_STATUS <> ST_R
            cArqXML := WK_E09->E09_ARQUIV
            Exit
         EndIf
         WK_E09->(DbSkip())
      EndDo      
      
      If Select("WK_E09") <> 0
         WK_E09->(DbCloseArea())
      EndIf
      
      If !Empty(cArqXML)
         cNomeArq := cArqXML
      Else
         cID := GetSXENum("E09", "E09_ID")
         ConfirmSX8()
         cNomeArq:= cID + cIntegracao + cValToChar(cCPTec+".xml")
      EndIf
      
   EndIf

   //Verifica se j� existe o arquivo para este processo
   E09->(DBSetOrder(2)) //E09_FILIAL + E09_ARQUIV + E09_PREEMB + E09_STATUS
   If E09->(DBSeek(xFilial() + AvKey(cNomeArq, "E09_ARQUIV") +;
            AvKey(AllTrim(cChave), "E09_PREEMB")))
          
      //Se existe arquivo com o status enviado, n�o ser� gerado outro
      If E09->E09_STATUS == ST_E

         MsgInfo(STR0073 + AllTrim(cChave) + STR0076 + DtoC(E09->E09_DATAEN) +; //O arquivo n�o ser� gerado pois o processo ### possui arquivo enviado em ###
                 STR0075 + AllTrim(E09->E09_USUAEN), cTitMsg) //pelo usu�rio ###

         lRet:= .F.
         Break
      EndIf

      //Se existe arquivo com o status n�o enviado, o sistema ir� sugerir a gera��o de um outro arquivo,
      //substituindo as informa��es do anterior, inclusive no hist�rico da tabela E09.
      If E09->E09_STATUS == ST_N

         lRet:= MsgYesNo(STR0077 + AllTrim(cChave) + STR0074 + DtoC(E09->E09_DATACR) +; //O processo ### possui arquivo gerado em ###
                         STR0075 + AllTrim(E09->E09_USUACR) + STR0078, cTitMsg) //pelo usu�rio ### com o Status 'N�o Enviado'. Deseja substitu�-lo?

         If !lRet
            Break
         EndIf
      EndIf 

      //Quando o status do arquivo for aceito o usu�rio ser� informado que o processo possui integra��o
      //conclu�da e n�o ser� gerado novo arquivo.
      If E09->E09_STATUS == ST_A //.And. cIntegracao == FAT_CERT
         If cIntegracao == CO_FIERGS
            MsgInfo(STR0188, cTitMsg) //"J� existe um certificado pela FIERGS para o processo e capitulo selecionados."
            lRet:= .F.
            Break
         Else
            MsgInfo(STR0133, cTitMsg) //O processo de integra��o com a Fiesp foi conclu�do para este embarque. O status do arquivo est� definido como 'A' - aceito.
            lRet:= .F.
            Break
         EndIf
      EndIf
   EndIf
 

   //Valida��es espec�ficas para o tipo de integra��o
   Do Case

      Case cIntegracao == DECL_EXP

           /* Verifica��o dos itens que precisam ser declarados.
              Esta fun��o preenche o array aDeclProd com os itens a serem declarados */
           If !EI100VerifDeclProd(cIntegracao, cNomeArq, EEC->EEC_PREEMB)
              lRet:= .F.
              Break
           EndIf
           
           If Len(aDeclProd) == 0
              MsgInfo(STR0083, cTitMsg) //Este processo n�o possui itens a serem declarados. Todos os itens possuem a Declara��o do Produto informada, com o vencimento v�lido at� a presente data ou aguardando a aprova��o da FIESP.
              lRet:= .F.
              Break
           EndIf

      Case cIntegracao == FAT_CERT
           
           E11->(DBSetOrder(1)) //E11_FILIAL + E11_CODACO
           E11->(DBSeek(xFilial() + cAcordoCom))
           
           //http://www.certificado.fiesp.com.br/ajuda/Acordos.asp
           If E11->E11_DOBRIG == "1" // Se � obrigat�ria a declara��o do produto antes de declarar o certificado de origem
              /* Verificar se � necess�rio declarar o produto antes de realizar a integra��o do C.O.
                 Esta fun��o preenche o array aDeclProd com os itens a serem declarados */
              If !EI100VerifDeclProd(cIntegracao, cNomeArq, EEC->EEC_PREEMB)
                 lRet:= .F.
                 Break
              EndIf
              
              If Len(aDeclProd) > 0
                 MsgInfo(STR0084, cTitMsg) //Este processo possui produtos n�o declarados ou com a data de validade da declara��o expirada. Envie a Declara��o de Produtos antes de prosseguir com esta opera��o.
                 lRet:= .F.
                 Break
              EndIf
           EndIf
      
      Case cIntegracao == CO_FIERGS
           
           If !EI100ValFiergs(EEC->EEC_PREEMB)
              lRet:= .F.
              Break
           EndIf

      OtherWise
         lRet:= .F.

   End Case
      
End Sequence
Return lRet



/*
Fun��o    : DeclExpLayoutEI100
Objetivo  : Criar aHeaders, aDetails e aFiller contendo o layout definido pela Fiesp para o envio de informa��es da
            Declara��o de Produtos.
            Cada array corresponde � uma linha do arquivo TXT. O c�digo de �rea (identifica��o do registro) ir�
            compor o nome do array para facilitar a sua identifica��o.
Par�metros:
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 16/11/2009
Obs.      :
*/

Static Function DeclExpLayoutEI100()
Local aHeader10:= {},;
      aHeader20:= {},;
      aHeader21:= {},;
      aHeader22:= {},;
      aDetail30:= {},;
      aDetail40:= {},;
      aTraill50:= {},;
      aTraill60:= {}
Local lRet:= .T.
Local nCont
Private aEmpImp:={}

Begin Sequence

   /* Estrutura:
                1 - T�tulo (definido pela Fiesp)
                2 - Campo correspondente no dicion�rio de dados do sistema.
                3 - Picture
                4 - Tamanho (quantidade de d�gitos definido pela Fiesp)
                5 - Decimais (definido pela Fiesp)
                6 - Tipo (caracteres num�ricos ou alfanum�ricos, definido pela Fiesp)
                7 - Arquivo (tabela)
                8 - Valor fixo, informado pela FIESP ou que ser� tratato antes de ser preenchido no aCols
                */


   /************
    Registro Header do Arquivo
    ****************************/
   AAdd(aHeader10, {STR0008,       Nil,, 002, 0, "N",   Nil,    "10"}) //Identifica��o do Registro
   AAdd(aHeader10, {STR0009,       Nil,, 005, 0, "N",   Nil, "00002"}) //Tipo de Arquivo
   AAdd(aHeader10, {STR0010,  "A2_CGC",, 014, 0, "N", "SA2",     Nil}) //CNPJ da Empresa
   AAdd(aHeader10, {STR0011, "A2_NOME",, 060, 0, "C", "SA2",     Nil}) //Raz�o Social da Empresa
   AAdd(aHeader10, {STR0012,       Nil,, 419, 0, "C",   Nil,      ""}) //Vazio

   //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
   If !DeclExpValidColEI100("10", aHeader10)
      lRet:= .F.
      Break
   EndIf


   /* Gera��o das informa��es do produto
      Array aDeclProd:
      Posi��o 1. o c�digo do produto,
      Posi��o 2. o RecNo correspondente � tabela EE9 */

   For nCont:= 1 To Len(aDeclProd)

      EE9->(DBGoTo(aDeclProd[nCont][2]))
      
      /************
       Registro Header da Declara��o - linha 1
       ****************************************/
      aHeader20:= {}
      AAdd(aHeader20, {STR0008,          Nil,, 002, 0, "N",   Nil,    "20"}) //Identifica��o do Registro
      AAdd(aHeader20, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",     Nil}) //C�digo da Declara��o
      AAdd(aHeader20, {STR0039,          Nil,, 010, 0, "C",   Nil,      ""}) //Classifica��o
      AAdd(aHeader20, {STR0085,          Nil,, 012, 3, "N",   Nil,      ""}) //Valor Fob M�nimo
      AAdd(aHeader20, {STR0086,          Nil,, 012, 3, "N",   Nil,      ""}) //Valor Fob M�ximo
      AAdd(aHeader20, {STR0040, "EE9_CODNOR",, 003, 0, "N", "EE9",     Nil}) //Norma de Origem
      AAdd(aHeader20, {STR0087,          Nil,, 001, 0, "N",   Nil,      ""}) //Empresa Fabricante
      AAdd(aHeader20, {STR0088,          Nil,, 014, 0, "N",   Nil,      ""}) //CNPJ do Fabricante
      AAdd(aHeader20, {STR0012,          Nil,, 436, 0, "C",   Nil,      ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !DeclExpValidColEI100("20", aHeader20)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro Header da Declara��o - linhas 2 e 3
       **********************************************/
      aHeader21:= {}
      AAdd(aHeader21, {STR0008, Nil,, 002, 0, "N",   Nil,    "21"}) //Identifica��o do Registro
      AAdd(aHeader21, {STR0025, Nil,, 498, 0, "C",   Nil,    "21"}) //Denomina��o

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !DeclExpValidColEI100("21", aHeader21)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro Header da Declara��o - linha 4 a 14
       **********************************************/
      aHeader22:= {}
      AAdd(aHeader22, {STR0008, Nil,, 002, 0, "N",   Nil,    "22"}) //Identifica��o do Registro
      AAdd(aHeader22, {STR0093, Nil,, 498, 0, "C",   Nil,    "22"}) //Processo Produtivo

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !DeclExpValidColEI100("22", aHeader22)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro Details (insumo nacional)
       ***********************************/
      aDetail30:= {}
      AAdd(aDetail30, {STR0008, Nil,, 002, 0, "N",   Nil,    "30"}) //Identifica��o do Registro
      AAdd(aDetail30, {STR0095, Nil,, 300, 0, "C",   Nil,      ""}) //Descri��o
      AAdd(aDetail30, {STR0012, Nil,, 198, 0, "C",   Nil,      ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !DeclExpValidColEI100("30", aDetail30)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro Details (insumo importados)
       *************************************/
      aDetail40:= {}
      AAdd(aDetail40, {STR0008,          Nil,             , 002, 0, "N",   Nil,    "40"}) //Identifica��o do Registro
      AAdd(aDetail40, {STR0099,          Nil,             , 001, 0, "C",   Nil,      ""}) //Origem do Insumo
      AAdd(aDetail40, {STR0100, "YA_CODFIES",             , 003, 0, "N", "SYA",      ""}) //Pa�s de Origem
      AAdd(aDetail40, {STR0039,          Nil,             , 010, 0, "C",   Nil,      ""}) //Classifica��o
      AAdd(aDetail40, {STR0095,          Nil,             , 300, 0, "C",   Nil,      ""}) //Descricao
      AAdd(aDetail40, {STR0101, "B1_VLCIF"  ,             , 012, 3, "N", "SB1",      ""}) //Valor CIF
      //o layout Fiesp define tamanho 7 para o percentual, 6 n�meros mais a v�rgula da picture
      AAdd(aDetail40, {STR0102,        Nil, "@R 999,999", 006, 3, "N",   Nil,      ""}) //Percentual de Participa��o
      AAdd(aDetail40, {STR0103,        Nil,             , 001, 0, "N",   Nil,      ""}) //Empresa importadora
      AAdd(aDetail40, {STR0104,        Nil,             , 014, 0, "C",   Nil,      ""}) //CNPJ da empresa importadora
      AAdd(aDetail40, {STR0012,        Nil,             , 150, 0, "C",   Nil,      ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !DeclExpValidColEI100("40", aDetail40)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro Trailler da declara��o
       **********************************/
      aTraill50:= {}
      AAdd(aTraill50, {STR0008,          Nil,, 002, 0, "N",   Nil,    "50"}) //Identifica��o do Registro
      AAdd(aTraill50, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",      ""}) //C�digo da Declara��o
      AAdd(aTraill50, {STR0012,          Nil,, 488, 0, "C",   Nil,      ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !DeclExpValidColEI100("50", aTraill50)
         lRet:= .F.
         Break
      EndIf
   Next

   /************
    Registro Trailler do arquivo    
    ******************************/
   aTraill60:= {}
   AAdd(aTraill60, {STR0008, Nil,, 002, 0, "N",   Nil,           "60"}) //Identifica��o do Registro
   AAdd(aTraill60, {STR0106, Nil,, 004, 0, "N",   Nil, Len(aDeclProd)}) //Quantidade de Declara��es
   AAdd(aTraill60, {STR0012, Nil,, 494, 0, "C",   Nil,             ""}) //Vazio

   //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
   If !DeclExpValidColEI100("60", aTraill60)
      lRet:= .F.
      Break
   EndIf

End Sequence
Return lRet



/*
Fun��o    : FatCertLayoutEI100
Objetivo  : Criar aHeaders, aDetails e aFiller contendo o layout definido pela Fiesp para o envio de informa��es de
            Certificados de Origem e Fatura Comercial.
            Cada array corresponde � uma linha do arquivo TXT. O c�digo de �rea (identifica��o do registro) ir�
            compor o nome do array para facilitar a sua identifica��o.
Par�metros:
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 29/10/2009
Obs.      :
*/

Static Function FatCertLayoutEI100()
Local lRet:= .T.
Local nOrdem:= 1
Local aHeader010:= {},;
      aHeader020:= {},;
      aHeader030:= {},;
      aDetail040:= {},;
      aTraill050:= {},;
      aHeader060:= {},;
      aDetail070:= {},;
      aTraill080:= {},;
      aHeader090:= {},;
      aHeader091:= {},;
      aHeader092:= {},;
      aHeader093:= {},;
      aHeader094:= {},;
      aItens100 := {},;
      aItens101 := {},;
      aTraill110:= {},;
      aTraill120:= {},;
      aTraill130:= {}

Begin Sequence

   /* Estrutura:
                1 - T�tulo (definido pela Fiesp)
                2 - Campo correspondente no dicion�rio de dados do sistema.
                3 - Picture
                4 - Tamanho (quantidade de d�gitos definido pela Fiesp)
                5 - Decimais (definido pela Fiesp)
                6 - Tipo (caracteres num�ricos ou alfanum�ricos, definido pela Fiesp)
                7 - Arquivo (tabela)
                8 - Valor fixo, informado pela FIESP ou que ser� tratato antes de ser preenchido no aCols
                */


   /************
    Header do Arquivo; informa��es da empresa
    *********************************************/
   AAdd(aHeader010, {STR0008,       Nil,, 003, 0, "N",   Nil,   "010"}) //Identifica��o do Registro
   AAdd(aHeader010, {STR0009,       Nil,, 005, 0, "N",   Nil, "00003"}) //Tipo de Arquivo
   AAdd(aHeader010, {STR0010,  "A2_CGC",, 014, 0, "N", "SA2",     Nil}) //CNPJ da Empresa
   AAdd(aHeader010, {STR0011, "A2_NOME",, 060, 0, "C", "SA2",     Nil}) //Raz�o Social da Empresa
   AAdd(aHeader010, {STR0012,       Nil,, 418, 0, "C",   Nil,      ""}) //Vazio

   //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
   If !FatCertValidColEI100("010", aHeader010)
      lRet:= .F.
      Break
   EndIf



   /************
    Registro Header do processo de certifica��o
    **********************************************/
   AAdd(aHeader020, {STR0008, Nil,, 003, 0, "N", Nil, "020"}) //Identifica��o do Registro
   AAdd(aHeader020, {STR0013, Nil,, 002, 0, "C", Nil,    ""}) //Acordo Comercial
   AAdd(aHeader020, {STR0014, Nil,, 001, 0, "C", Nil,    ""}) //Opera��o Triangular
   AAdd(aHeader020, {STR0012, Nil,, 494, 0, "C", Nil,    ""}) //Vazio
       
   //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
   If !FatCertValidColEI100("020", aHeader020)
      lRet:= .F.
      Break
   EndIf



   /************
    Registro Header da fatura do exportador
    ******************************************/
   AAdd(aHeader030, {STR0008,          Nil,, 003, 0, "N",   Nil,      "030"}) //Identifica��o do Registro
   AAdd(aHeader030, {STR0015, "EEC_IMPODE",, 060, 0, "C", "EEC",        Nil}) //Importador
   AAdd(aHeader030, {STR0016,          Nil,, 150, 0, "C",   Nil,         ""}) //Endere�o do Importador
   AAdd(aHeader030, {STR0017, "YA_CODFIES",, 003, 0, "N", "SYA",        Nil}) //Pa�s Importador
   AAdd(aHeader030, {STR0018, "EEC_NRINVO",, 030, 0, "C", "EEC",        Nil}) //N�mero da Fatura
   AAdd(aHeader030, {STR0019, "EEC_DTINVO",, 010, 0, "C", "EEC",        Nil}) //Data da Fatura
   AAdd(aHeader030, {STR0020,          Nil,, 012, 3, "N",   Nil,        Nil}) //Peso L�quido
   AAdd(aHeader030, {STR0021,          Nil,, 012, 3, "N",   Nil,        Nil}) //Peso Bruto
   AAdd(aHeader030, {STR0022, "EEC_TOTPED",, 012, 3, "N", "EEC",        Nil}) //Valor Total da Fatura
   AAdd(aHeader030, {STR0012,          Nil,, 208, 0, "C",   Nil,         ""}) //Vazio

   //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
   If !FatCertValidColEI100("030", aHeader030)
      lRet:= .F.
      Break
   EndIf



   /************
    Registro details dos itens da fatura do exportador
    *****************************************************/
   AAdd(aDetail040, {STR0008,          Nil,, 003, 0, "N",   Nil, "040"}) //Identifica��o do Registro
   AAdd(aDetail040, {STR0023, "EE9_SLDINI",, 012, 3, "N", "EE9",   Nil}) //Quantidade
   AAdd(aDetail040, {STR0024,  "AH_COD_CO",, 003, 0, "N", "SAH",   Nil}) //Unidade de Medida
   AAdd(aDetail040, {STR0025,          Nil,, 300, 0, "C",      ,    ""}) //Denomina��o
   AAdd(aDetail040, {STR0026, "EE9_PRCINC",, 012, 3, "N", "EE9",   Nil}) //Valor FOB
   AAdd(aDetail040, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",   Nil}) //C�digo da Declara��o
   AAdd(aDetail040, {STR0012,          Nil,, 160, 0, "C",   Nil,    ""}) //Vazio

   //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
   If !FatCertValidColEI100("040", aDetail040)
      lRet:= .F.
      Break
   EndIf


   /************
    Registro trailler da fatura do exportador
    *********************************************/
   AAdd(aTraill050, {STR0008,          Nil,, 003, 0, "N",   Nil, "050"}) //Identifica��o do Registro
   AAdd(aTraill050, {STR0018, "EEC_NRINVO",, 030, 0, "C", "EEC",   Nil}) //N�mero da Fatura
   AAdd(aTraill050, {STR0012,          Nil,, 467, 0, "C",   Nil,    ""}) //Vazio

   //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
   If !FatCertValidColEI100("050", aTraill050)
      lRet:= .F.
      Break
   EndIf

   //Se � opera��o triangular
   If cOpTriang == "1"

      /************
       Registro header da fatura do interveniente
       ***********************************************/
      AAdd(aHeader060, {STR0008, Nil,, 003, 0, "N",   Nil, "060"}) //Identifica��o do Registro
      AAdd(aHeader060, {STR0028, Nil,, 060, 0, "C",   Nil,    ""}) //Interveniente
      AAdd(aHeader060, {STR0029, Nil,, 150, 0, "C",   Nil,    ""}) //Endere�o do Interveniente
      AAdd(aHeader060, {STR0030, Nil,, 003, 0, "C",   Nil,    ""}) //Pa�s Interveniente
      AAdd(aHeader060, {STR0018, Nil,, 030, 0, "C",   Nil,    ""}) //N�mero da Fatura
      AAdd(aHeader060, {STR0019, Nil,, 010, 0, "C",   Nil,    ""}) //Data da Fatura
      AAdd(aHeader060, {STR0020, Nil,, 012, 3, "N",   Nil,    ""}) //Peso L�quido
      AAdd(aHeader060, {STR0021, Nil,, 012, 3, "N",   Nil,    ""}) //Peso Bruto
      AAdd(aHeader060, {STR0022, Nil,, 012, 3, "N",   Nil,    ""}) //Valor Total da Fatura
      AAdd(aHeader060, {STR0012, Nil,, 208, 3, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("060", aHeader060)
         lRet:= .F.
         Break
      EndIf



      /************
       Registro details dos itens da fatura do interveniente
       ******************************************************/
      AAdd(aDetail070, {STR0008,          Nil,, 003, 0, "N",   Nil, "070"}) //Identifica��o do Registro
      AAdd(aDetail070, {STR0023,          Nil,, 012, 0, "N",   Nil,   Nil}) //Quantidade
      AAdd(aDetail070, {STR0024,          Nil,, 003, 0, "N",   Nil,   Nil}) //Unidade de Medida
      AAdd(aDetail070, {STR0025,          Nil,, 300, 0, "C",   nil,    ""}) //Denomina��o
      AAdd(aDetail070, {STR0026,          Nil,, 012, 3, "N",   Nil,   Nil}) //Valor FOB
      AAdd(aDetail070, {STR0012,          Nil,, 170, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("070", aDetail070)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro trailler da fatura do interveniente
       ***********************************************/
      AAdd(aTraill080, {STR0008,          Nil,, 003, 0, "N",   Nil, "080"}) //Identifica��o do Registro
      AAdd(aTraill080, {STR0018,          Nil,, 030, 0, "C",   Nil,    ""}) //N�mero da Fatura
      AAdd(aTraill080, {STR0012,          Nil,, 467, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("080", aTraill080)
         lRet:= .F.
         Break
      EndIf

   EndIf

   //Se pertence � um dos acordos abaixo, o layout ter� a seguinte estrutura:
   If cAcordoCom $ "18/35/36/A3/59" //ACE18/ACE35/ACE36/ACE14-Automotivo/ACE59

      /************
       Registro header do certificado de origem - exportador
       ********************************************************/
      AAdd(aHeader090, {STR0008,          Nil,, 003, 0, "N",   Nil, "090"}) //Identifica��o do Registro
      AAdd(aHeader090, {STR0031,          Nil,, 300, 0, "C",   Nil,    ""}) //Endere�o/Pa�s do Exportador
      AAdd(aHeader090, {STR0032,   "Y9_DESCR",, 060, 0, "C", "SY9",   Nil}) //Porto ou local de embarque
      AAdd(aHeader090, {STR0033,   "YQ_DESCR",, 060, 0, "C", "SYQ",   Nil}) //Meio de Transporte
      AAdd(aHeader090, {STR0034, "EEC_RESPON",, 077, 0, "C", "EEC",   Nil}) //Assinante
       
      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("090", aHeader090)
         lRet:= .F.
         Break
      EndIf


      /*******************
       Registro header do certificado de origem - consignat�rio
       ***********************************************************/
      AAdd(aHeader092, {STR0008,          Nil,, 003, 0, "N",   Nil, "092"}) //Identifica��o do Registro
      AAdd(aHeader092, {STR0035,    "A1_NOME",, 060, 0, "C", "SA1",   Nil}) //Consignat�rio
      AAdd(aHeader092, {STR0036,   "YA_DESCR",, 300, 0, "C", "SYA",   Nil}) //Pa�s do Consignat�rio
      AAdd(aHeader092, {STR0012,          Nil,, 137, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("092", aHeader092)
         lRet:= .F.
         Break
      EndIf


      /*******************
       Registro header do certificado de origem - observa��o
       *********************************************************/
      AAdd(aHeader093, {STR0008, Nil,, 003, 0, "N",   Nil, "093"}) //Identifica��o do Registro
      AAdd(aHeader093, {STR0037, Nil,, 497, 0, "C",   Nil,    ""}) //Observa��es

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("093", aHeader093)
         lRet:= .F.
         Break
      EndIf


      EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
      EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))

      /* Para alguns acordos o usu�rio escolhe se quer gerar o C.O. com a quantidade ou o peso. Neste caso, o valor
         correspondente ser� gravado no array.
         Outros acordos � apenas a quantidade. O campo � informado no array.

      Pergunte para a escolha da classifica��o (ncm ou naladi) e do peso ou quantidade */
      If !Pergunte("EI100B", .T., STR0134 + STR0039 + " - " + STR0041) //Dados do produto: Classifica��o - Peso L�quido/ Quantidade
         lRet:= .F.
         Break
      EndIf

      While EE9->(!Eof()) .And.;
            EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + EEC->EEC_PREEMB


         aItens100:= {}
         /*******************
          Registro itens do certificado de origem
          *******************************************/
         AAdd(aItens100, {STR0008,          Nil,, 003, 0, "N",   Nil,       "100"}) //Identifica��o do Registro
         AAdd(aItens100, {STR0038,          Nil,, 004, 0, "N",   Nil, Str(nOrdem)}) //N�mero de Ordem
         AAdd(aItens100, {STR0039,          Nil,, 020, 0, "C",   Nil,          ""}) //Classifica��o; (NCM ou NALADI)
         AAdd(aItens100, {STR0040, "EE9_CODNOR",, 003, 0, "N", "EE9",         Nil}) //Norma de Origem
         AAdd(aItens100, {STR0041,          Nil,, 012, 3, "N",   Nil,         Nil}) //Peso L�quido/ Quantidade
         AAdd(aItens100, {STR0026, "EE9_PRCINC",, 012, 3, "N", "EE9",         Nil}) //Valor FOB
         AAdd(aItens100, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",          ""}) //C�digo da Declara��o
         AAdd(aItens100, {STR0012,          Nil,, 436, 0, "C",   Nil,          ""}) //Vazio

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("100", aItens100)
            lRet:= .F.
            Break
         EndIf


         aItens101:= {}
         /*******************
          Registro itens do certificado de origem - denomina��o
          ******************************************************/
         AAdd(aItens101, {STR0008, Nil,, 003, 0, "N",   Nil, "101"}) //Identifica��o do Registro
         AAdd(aItens101, {STR0025, Nil,, 300, 0, "C",   Nil,    ""}) //Denomina��o
         AAdd(aItens101, {STR0012, Nil,, 197, 0, "C",   Nil,    ""}) //Vazio

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("101", aItens101)
            lRet:= .F.
            Break
         EndIf

         nOrdem++
         EE9->(DBSkip())
      End


      /*******************
       Registro trailler do certificado de origem
       **********************************************/
      AAdd(aTraill110, {STR0008, Nil,, 003, 0, "N",   Nil, "110"}) //Identifica��o do Registro
      AAdd(aTraill110, {STR0012, Nil,, 497, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("110", aTraill110)
         lRet:= .F.
         Break
      EndIf

   ElseIf cAcordoCom $ "PT/58/53/55/62" //AARPTR04/ACE58/ACE43/ACE53/ACE55/ACE62 (O c�digo do ACE43 n�o est� no site da FIESP)
   
      /************
       Registro header do certificado de origem - exportador
       ********************************************************/
      AAdd(aHeader090, {STR0008,          Nil,, 003, 0, "N",   Nil, "090"}) //Identifica��o do Registro
      AAdd(aHeader090, {STR0031,          Nil,, 300, 0, "C",   Nil,    ""}) //Endere�o/Pa�s do Exportador
      AAdd(aHeader090, {STR0034, "EEC_RESPON",, 077, 0, "C", "EEC",   Nil}) //Assinante
      AAdd(aHeader090, {STR0012,          Nil,, 120, 0, "C",   Nil,    ""}) //Vazio       

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("090", aHeader090)
         lRet:= .F.
         Break
      EndIf


      /*******************
       Registro header do certificado de origem - observa��o
       *********************************************************/
      AAdd(aHeader093, {STR0008, Nil,, 003, 0, "N",   Nil, "093"}) //Identifica��o do Registro
      AAdd(aHeader093, {STR0037, Nil,, 497, 0, "C",   Nil,    ""}) //Observa��es

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("093", aHeader093)
         lRet:= .F.
         Break
      EndIf


      EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
      EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))

      /* Para alguns acordos o usu�rio escolhe se quer gerar o C.O. com a quantidade ou o peso. Neste caso, o valor
         correspondente ser� gravado no array.
         Outros acordos � apenas a quantidade. O campo � informado no array.

      Pergunte para a escolha da classifica��o (NCM ou Naladi) */
      If !Pergunte("EI100C", .T., STR0134 + STR0039) //Dados do produto: Classifica��o
         lRet:= .F.
         Break
      EndIf

      While EE9->(!Eof()) .And.;
            EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + EEC->EEC_PREEMB


         aItens100:= {}
         /*******************
          Registro itens do certificado de origem
          *******************************************/
         AAdd(aItens100, {STR0008,          Nil,, 003, 0, "N",   Nil,       "100"}) //Identifica��o do Registro
         AAdd(aItens100, {STR0038,          Nil,, 004, 0, "N",   Nil, Str(nOrdem)}) //N�mero de Ordem
         AAdd(aItens100, {STR0039,          Nil,, 020, 0, "C",   Nil,          ""}) //Classifica��o
         AAdd(aItens100, {STR0040, "EE9_CODNOR",, 003, 0, "N", "EE9",         Nil}) //Norma de Origem
         AAdd(aItens100, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",          ""}) //C�digo da Declara��o
         AAdd(aItens100, {STR0012,          Nil,, 460, 0, "C",   Nil,          ""}) //Vazio

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("100", aItens100)
            lRet:= .F.
            Break
         EndIf


         aItens101:= {}
         /*******************
          Registro itens do certificado de origem - denomina��o
          ******************************************************/
         AAdd(aItens101, {STR0008, Nil,, 003, 0, "N",   Nil, "101"}) //Identifica��o do Registro
         AAdd(aItens101, {STR0025, Nil,, 497, 0, "C",   Nil,    ""}) //Denomina��o

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("101", aItens101)
            lRet:= .F.
            Break
         EndIf

         nOrdem++
         EE9->(DBSkip())
      End

      /*******************
       Registro trailler do certificado de origem
       **********************************************/
      AAdd(aTraill110, {STR0008, Nil,, 003, 0, "N",   Nil, "110"}) //Identifica��o do Registro
      AAdd(aTraill110, {STR0012, Nil,, 497, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("110", aTraill110)
         lRet:= .F.
         Break
      EndIf

   ElseIf cAcordoCom $ "U2/A3" //ACE02/ACE14
   
      /************
       Registro header do certificado de origem - exportador
       ********************************************************/
      AAdd(aHeader090, {STR0008,          Nil,, 003, 0, "N",   Nil, "090"}) //Identifica��o do Registro
      AAdd(aHeader090, {STR0031,          Nil,, 300, 0, "C",   Nil,    ""}) //Endere�o/Pa�s do Exportador
      AAdd(aHeader090, {STR0034, "EEC_RESPON",, 077, 0, "C", "EEC",   Nil}) //Assinante
      AAdd(aHeader090, {STR0012,          Nil,, 120, 0, "C",   Nil,    ""}) //Vazio       

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("090", aHeader090)
         lRet:= .F.
         Break
      EndIf


      /*******************
       Registro header do certificado de origem - observa��o
       *********************************************************/
      AAdd(aHeader093, {STR0008, Nil,, 003, 0, "N",   Nil, "093"}) //Identifica��o do Registro
      AAdd(aHeader093, {STR0037, Nil,, 497, 0, "C",   Nil,    ""}) //Observa��es

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("093", aHeader093)
         lRet:= .F.
         Break
      EndIf


      EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
      EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))

      /* Para alguns acordos o usu�rio escolhe se quer gerar o C.O. com a quantidade ou o peso. Neste caso, o valor
         correspondente ser� gravado no array.
         Outros acordos � apenas a quantidade. O campo � informado no array.

      Pergunte para a escolha da classifica��o (NCM ou Naladi) */
      If !Pergunte("EI100C", .T., STR0134 + STR0039) //Dados do produto: Classifica��o
         lRet:= .F.
         Break
      EndIf

      While EE9->(!Eof()) .And.;
            EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + EEC->EEC_PREEMB


         aItens100:= {}
         /*******************
          Registro itens do certificado de origem
          *******************************************/
         AAdd(aItens100, {STR0008,          Nil,, 003, 0, "N",   Nil,       "100"}) //Identifica��o do Registro
         AAdd(aItens100, {STR0038,          Nil,, 004, 0, "N",   Nil, Str(nOrdem)}) //N�mero de Ordem
         AAdd(aItens100, {STR0039,          Nil,, 020, 0, "C",   Nil,          ""}) //Classifica��o
         AAdd(aItens100, {STR0040, "EE9_CODNOR",, 003, 0, "N", "EE9",         Nil}) //Norma de Origem
         AAdd(aItens100, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",          ""}) //C�digo da Declara��o
         AAdd(aItens100, {STR0012,          Nil,, 460, 0, "C",   Nil,          ""}) //Vazio

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("100", aItens100)
            lRet:= .F.
            Break
         EndIf


         aItens101:= {}
         /*******************
          Registro itens do certificado de origem - denomina��o
          ******************************************************/
         AAdd(aItens101, {STR0008, Nil,, 003, 0, "N",   Nil, "101"}) //Identifica��o do Registro
         AAdd(aItens101, {STR0025, Nil,, 497, 0, "C",   Nil,    ""}) //Denomina��o

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("101", aItens101)
            lRet:= .F.
            Break
         EndIf

         nOrdem++
         EE9->(DBSkip())
      End

      /*******************
       Registro trailler do certificado de origem
       **********************************************/
      AAdd(aTraill110, {STR0008, Nil,, 003, 0, "N",   Nil, "110"}) //Identifica��o do Registro
      AAdd(aTraill110, {STR0012, Nil,, 497, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("110", aTraill110)
         lRet:= .F.
         Break
      EndIf

   ElseIf cAcordoCom $ "AN" //ANEXO III
   
      /************
       Registro header do certificado de origem - exportador
       ********************************************************/
      AAdd(aHeader090, {STR0008,          Nil,, 003, 0, "N",   Nil, "090"}) //Identifica��o do Registro
      AAdd(aHeader090, {STR0031,          Nil,, 300, 0, "C",   Nil,    ""}) //Endere�o/Pa�s do Exportador
      AAdd(aHeader090, {STR0042,          Nil,, 004, 0, "N",   Nil,   "0"}) //N�mero de folhas
      AAdd(aHeader090, {STR0034, "EEC_RESPON",, 077, 0, "C", "EEC",   Nil}) //Assinante
      AAdd(aHeader090, {STR0012,          Nil,, 116, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("090", aHeader090)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro header do certificado de origem - produtor
       ******************************************************/
      AAdd(aHeader091, {STR0008,       Nil,, 003, 0, "N",   Nil, "091"}) //Identifica��o do Registro
      AAdd(aHeader091, {STR0043, "A2_NOME",, 060, 0, "C", "SA2",    ""}) //Produtor
      AAdd(aHeader091, {STR0044,       Nil,, 300, 0, "C",   Nil,    ""}) //Endere�o do Produtor
      AAdd(aHeader091, {STR0012,       Nil,, 137, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("091", aHeader091)
         lRet:= .F.
         Break
      EndIf


      EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
      EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))

      /* Para alguns acordos o usu�rio escolhe se quer gerar o C.O. com a quantidade ou o peso. Neste caso, o valor
         correspondente ser� gravado no array.
         Outros acordos � apenas a quantidade. O campo � informado no array.

      Pergunte para a escolha da classifica��o (NCM ou Naladi) */
      If !Pergunte("EI100C", .T., STR0134 + STR0039) //Dados do produto: Classifica��o
         lRet:= .F.
         Break
      EndIf

      While EE9->(!Eof()) .And.;
            EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + EEC->EEC_PREEMB


         aItens100:= {}
         /*******************
          Registro itens do certificado de origem
          *******************************************/
         AAdd(aItens100, {STR0008,          Nil,, 003, 0, "N",   Nil, "100"}) //Identifica��o do Registro
         AAdd(aItens100, {STR0039,          Nil,, 020, 0, "C",   Nil,    ""}) //Classifica��o
         AAdd(aItens100, {STR0045, "EE9_CODNOR",, 003, 0, "N", "EE9",    ""}) //Crit�rio de Origem
         AAdd(aItens100, {STR0023, "EE9_SLDINI",, 012, 3, "N", "EE9",    ""}) //Quantidade
         AAdd(aItens100, {STR0024, "AH_COD_COI",, 003, 0, "N", "SAH",    ""}) //Unidade de Medida
         AAdd(aItens100, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",    ""}) //C�digo da Declara��o
         AAdd(aItens100, {STR0012,          Nil,, 449, 0, "C",   Nil,    ""}) //Vazio

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("100", aItens100)
            lRet:= .F.
            Break
         EndIf


         aItens101:= {}
         /*******************
          Registro itens do certificado de origem - denomina��o
          ******************************************************/
         AAdd(aItens101, {STR0008, Nil,, 003, 0, "N",   Nil, "101"}) //Identifica��o do Registro
         AAdd(aItens101, {STR0025, Nil,, 497, 0, "C",   Nil,    ""}) //Denomina��o

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("101", aItens101)
            lRet:= .F.
            Break
         EndIf

         EE9->(DBSkip())
      End

      /*******************
       Registro trailler do certificado de origem
       **********************************************/
      AAdd(aTraill110, {STR0008, Nil,, 003, 0, "N",   Nil, "110"}) //Identifica��o do Registro
      AAdd(aTraill110, {STR0012, Nil,, 497, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("110", aTraill110)
         lRet:= .F.
         Break
      EndIf

   ElseIf cAcordoCom == "CP" //CAP52-55
   
      /************
       Registro header do certificado de origem - exportador
       ********************************************************/
      AAdd(aHeader090, {STR0008,          Nil,, 003, 0, "N",   Nil, "090"}) //Identifica��o do Registro
      AAdd(aHeader090, {STR0031,          Nil,, 300, 0, "C",   Nil,    ""}) //Endere�o/Pa�s do Exportador
      AAdd(aHeader090, {STR0034, "EEC_RESPON",, 077, 0, "C", "EEC",   Nil}) //Assinante
      AAdd(aHeader090, {STR0012,          Nil,, 120, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("090", aHeader090)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro header do certificado de origem - produtor
       ******************************************************/
      AAdd(aHeader091, {STR0008,       Nil,, 003, 0, "N",   Nil, "091"}) //Identifica��o do Registro
      AAdd(aHeader091, {STR0043, "A2_NOME",, 060, 0, "C", "SA2",    ""}) //Produtor
      AAdd(aHeader091, {STR0044,       Nil,, 300, 0, "C",   Nil,    ""}) //Endere�o do Produtor
      AAdd(aHeader091, {STR0012,       Nil,, 137, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("091", aHeader091)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro header do certificado de origem - transporte
       ******************************************************/
      AAdd(aHeader094, {STR0008,        Nil,, 003, 0, "N",   Nil, "094"}) //Identifica��o do Registro
      AAdd(aHeader094, {STR0033, "YQ_DESCR",, 060, 0, "C", "SYQ",    ""}) //Meio de Transporte
      AAdd(aHeader094, {STR0046,        Nil,, 300, 0, "C",   Nil,    ""}) //Rota/Itiner�rio
      AAdd(aHeader094, {STR0012,        Nil,, 137, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("094", aHeader094)
         lRet:= .F.
         Break
      EndIf


      EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
      EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))

      /* Para alguns acordos o usu�rio escolhe se quer gerar o C.O. com a quantidade ou o peso. Neste caso, o valor
         correspondente ser� gravado no array.
         Outros acordos � apenas a quantidade. O campo � informado no array.

      Pergunte para a escolha da classifica��o (ncm ou naladi) e do peso ou quantidade */
      If !Pergunte("EI100B", .T., STR0134 + STR0039 + " - " + STR0047) //Dados do produto: Classifica��o - Peso Bruto/Quantidade
         lRet:= .F.
         Break
      EndIf

      While EE9->(!Eof()) .And.;
            EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + EEC->EEC_PREEMB


         aItens100:= {}
         /*******************
          Registro itens do certificado de origem
          *******************************************/
         AAdd(aItens100, {STR0008,          Nil,, 003, 0, "N",   Nil,       "100"}) //Identifica��o do Registro
         AAdd(aItens100, {STR0038,          Nil,, 004, 0, "N",   Nil, Str(nOrdem)}) //N�mero de Ordem
         AAdd(aItens100, {STR0039,          Nil,, 020, 0, "C",   Nil,          ""}) //Classifica��o
         AAdd(aItens100, {STR0047,          Nil,, 012, 3, "N",   Nil,         Nil}) //Peso Bruto/Quantidade
         AAdd(aItens100, {STR0024, "AH_COD_COI",, 003, 0, "N", "SAH",          ""}) //Unidade de Medida
         AAdd(aItens100, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",          ""}) //C�digo da Declara��o
         AAdd(aItens100, {STR0012,          Nil,, 448, 0, "C",   Nil,          ""}) //Vazio

        //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("100", aItens100)
            lRet:= .F.
            Break
         EndIf


        aItens101:= {}
        /*******************
         Registro itens do certificado de origem - denomina��o
         ******************************************************/
         AAdd(aItens101, {STR0008, Nil,, 003, 0, "N",   Nil, "101"}) //Identifica��o do Registro
         AAdd(aItens101, {STR0025, Nil,, 497, 0, "C",   Nil,    ""}) //Denomina��o

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("101", aItens101)
            lRet:= .F.
            Break
         EndIf

         nOrdem++
         EE9->(DBSkip())
      End


      /*******************
       Registro trailler do certificado de origem
       **********************************************/
      AAdd(aTraill110, {STR0008, Nil,, 003, 0, "N",   Nil, "110"}) //Identifica��o do Registro
      AAdd(aTraill110, {STR0012, Nil,, 497, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("110", aTraill110)
         lRet:= .F.
         Break
      EndIf

   ElseIf cAcordoCom $ "SG/GT" //SGPC/GATT
   
      /************
       Registro header do certificado de origem - exportador
       ********************************************************/
      AAdd(aHeader090, {STR0008,          Nil,, 003, 0, "N",   Nil, "090"}) //Identifica��o do Registro
      AAdd(aHeader090, {STR0031,          Nil,, 300, 0, "C",   Nil,    ""}) //Endere�o/Pa�s do Exportador
      AAdd(aHeader090, {STR0034, "EEC_RESPON",, 077, 0, "C", "EEC",   Nil}) //Assinante
      AAdd(aHeader090, {STR0012,          Nil,, 120, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("090", aHeader090)
         lRet:= .F.
         Break
      EndIf


      /*******************
       Registro header do certificado de origem - consignat�rio
       ***********************************************************/
      AAdd(aHeader092, {STR0008,       Nil,, 003, 0, "N",   Nil, "092"}) //Identifica��o do Registro
      AAdd(aHeader092, {STR0035, "A1_NOME",, 060, 0, "C", "SA1",   Nil}) //Consignat�rio
      AAdd(aHeader092, {STR0048,       Nil,, 300, 0, "C",   Nil,   Nil}) //Endere�o/Pa�s do Consignat�rio
      AAdd(aHeader092, {STR0012,       Nil,, 137, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("092", aHeader092)
         lRet:= .F.
         Break
      EndIf


      /************
       Registro header do certificado de origem - transporte
       ******************************************************/
      AAdd(aHeader094, {STR0008,        Nil,, 003, 0, "N",   Nil, "094"}) //Identifica��o do Registro
      AAdd(aHeader094, {STR0033, "YQ_DESCR",, 060, 0, "C", "SYQ",    ""}) //Meio de Transporte
      AAdd(aHeader094, {STR0046,        Nil,, 300, 0, "C",   Nil,    ""}) //Rota/Itiner�rio
      AAdd(aHeader094, {STR0012,        Nil,, 137, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("094", aHeader094)
         lRet:= .F.
         Break
      EndIf


      EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
      EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))

      /* Para alguns acordos o usu�rio escolhe se quer gerar o C.O. com a quantidade ou o peso. Neste caso, o valor
         correspondente ser� gravado no array.
         Outros acordos � apenas a quantidade. O campo � informado no array.

      Pergunte para a escolha da classifica��o (NCM ou Naladi) */
      If !Pergunte("EI100C", .T., STR0134 + STR0039) //Dados do produto: Classifica��o
         lRet:= .F.
         Break
      EndIf

      While EE9->(!Eof()) .And.;
            EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + EEC->EEC_PREEMB


         aItens100:= {}
         /*******************
          Registro itens do certificado de origem
          *******************************************/
         AAdd(aItens100, {STR0008,          Nil,, 003, 0, "N",   Nil,       "100"}) //Identifica��o do Registro
         AAdd(aItens100, {STR0049,          Nil,, 004, 0, "N",   Nil, Str(nOrdem)}) //N�mero do Item
         AAdd(aItens100, {STR0039,          Nil,, 060, 0, "C",   Nil,          ""}) //Registro/N�mero de pacotes
         AAdd(aItens100, {STR0045, "EE9_CODNOR",, 003, 0, "N", "EE9",          ""}) //Crit�rio de Origem
         AAdd(aItens100, {STR0047,          Nil,, 012, 3, "N",   Nil,         Nil}) //Peso Bruto/Quantidade
         AAdd(aItens100, {STR0024,  "AH_COD_CO",, 003, 0, "N", "SAH",          ""}) //Unidade de Medida
         AAdd(aItens100, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",          ""}) //C�digo da Declara��o
         AAdd(aItens100, {STR0012,          Nil,, 405, 0, "C",   Nil,          ""}) //Vazio

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("100", aItens100)
            lRet:= .F.
            Break
         EndIf


         aItens101:= {}
         /*******************
          Registro itens do certificado de origem - denomina��o
          ******************************************************/
         AAdd(aItens101, {STR0008, Nil,, 003, 0, "N",   Nil, "101"}) //Identifica��o do Registro
         AAdd(aItens101, {STR0025, Nil,, 497, 0, "C",   Nil,    ""}) //Denomina��o

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("101", aItens101)
            lRet:= .F.
            Break
         EndIf

         nOrdem++
         EE9->(DBSkip())
      End

   
      /*******************
       Registro trailler do certificado de origem
       **********************************************/
      AAdd(aTraill110, {STR0008, Nil,, 003, 0, "N",   Nil, "110"}) //Identifica��o do Registro
      AAdd(aTraill110, {STR0012, Nil,, 497, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("110", aTraill110)
         lRet:= .F.
         Break
      EndIf

   ElseIf cAcordoCom == "CO" //COMUM

      /************
       Registro header do certificado de origem - exportador
       ********************************************************/
      AAdd(aHeader090, {STR0008,         Nil,, 003, 0, "N",   Nil, "090"}) //Identifica��o do Registro
      AAdd(aHeader090, {STR0031,         Nil,, 300, 0, "C",   Nil,    ""}) //Endere�o/Pa�s do Exportador
      AAdd(aHeader090, {STR0051, "Y9_CIDADE",, 030, 0, "C", "SY9",    ""}) //Cidade de Destino
      AAdd(aHeader090, {STR0052,  "YA_DESCR",, 050, 0, "C", "SYA",    ""}) //Pa�s de Destino
      AAdd(aHeader090, {STR0012,         Nil,, 117, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("090", aHeader090)
         lRet:= .F.
         Break
      EndIf


      /*******************
       Registro header do certificado de origem - consignat�rio
       ***********************************************************/
      AAdd(aHeader092, {STR0008,       Nil,, 003, 0, "N",   Nil, "092"}) //Identifica��o do Registro
      AAdd(aHeader092, {STR0035, "A1_NOME",, 060, 0, "C", "SA1",   Nil}) //Consignat�rio
      AAdd(aHeader092, {STR0048,       Nil,, 300, 0, "C",   Nil,   Nil}) //Endere�o/Pa�s do Consignat�rio
      AAdd(aHeader092, {STR0012,       Nil,, 137, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("092", aHeader092)
         lRet:= .F.
         Break
      EndIf


      /*******************
       Registro header do certificado de origem - observa��o
       *********************************************************/
      AAdd(aHeader093, {STR0008, Nil,, 003, 0, "N",   Nil, "093"}) //Identifica��o do Registro
      AAdd(aHeader093, {STR0037, Nil,, 497, 0, "C",   Nil,    ""}) //Observa��es

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("093", aHeader093)
         lRet:= .F.
         Break
      EndIf


       EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
       EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))

       /* Para alguns acordos o usu�rio escolhe se quer gerar o C.O. por quantidade ou o peso. Neste caso, o valor
          correspondente ser� gravado no array.
          Outros acordos � apenas a quantidade. O campo � informado no array.*/

       While EE9->(!Eof()) .And.;
             EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + EEC->EEC_PREEMB


         aItens100:= {}
         /*******************
          Registro itens do certificado de origem
          *******************************************/
         AAdd(aItens100, {STR0008,          Nil,, 003, 0, "N",   Nil, "100"}) //Identifica��o do Registro
         AAdd(aItens100, {STR0023, "EE9_SLDINI",, 012, 3, "N", "EE9",   Nil}) //Quantidade
         AAdd(aItens100, {STR0053, "EE9_EMBAL1",, 060, 0, "C", "EE9",   Nil}) //Embalagem
         AAdd(aItens100, {STR0020,          Nil,, 012, 3, "N",   Nil,   Nil}) //Peso L�quido
         AAdd(aItens100, {STR0021,          Nil,, 012, 3, "N",   Nil,   Nil}) //Peso Bruto
         AAdd(aItens100, {STR0027, "E10_DECLPR",, 010, 0, "C", "E10",    ""}) //C�digo da Declara��o
         AAdd(aItens100, {STR0012,          Nil,, 391, 0, "C",   Nil,    ""}) //Vazio

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("100", aItens100)
            lRet:= .F.
            Break
         EndIf


         aItens101:= {}
         /*******************
          Registro itens do certificado de origem - denomina��o
          ******************************************************/
         AAdd(aItens101, {STR0008, Nil,, 003, 0, "N",   Nil, "101"}) //Identifica��o do Registro
         AAdd(aItens101, {STR0025, Nil,, 497, 0, "C",   Nil,    ""}) //Denomina��o

         //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
         //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
         If !FatCertValidColEI100("101", aItens101)
            lRet:= .F.
            Break
         EndIf

         EE9->(DBSkip())
      End   

      /*******************
       Registro trailler do certificado de origem
       **********************************************/
      AAdd(aTraill110, {STR0008, Nil,, 003, 0, "N",   Nil, "110"}) //Identifica��o do Registro
      AAdd(aTraill110, {STR0012, Nil,, 497, 0, "C",   Nil,    ""}) //Vazio

      //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
      //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
      If !FatCertValidColEI100("110", aTraill110)
         lRet:= .F.
         Break
      EndIf
   EndIf

   /*******************
    Registro trailler do processo de certifica��o
    **********************************************/
   AAdd(aTraill120, {STR0008, Nil,, 003, 0, "N",   Nil, "120"}) //Identifica��o do Registro
   AAdd(aTraill120, {STR0013, Nil,, 002, 0, "C",   Nil,    ""}) //Acordo Comercial
   AAdd(aTraill120, {STR0012, Nil,, 495, 0, "C",   Nil,    ""}) //Vazio

   //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
   If !FatCertValidColEI100("120", aTraill120)
      lRet:= .F.
      Break
   EndIf

   /*************
    Registro trailler do arquivo
    ******************************/
   AAdd(aTraill130, {STR0008, Nil,, 003, 0, "N",   Nil, "130"}) //Identifica��o do Registro
   AAdd(aTraill130, {STR0054, Nil,, 004, 0, "N",   Nil,   "1"}) //Quantidade de processos de certifica��o - quantas vezes o "Header do Processo de Certifica��o" (020) se repete no arquivo. Sempre emitiremos um processo por arquivo.
   AAdd(aTraill130, {STR0012, Nil,, 493, 0, "C",   Nil,    ""}) //Vazio

   //Posicionamento das tabelas, valida��o da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Ap�s a valida��o, chama a fun��o GeraColEI100() para gravar as informa��es no aCols
   If !FatCertValidColEI100("130", aTraill130)
      lRet:= .F.
      Break
   EndIf

End Sequence

Return lRet

/*
Fun��o    : DeclExpValidColEI100
Objetivo  : Posicionar nas tabelas correspondentes, realizar as valida��es da linha do arquivo de integra��o e
            preencher a posi��o FIXO do array com as informa��es que devem ser manipuladas antes da grava��o dos dados
            no array principal (aCols).
            A linha � representada pelo c�digo da �rea recebida por par�metro.
Par�metros: cCodArea - c�digo da �rea da estrutura do arquivo formato DECL_EXP.
            aLayout - array aHeader, aDetail ou a Filler a ser manupilado.
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 16/11/2009
Obs.      : 
*/
Static Function DeclExpValidColEI100(cCodArea, aLayout)
Local cFornecedor:= "",;
      cProdutor  := "",;
      cDescricao := "",;
      cEmpImport := "",;
      cCodMemo
Local lRet:= .T.
Local nChave     := 0,;
      nTamDesc   := 0,;
      nPercentual:= 0.10,;
      nCont      := 0,;
      nQtdLinha  := 0,;
      nPos

Begin Sequence

   Do Case
      Case cCodArea == "10"

         SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA

         If !Empty(EEC->EEC_EXPORT)
            cFornecedor:= EEC->EEC_EXPORT + EEC->EEC_EXLOJA
         Else
            cFornecedor:= EEC->EEC_FORN + EEC->EEC_FOLOJA
         EndIf

         If !SA2->(DBSeek(xFilial() + cFornecedor))
            MsgInfo(STR0003, cTitMsg) //Exportador/ produtor n�o encontrado
            lRet:= .F.
            Break
         EndIf

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "20"

         //C�digo da declara��o do produto
         E10->(DBSetOrder(2)) //E10_FILIAL + E10_COD_I + E10_VLDECL
         E10->(DBSeek(xFilial() + EE9->EE9_COD_I + AvKey("", "E10_VLDECL")))

         //Classifica��o
         nChave:= AScan(aLayout, {|x| x[1] == STR0039}) //Classifica��o
         If nClassif == 1 //NCM
            aLayout[nChave][FIXO]:= EE9->EE9_POSIPI
            aLayout[nChave][PICT]:= X3Picture("EE9_POSIPI")
         Else //Naladi
            aLayout[nChave][FIXO]:= EE9->EE9_NALSH
            aLayout[nChave][PICT]:= X3Picture("EE9_NALSH")
         EndIf

         If Empty(aLayout[nChave][FIXO])
            MsgInfo(STR0113 + AllTrim(EE9->EE9_SEQEMB) + " - " + AllTrim(EE9->EE9_COD_I), cTitMsg) //C�digo NCM/ Naladi n�o informado. Atualize o processo de embarque antes de prosseguir. Item: #####
            lRet:= .F.
            Break
         EndIf

         //Valor FOB
         nChave:= AScan(aLayout, {|x| x[1] == STR0085}) //Valor Fob M�nimo
         aLayout[nChave][FIXO]:= EE9->EE9_PRECOI * (1 - nPercentual)

         nChave:= AScan(aLayout, {|x| x[1] == STR0086}) //Valor Fob M�ximo
         aLayout[nChave][FIXO]:= EE9->EE9_PRECOI * (1 + nPercentual)

         //Norma de Origem
         If Empty(EE9->EE9_CODNOR)
            MsgInfo(STR0112 + AllTrim(EE9->EE9_SEQEMB) + " - " + AllTrim(EE9->EE9_COD_I), cTitMsg) //A norma de origem n�o foi informada para o item abaixo. Atualize o processo de embarque antes de prosseguir. Item: ###########
            lRet:= .F.
            Break
         EndIf

         //Empresa Fabricante
         nChave:= AScan(aLayout, {|x| x[1] == STR0087}) //Empresa Fabricante

         If !Empty(EEC->EEC_EXPORT)
            cProdutor:= EEC->EEC_EXPORT + EEC->EEC_EXLOJA
         Else
            cProdutor:= EEC->EEC_FORN + EEC->EEC_FOLOJA
         EndIf

         If !Empty(EE9->EE9_FABR) .And. (EE9->EE9_FABR + EE9->EE9_FALOJA) <> cProdutor
            aLayout[nChave][FIXO]:= "2"
            cProdutor:= EE9->EE9_FABR + EE9->EE9_FALOJA
         Else
            aLayout[nChave][FIXO]:= "1"
         EndIf

         //CNPJ do Fabricante
         //O CNPJ ser� preenchido apenas quando o produto for fabricado por terceiros.
         If aLayout[nChave][FIXO] == "2"
            nChave:= AScan(aLayout, {|x| x[1] == STR0088}) //CNPJ do Fabricante
            SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
            SA2->(DBSeek(xFilial() + cProdutor))

            If Empty(SA2->A2_CGC)
               MsgInfo(STR0092 + AllTrim(SA2->A2_COD) + " - " + AllTrim(SA2->A2_NOME), cTitMsg) //O CNPJ do Fabricante/ Produtor n�o foi informado no cadastro. Favor atualizar antes de prosseguir: 
               lRet:= .F.
               Break
            Else
               aLayout[nChave][FIXO]:= SA2->A2_CGC
            EndIf
         Else
            nChave:= AScan(aLayout, {|x| x[1] == STR0088}) //CNPJ do Fabricante
            aLayout[nChave][FIXO]:= Replicate("0", aLayout[nChave][TAM])
         EndIf
         
         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "21"

         nChave:= AScan(aLayout, {|x| x[1] == STR0025}) //Denomina��o

         /* Descri��o do produto
            O campo �DENOMINA��O� possui um tamanho total de 996 caracteres. Para seu preenchimento completo,
            deve-se utilizar as 2 linhas dispon�veis para este registro, repetindo tamb�m o campo �IDENTIFICA��O
            DO REGISTRO� em todas as linhas.
            Para efeito de preenchimento de uma determinada linha, a linha imediatamente anterior deve estar
            completamente preenchida.*/

         nTamDesc:= 996
         cDescricao:= AllTrim(MSMM(EE9->EE9_DESC, nTamDesc,,, LERMEMO))
         cDescricao:= StrTran(cDescricao, ENTER, " ")         

         //Quantidade de linhas usadas para a descri��o do produto
         nQtdLinha:= QtdLinDescEI100(cDescricao, aLayout[nChave][TAM], nTamDesc)

         //Grava��o da linha no aCols
         For nCont:= 1 To nQtdLinha
            aLayout[nChave][FIXO]:= SubStr(cDescricao,;
                                          ((nCont * aLayout[nChave][TAM]) - aLayout[nChave][TAM]) + 1,; //Posi��o inicial
                                            nCont * aLayout[nChave][TAM]) //Posi��o final
            GeraColEI100(aLayout)
         Next

      Case cCodArea == "22"

         SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD
         SB1->(DBSeek(xFilial() + EE9->EE9_COD_I))
         /* O campo �PROCESSO PRODUTIVO� possui um tamanho total de 4980 caracteres. Para seu preenchimento
            completo, deve-se utilizar no m�ximo as 10 linhas dispon�veis para este registro, repetindo tamb�m
            o campo �IDENTIFICA��O DO REGISTRO� em todas as linhas.
            Para efeito de preenchimento de uma determinada linha, a linha imediatamente anterior deve estar
            completamente preenchida. */
         nTamDesc:= 4980
         nChave:= AScan(aLayout, {|x| x[1] == STR0093}) //Processo Produtivo

         If Empty(SB1->B1_CODPROC)
            MsgInfo(STR0094 + AllTrim(SB1->B1_COD), cTitMsg) //Um resumo do processo produtivo deve ser informado para este produto antes de prosseguir com a gera��o do arquivo. Acesse o cadastro do produto e atualize esta informa��o; produto 
            lRet:= .F.
            Break
         EndIf

         cDescricao:= AllTrim(MSMM(SB1->B1_CODPROC, aLayout[nChave][TAM],,, LERMEMO))
         cDescricao:= StrTran(cDescricao, ENTER, " ")

         //Quantidade de linhas usadas para a descri��o do processo produtivo
         nQtdLinha:= QtdLinDescEI100(cDescricao, aLayout[nChave][TAM], nTamDesc)

         //Grava��o da linha no aCols
         For nCont:= 1 To nQtdLinha
            aLayout[nChave][FIXO]:= SubStr(cDescricao,;
                                          ((nCont * aLayout[nChave][TAM]) - aLayout[nChave][TAM]) + 1,; //Posi��o inicial
                                            nCont * aLayout[nChave][TAM]) //Posi��o final
            GeraColEI100(aLayout)
         Next

      Case cCodArea == "30"

         //Verificar se existe a estrutura para o produto
         SG1->(DBSetOrder(1)) //G1_FILIAL + G1_COD + G1_COMP + G1_TRT
         SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD
         If !SG1->(DBSeek(xFilial() + EE9->EE9_COD_I))
            MsgInfo(STR0097 + AllTrim(EE9->EE9_COD_I) + STR0098, cTitMsg) //O produto #### n�o possui insumos cadastrados. Antes de prosseguir ser� necess�rio realizar o cadastro da estrutura deste produto.
            lRet:= .F.
            Break
         EndIf

         While SG1->(!Eof()) .And.;
               SG1->G1_COD == EE9->EE9_COD_I

            SB1->(DBSeek(xFilial() + SG1->G1_COMP))

            //Verifica se � produto nacional
            If SB1->B1_IMPORT == "N"
               
               //Descri��o
               nChave:= AScan(aLayout, {|x| x[1] == STR0095}) //Descri��o
               cCodMemo:= Posicione("EE2", 2, xFilial("EE2") + MC_CPRO + TM_GER +;
                                     AvKey(SB1->B1_COD, "EE2_COD") + PORTUGUES, "EE2_TEXTO")

               //Se n�o houver descri��o cadastrada no idioma, tenta outras alternativas do cadastro de produtos
               If Empty(cCodMemo)
                  cCodMemo:= SB1->B1_DESC_P
               EndIf
               cDescricao:= AllTrim(MSMM(cCodMemo, aLayout[nChave][TAM],,, LERMEMO))
               If Empty(cDescricao)
                  cDescricao:= SB1->B1_ESPECIF
               EndIf
               If Empty(cDescricao)
                  cDescricao:= AllTrim(SB1->B1_DESC)
               EndIf
               aLayout[nChave][FIXO]:= cDescricao

               //Grava��o da linha no aCols
               GeraColEI100(aLayout)
            EndIf

            SG1->(DBSkip())
         End

      Case cCodArea == "40"

         //Verificar se existe a estrutura para o produto
         SG1->(DBSetOrder(1)) //G1_FILIAL + G1_COD + G1_COMP + G1_TRT
         SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD
         SYA->(DBSetOrder(1)) //YA_FILIAL + YA_CODGI
         E10->(DBSetOrder(2)) //E10_FILIAL + E10_COD_I + E10_VLDECL
         SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA

         If !SG1->(DBSeek(xFilial() + EE9->EE9_COD_I))
            MsgInfo(STR0097 + AllTrim(EE9->EE9_COD_I) + STR0098, cTitMsg) //O produto #### n�o possui insumos cadastrados. Antes de prosseguir ser� necess�rio realizar o cadastro da estrutura deste produto.
            lRet:= .F.
            Break
         EndIf

         While SG1->(!Eof()) .And.;
               SG1->G1_COD == EE9->EE9_COD_I

            SB1->(DBSeek(xFilial() + SG1->G1_COMP))

            //Verifica se � insumo importado
            If SB1->B1_IMPORT == "S"

               //Classifica��o - NCM ou Naladi
               nChave:= AScan(aLayout, {|x| x[1] == STR0039}) //Classifica��o
               If nChave > 0
                  If nClassif == 1 //NCM
                     aLayout[nChave][FIXO]:= SB1->B1_POSIPI
                     aLayout[nChave][PICT]:= X3Picture("B1_POSIPI")
                  Else //Naladi
                     aLayout[nChave][FIXO]:= SB1->B1_NALSH
                     aLayout[nChave][PICT]:= X3Picture("B1_NALSH")
                  EndIf
               EndIf

               If Empty(aLayout[nChave][FIXO])
                  MsgInfo(STR0107 + AllTrim(SB1->B1_COD), cTitMsg) //C�digo NCM/ Naladi n�o informado. Atualiza o cadastro do produto: ###
                  lRet:= .F.
                  Break
               EndIf

               //Descri��o
               nChave:= AScan(aLayout, {|x| x[1] == STR0095}) //Descri��o
               cCodMemo:= Posicione("EE2", 2, xFilial("EE2") + MC_CPRO + TM_GER +;
                                     AvKey(SB1->B1_COD, "EE2_COD") + PORTUGUES, "EE2_TEXTO")

               //Se n�o houver descri��o cadastrada no idioma, tenta outras alternativas do cadastro de produtos
               If Empty(cCodMemo)
                  cCodMemo:= SB1->B1_DESC_P
               EndIf
               cDescricao:= AllTrim(MSMM(cCodMemo, aLayout[nChave][TAM],,, LERMEMO))
               If Empty(cDescricao)
                  cDescricao:= SB1->B1_ESPECIF
               EndIf
               If Empty(cDescricao)
                  cDescricao:= AllTrim(SB1->B1_DESC)
               EndIf
               aLayout[nChave][FIXO]:= cDescricao

               //Custo CIF
               If Empty(SB1->B1_VLCIF)
                  MsgInfo(STR0105 + AllTrim(SB1->B1_COD), cTitMsg) //O valor CIF do insumo n�o foi informado. O cadastro do produto deve ser atualizado antes de prosseguir: ###
                  lRet:= .F.
                  Break
               EndIf

               //Percentual de Participa��o
               //F�rmula para c�lculo: (Valor CIF * 100) / Valor Fob
               //Deve ser considerado o valor Fob m�nimo
               nChave:= AScan(aLayout, {|x| x[1] == STR0102}) //Percentual de Participa��o
               aLayout[nChave][FIXO]:= (SB1->B1_VLCIF * 100) / (EE9->EE9_PRECOI * (1 - nPercentual))

               //Empresa importadora
               nChave:= AScan(aLayout, {|x| x[1] == STR0103}) //Empresa importadora

               /* Ser� verificada na tabela SA5 a exist�ncia da amarra��o produto X fornecedor.
                  Caso haja mais que uma amarra��o, o usu�rio escolher� qual ser� considerada a empresa importadora.
                  A vari�vel cEmpImport ser� preenchida por refer�ncia. */
               //Tratamento para impedir que n�o seja solicitada a escolha da empresa importadora do insumo
               //quando o produto principal se repetir no processo.
               If (nPos:= AScan(aEmpImp, {|x| x[1] == EE9->EE9_COD_I + SB1->B1_COD})) == 0
                  If !VerifEmpImpInsumoEI100(SB1->B1_COD, @cEmpImport)
                     lRet:= .F.
                     Break
                  EndIf
                  //Armazena o produto e a empresa importadora, para que n�o seja exibida mais que uma vez
                  //o insumo de um mesmo produto que venha a se repetir no processo.
                  AAdd(aEmpImp, {EE9->EE9_COD_I + SB1->B1_COD, cEmpImport})
               Else
                  cEmpImport:= aEmpImp[nPos][2]
               EndIf

               If Empty(cEmpImport)
                  MsgInfo(STR0128 + AllTrim(SB1->B1_COD), cTitMsg) //O importador do insumo n�o foi informado. O cadastro de amarra��o do produto x fornecedor deve ser atualizado antes de prosseguir: ###
                  lRet:= .F.
                  Break
               EndIf
               
               If !Empty(EEC->EEC_EXPORT)
                  cFornecedor:= EEC->EEC_EXPORT + EEC->EEC_EXLOJA
               Else
                  cFornecedor:= EEC->EEC_FORN + EEC->EEC_FOLOJA
               EndIf

               If cEmpImport == cFornecedor
                  aLayout[nChave][FIXO]:= "1"
               Else
                  aLayout[nChave][FIXO]:= "2"
               EndIf

               //CNPJ da empresa importadora
               nChave:= AScan(aLayout, {|x| x[1] == STR0104}) //CNPJ da empresa importadora

               If cEmpImport == cFornecedor
                  aLayout[nChave][FIXO]:= Replicate("0", aLayout[nChave][TAM])
               Else
                  SA2->(DBSeek(xFilial() + cEmpImport))
                  If Empty(SA2->A2_CGC)
                     MsgInfo(STR0129 + AllTrim(SA2->A2_COD) + "/" + SA2->A2_LOJA, cTitMsg) //O CNPJ da empresa importadora do insumo n�o foi informado. Atualize o cadastro antes de prosseguir: ###
                     lRet:= .F.
                     Break
                  Else
                     aLayout[nChave][FIXO]:= SA2->A2_CGC
                  EndIf
               EndIf

               /*Origem do insumo
                 A origem do insumo ser� informada conforme o cadastro do seu fabricante.
                 Para isso, tamb�m na tabela de amarra��o produto x fornecedor deve ser informado qual o
                 fabricante do insumo. */
               nChave:= AScan(aLayout, {|x| x[1] == STR0099}) //Origem do Insumo

               SA5->(DBSetOrder(2)) //A5_FILIAL + A5_PRODUTO + A5_FORNECE + A5_LOJA
               SA5->(DBSeek(xFilial() + SB1->B1_COD + cEmpImport))

               If Empty(SA5->A5_FABR)
                  MsgInfo(STR0132 + AllTrim(SB1->B1_COD) + " X " + AllTrim(cEmpImport), cTitMsg) //Para identificar o pa�s de origem do insumo, o fabricante deve ser informado no cadastro amarra��o x fornecedor. Atualize o cadastro antes de prosseguir: " ####
                  lRet:= .F.
                  Break
               EndIf

               SA2->(DBSeek(xFilial() + SA5->A5_FABR + SA5->A5_FALOJA))
               If Empty(SA2->A2_PAIS)
                  MsgInfo(STR0127 + AllTrim(SA5->A5_FABR + "/" + SA5->A5_FALOJA), cTitMsg) //O pa�s de origem do insumo n�o foi informado. Atualize o cadastro do fabricante antes de prosseguir: ###
                  lRet:= .F.
                  Break
               EndIf
                  
               SYA->(DBSeek(xFilial() + SA2->A2_PAIS))
               If Empty(SYA->YA_CODFIES)
                  MsgInfo(STR0150 + SYA->YA_CODGI) //O c�digo do pa�s conforme a tabela Fiesp n�o foi informado. Atualize a tabela de pa�ses antes de prosseguir: ###
                  lRet:= .F.
                  Break
               EndIf

               /* Verificando se o insumo � origin�rio de estados partes (Mercosul) ou terceiros pa�ses.
                  Por pa�ses partes subentende os que fazem parte do acordo comercial vinculado ao processo.
                  Exemplo:
                     Se o acordo comercial for ACE18 e o pa�s de origem for a Argentina, o conte�do a ser
                     preenchido ser� "E" pois o pa�s pertence ao Mercosul e, por consequ�ncia, ao acordo.
                     No mesmo cen�rio, se o acordo comercial for ACE53 (Brasil-M�xico), o conte�do ser� "T".

                  Ser� verificado se o pa�s do insumo est� vinculado ao acordo comercial do produto principal.
                  Para isso, deve existir o relacionamento acordo x pa�s na tabela EXN. */

               EXN->(DBSetOrder(2)) //EXN_FILIAL + EXN_ACORDO + EXN_PAIS
               If EXN->(DBSeek(xFilial() + AvKey(cAcordoCom, "EXN_ACORDO") + SA2->A2_PAIS))
                  aLayout[nChave][FIXO]:= "E"
               Else
                  aLayout[nChave][FIXO]:= "T"
               EndIf

               //Grava��o da linha no aCols
               GeraColEI100(aLayout)
            EndIf

            SG1->(DBSkip())
         End

      Case cCodArea == "50"

         //C�digo da declara��o do produto
         E10->(DBSetOrder(2)) //E10_FILIAL + E10_COD_I + E10_VLDECL
         E10->(DBSeek(xFilial() + EE9->EE9_COD_I + AvKey("", "E10_VLDECL")))

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "60"

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      OtherWise
         MsgInfo(STR0006, cTitMsg) //C�digo da �rea n�o informado ou inv�lido
         lRet:= .F.
         Break
   EndCase
      
End Sequence         
Return lRet

/*
Fun��o    : FatCertValidColEI100
Objetivo  : Posicionar nas tabelas correspondentes, realizar as valida��es da linha do arquivo de integra��o e preencher
            a posi��o 7 do array com as informa��es que devem ser manipuladas antes da gera��o do arquivo.
            A linha � representada pelo c�digo da �rea recebida por par�metro.
Par�metros: cCodArea - c�digo da �rea da estrutura do arquivo formato FAT_CERT.
            aLayout - array aHeader, aDetail ou a Filler a ser manupilado.
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 28/10/2009
Obs.      :
*/
Static Function FatCertValidColEI100(cCodArea, aLayout)
Local lRet:= .T.
Local cFornecedor:= "",;
      cProdutor  := "",;
      cProdTemp  := "",;
      cDescricao := ""
Local nChave,;
      nTamDesc,;
      nCont

Begin Sequence

   Do Case
      Case cCodArea == "010"

         SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
         
         If !Empty(EEC->EEC_EXPORT)
            cFornecedor:= EEC->EEC_EXPORT + EEC->EEC_EXLOJA
         Else
            cFornecedor:= EEC->EEC_FORN + EEC->EEC_FOLOJA
         EndIf

         If !SA2->(DBSeek(xFilial() + cFornecedor))
            MsgInfo(STR0003, cTitMsg) //Exportador/ produtor n�o encontrado
            lRet:= .F.
            Break
         EndIf

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "020"

         //Preenchimento do conte�do fixo no aHeader
         nChave:= AScan(aLayout, {|x| x[1] == STR0013}) //Acordo Comercial
         aLayout[nChave][FIXO]:= cAcordoCom
         
         nChave:= AScan(aLayout, {|x| x[1] == STR0014}) //Opera��o Triangular
         aLayout[nChave][FIXO]:= cOpTriang

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "030"

         //Pa�s do importador
         SA1->(DBSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
         SA1->(DBSeek(xFilial() + EEC->EEC_IMPORT + EEC->EEC_IMLOJA))
         If Empty(SA1->A1_PAIS)
            MsgInfo(STR0004 + AllTrim(EEC->EEC_IMPORT + EEC->EEC_IMLOJA), cTitMsg) //O pa�s do importador n�o foi informado. Atualize o cadastro do importador antes de prossegir: ###
            //lRet:= .F.
            Break
         EndIf

         SYA->(DBSetOrder(1)) //YA_FILIAL + YA_CODGI
         SYA->(DBSeek(xFilial() + SA1->A1_PAIS))
         If Empty(SYA->YA_CODFIES)
            MsgInfo(STR0150 + SYA->YA_CODGI) //O c�digo do pa�s conforme a tabela Fiesp n�o foi informado. Atualize a tabela de pa�ses antes de prosseguir: ###
            lRet:= .F.
            Break
         EndIf


         //Preenchimento do conte�do fixo no aHeader
         //Endere�o do importador
         nChave:= AScan(aLayout, {|x| x[1] == STR0016}) //Endere�o do Importador
         aLayout[nChave][FIXO]:= AllTrim(EEC->EEC_ENDIMP) +;
                                 If (!Empty(EEC->EEC_END2IM), " - " + AllTrim(EEC->EEC_END2IM), "")

         //Verifica��o da unidade de medida da capa do processo
         nChave:= AScan(aLayout, {|x| x[1] == STR0020}) //Peso L�quido
         If !Empty(EEC->EEC_UNIDAD) .And. ! AvVldUn(EEC->EEC_UNIDAD) // MPG - 06/02/2018
            aLayout[nChave][FIXO]:= AvTransUnid(EEC->EEC_UNIDAD, "KG",, EEC->EEC_PESLIQ, .F.)
         Else
            aLayout[nChave][FIXO]:= EEC->EEC_PESLIQ
         EndIf

         nChave:= AScan(aLayout, {|x| x[1] == STR0021}) //Peso Bruto
         If !Empty(EEC->EEC_UNIDAD) .And. ! AvVldUn(EEC->EEC_UNIDAD) // MPG - 06/02/2018
            aLayout[nChave][FIXO]:= AvTransUnid(EEC->EEC_UNIDAD, "KG",, EEC->EEC_PESBRU, .F.)
         Else
            aLayout[nChave][FIXO]:= EEC->EEC_PESBRU
         EndIf

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "040"

         EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
         If !EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))
            MsgInfo(STR0005, cTitMsg) //Este processo n�o possui itens
            lRet:= .F.
            Break
         EndIf

         nChave:= AScan(aLayout, {|x| x[1] == STR0025}) //Denomina��o

         While EE9->(!Eof()) .And.;
               EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + EEC->EEC_PREEMB


            //Posicionamento na tabela de unidades de medidas
            SAH->(DBSetOrder(1)) //AH_FILIAL + AH_UNIMED
            SAH->(DBSeek(xFilial() + AvKey(EE9->EE9_UNIDAD, "AH_UNIMED")))

            If Empty(SAH->AH_COD_CO)
               MsgInfo(STR0096 + AllTrim(EE9->EE9_UNIDAD), cTitMsg) //O c�digo da unidade de medidas conforme a tabela FIESP n�o est� cadastrado. Verifique o cadastro desta unidade de medida antes de prosseguir: 
               lRet:= .F.
               Break
            EndIf

            //Descri��o do produto 
            cDescricao:= MSMM(EE9->EE9_DESC, aLayout[nChave][TAM],,, LERMEMO)
            aLayout[nChave][FIXO]:= cDescricao

            //Posicionamento na tabela para coletar o c�digo da declara��o de produtos
            E10->(DBSetOrder(2)) //E10_FILIAL + E10_COD_I + E10_VLDECL
            E10->(AVSeekLast(xFilial() + EE9->EE9_COD_I))

            //Grava��o da linha no aCols
            GeraColEI100(aLayout)

            EE9->(DBSkip())
         EndDo

      Case cCodArea == "050"

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)
            
      Case cCodArea == "060"

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "070"

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "080"

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "090"

         SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
         
         If !Empty(EEC->EEC_EXPORT)
            cFornecedor:= EEC->EEC_EXPORT + EEC->EEC_EXLOJA
         Else
            cFornecedor:= EEC->EEC_FORN + EEC->EEC_FOLOJA
         EndIf

         SA2->(DBSeek(xFilial() + cFornecedor))

         SYA->(DBSetOrder(1)) //YA_FILIAL + YA_CODGI
         SYA->(DBSeek(xFilial() + SA2->A2_PAIS))

         //Endere�o/Pa�s do Exportador
         nChave:= AScan(aLayout, {|x| x[1] == STR0031}) //Endere�o/Pa�s do Exportador
         If nChave > 0
            aLayout[nChave][FIXO]:= AllTrim(SA2->A2_END) + ;
                                    If (!Empty(SA2->A2_NR_END), ", "  + AllTrim(SA2->A2_NR_END), "") +;
                                    If (!Empty(SA2->A2_BAIRRO), ", "  + AllTrim(SA2->A2_BAIRRO), "") +;
                                    If (!Empty(SA2->A2_MUN)   , ", "  + AllTrim(SA2->A2_MUN)   , "") +;
                                    If (!Empty(SA2->A2_EST)   , " - " + AllTrim(SA2->A2_EST)   , "") +;
                                    If (!Empty(SYA->YA_DESCR) , " - " + AllTrim(SYA->YA_DESCR) , "")
         EndIf

         //Porto ou local de embarque
         If Empty(EEC->EEC_ORIGEM)
            MsgInfo(STR0110, cTitMsg) //O local de embarque (porto de origem) n�o foi informado no processo de exporta��o.
         EndIf
         
         SY9->(DBSetOrder(2)) //Y9_FILIAL + Y9_SIGLA
         SY9->(DBSeek(xFilial() + EEC->EEC_ORIGEM))

         //Meio de Transporte
         If Empty(EEC->EEC_VIA)
            MsgInfo(STR0111, cTitMsg) //A via de transporte n�o foi informada no processo de exporta��o.
         EndIf
         
         SYQ->(DBSetOrder(1)) //YQ_FILIAL + YQ_VIA
         SYQ->(DBSeek(xFilial() + EEC->EEC_VIA))

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "091"

         //Por padr�o, a vari�vel cProdutor iniciar� com os dados do pr�prio exportador.
         //Caso os campos EE9_FABR e EE9_FALOJA estiverem vazios, o primeiro valor v�lido ser� o conte�do da vari�vel cProdutor, 
         //caso contr�rio, cProdutor assumir� o conte�do dos campos EE9_FABR e EE9_FALOJA e passar� a acumular este conte�do em
         //cProdTemp para que n�o sejam geradas linhas com dados repetidos.
         
         If !Empty(EEC->EEC_EXPORT)
            cProdutor:= EEC->EEC_EXPORT + EEC->EEC_EXLOJA
         Else
            cProdutor:= EEC->EEC_FORN + EEC->EEC_FOLOJA
         EndIf

         SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
         EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
         EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))

         If !Empty(EE9->EE9_FABR) .And. (EE9->EE9_FABR + EE9->EE9_FALOJA) <> cProdutor
            cProdutor:= (EE9->EE9_FABR + EE9->EE9_FALOJA)
         EndIF

         //Busca dos dados do produtor/ fabricante
         While EE9->(!Eof()) .And.;
               EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + EEC->EEC_PREEMB

            If !(cProdutor $ cProdTemp)
               SA2->(DBSeek(xFilial() + cProdutor))
               
               nChave:= AScan(aLayout, {|x| x[1] == STR0044}) //Endere�o do Produtor
               aLayout[nChave][FIXO]:= AllTrim(SA2->A2_END) + ;
                                       If (!Empty(SA2->A2_NR_END), ", "  + AllTrim(SA2->A2_NR_END), "") +;
                                       If (!Empty(SA2->A2_BAIRRO), ", "  + AllTrim(SA2->A2_BAIRRO), "") +;
                                       If (!Empty(SA2->A2_MUN)   , ", "  + AllTrim(SA2->A2_MUN)   , "") +;
                                       If (!Empty(SA2->A2_EST)   , " - " + AllTrim(SA2->A2_EST)   , "") +;
                                       " - " + AllTrim(Posicione("SYA", 1, SYA->(xFilial()) + SA2->A2_PAIS, "YA_DESCR"))

               cProdTemp += cProdutor

               //Grava��o da linha no aCols
               GeraColEI100(aLayout)
            EndIf

            EE9->(DBSkip())
         End

      Case cCodArea == "092"

         //Consignat�rio
         SA1->(DBSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
         SA1->(DBSeek(xFilial() + EEC->EEC_CONSIG + EEC->EEC_COLOJA))

         //Pa�s do consignat�rio
         SYA->(DBSetOrder(1)) //YA_FILIAL + YA_CODGI
         SYA->(DBSeek(xFilial() + SA1->A1_PAIS))

         //Endere�o/Pa�s do Consignat�rio
         nChave:= AScan(aLayout, {|x| x[1] == STR0048}) //Endere�o/Pa�s do Consignat�rio
         If nChave > 0
            aLayout[nChave][FIXO]:= AllTrim(SA1->A1_END) + ;
                                    If (!Empty(SA1->A1_BAIRRO), ", "  + AllTrim(SA1->A1_BAIRRO), "") +;
                                    If (!Empty(SA1->A1_MUN)   , ", "  + AllTrim(SA1->A1_MUN)   , "") +;
                                    If (!Empty(SA1->A1_EST)   , " - " + AllTrim(SA1->A1_EST)   , "") +;
                                    If (!Empty(SYA->YA_DESCR) , " - " + AllTrim(SYA->YA_DESCR) , "")
         EndIf


         //Grava��o da linha no aCols
         GeraColEI100(aLayout)


      Case cCodArea == "093"

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "094"

         //Meio de Transporte
         SYQ->(DBSetOrder(1)) //YQ_FILIAL + YQ_VIA
         SYQ->(DBSeek(xFilial() + EEC->EEC_VIA))

         //Rota/Itiner�rio
         /* Ser� informado no arquivo de integra��o:
            Porto de origem: xxx, yyy; porto intermedi�rio: xxx, yyy; porto de destino: xxx, yyy;
            onde xxx � a cidade e yyy o estado. */
         nChave:= AScan(aLayout, {|x| x[1] == STR0046}) //Rota/Itiner�rio

         If nChave > 0

            //Porto ou local de embarque
            SY9->(DBSetOrder(2)) //Y9_FILIAL + Y9_SIGLA
            SY9->(DBSeek(xFilial() + EEC->EEC_ORIGEM))

            aLayout[nChave][FIXO] += STR0032 +; //Porto ou local de embarque
                                     If (!Empty(SY9->Y9_CIDADE), ": " + AllTrim(SY9->Y9_CIDADE), "") +;
                                     If (!Empty(SY9->Y9_ESTADO), ", " + AllTrim(SY9->Y9_ESTADO), "")

            //Porto intermedi�rio
            If !Empty(EEC->EEC_PTINT)
               SY9->(DBSeek(xFilial() + EEC->EEC_PTINT))
               aLayout[nChave][FIXO] += STR0056 +; //Porto intermedi�rio:
                                        If (!Empty(SY9->Y9_CIDADE),      + AllTrim(SY9->Y9_CIDADE), "") +;
                                        If (!Empty(SY9->Y9_ESTADO), ", " + AllTrim(SY9->Y9_ESTADO), "")
            EndIf

            //Porto destino
            SY9->(DBSeek(xFilial() + EEC->EEC_DEST))
            aLayout[nChave][FIXO] += STR0057 +; //Porto destino:
                                     If (!Empty(SY9->Y9_CIDADE),      + AllTrim(SY9->Y9_CIDADE), "") +;
                                     If (!Empty(SY9->Y9_ESTADO), ", " + AllTrim(SY9->Y9_ESTADO), "")
         EndIf

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "100"

         /* Para alguns acordos o usu�rio escolhe se quer gerar o C.O. com a quantidade ou o peso. Neste caso, o valor
            correspondente ser� gravado no array.
            Outros acordos � apenas a quantidade. O campo � informado no array.*/

         nChave:= AScan(aLayout, {|x| x[1] == STR0039}) //Classifica��o
         If nChave > 0
            If MV_PAR01 == 1 //NCM
               aLayout[nChave][FIXO]:= EE9->EE9_POSIPI
               aLayout[nChave][PICT]:= X3Picture("EE9_POSIPI")
            Else //Naladi
               aLayout[nChave][FIXO]:= EE9->EE9_NALSH
               aLayout[nChave][PICT]:= X3Picture("EE9_NALSH")
            EndIf
         EndIf

         If Empty(aLayout[nChave][FIXO])
            MsgInfo(STR0113 + AllTrim(EE9->EE9_SEQEMB) + " - " + AllTrim(EE9->EE9_COD_I), cTitMsg) //C�digo NCM/ Naladi n�o informado. Atualize o processo de embarque antes de prosseguir. Item: #####
            lRet:= .F.
            Break
         EndIf

         nChave:= AScan(aLayout, {|x| x[1] == STR0041}) //Peso L�quido/ Quantidade
         If nChave > 0
            //Os campos que se referem a pesos devem ser preenchidos com informa��es baseadas sempre em quilos
            If MV_PAR02 == 1 //peso
               If !Empty(EE9->EE9_UNPES) .And. ! AvVldUn(EE9->EE9_UNPES) // MPG - 06/02/2018
                  aLayout[nChave][FIXO]:= AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE9->EE9_PSLQTO, .F.)
               Else
                  aLayout[nChave][FIXO]:= EE9->EE9_PSLQTO
               EndIf

            Else //quantidade
               aLayout[nChave][FIXO]:= EE9->EE9_SLDINI
            EndIf
         EndIf

         nChave:= AScan(aLayout, {|x| x[1] == STR0047}) //Peso Bruto/Quantidade
         If nChave > 0
            //Os campos que se referem a pesos devem ser preenchidos com informa��es baseadas sempre em quilos
            If MV_PAR02 == 1 //peso
               If !Empty(EE9->EE9_UNPES) .And. ! AvVldUn(EE9->EE9_UNPES) // MPG - 06/02/2018
                  aLayout[nChave][FIXO]:= AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE9->EE9_PSBRTO, .F.)
               Else
                  aLayout[nChave][FIXO]:= EE9->EE9_PSBRTO
               EndIf

            Else //quantidade
               aLayout[nChave][FIXO]:= EE9->EE9_SLDINI
            EndIf
         EndIf

         nChave:= AScan(aLayout, {|x| x[1] == STR0020}) //Peso L�quido
         If nChave > 0
            //Os campos que se referem a pesos devem ser preenchidos com informa��es baseadas sempre em quilos
            If !Empty(EE9->EE9_UNPES) .And. ! AvVldUn(EE9->EE9_UNPES) // MPG - 06/02/2018
               aLayout[nChave][FIXO]:= AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE9->EE9_PSLQTO, .F.)
            Else
              aLayout[nChave][FIXO]:= EE9->EE9_PSLQTO
            EndIf
         EndIf

         nChave:= AScan(aLayout, {|x| x[1] == STR0021}) //Peso Bruto
         If nChave > 0
            //Os campos que se referem a pesos devem ser preenchidos com informa��es baseadas sempre em quilos
            If !Empty(EE9->EE9_UNPES) .And. ! AvVldUn(EE9->EE9_UNPES) // MPG - 06/02/2018
               aLayout[nChave][FIXO]:= AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE9->EE9_PSBRTO, .F.)
            Else
               aLayout[nChave][FIXO]:= EE9->EE9_PSBRTO
            EndIf
         EndIf

         nChave:= AScan(aLayout, {|x| x[1] == STR0024}) //Unidade de Medida
         If nChave > 0
            //Posicionamento na tabela de unidades de medidas
            SAH->(DBSetOrder(1)) //AH_FILIAL + AH_UNIMED
            SAH->(DBSeek(xFilial() + AvKey(EE9->EE9_UNIDAD, "AH_UNIMED")))

            If Empty(SAH->AH_COD_CO)
               MsgInfo(STR0096 + AllTrim(EE9->EE9_UNIDAD), cTitMsg) //O c�digo da unidade de medidas conforme a tabela FIESP n�o est� cadastrado. Verifique o cadastro desta unidade de medida antes de prosseguir: 
               lRet:= .F.
               Break
            EndIf

         EndIf

         //Posicionamento na tabela para coletar o c�digo da declara��o de produtos
         E10->(DBSetOrder(2)) //E10_FILIAL + E10_COD_I + E10_VLDECL
         E10->(AVSeekLast(xFilial() + EE9->EE9_COD_I))

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "101"

         //Descri��o do produto
         //Tratamento para as normas que permitem que o tamanho da descri��o seja de at� 700 caracteres.
         cDescricao:= AllTrim(MSMM(EE9->EE9_DESC, nTamDesc,,, LERMEMO))
         nChave:= AScan(aLayout, {|x| x[1] == STR0025}) //Denomina��o
         nTamDesc:= 700

         If !(cAcordoCom $ "18/35/36/A3/59") //ACE18/ACE35/ACE36/ACE14-Automotivo/ACE59

            /* O campo �DENOMINA��O� possui um tamanho total de 700 caracteres. Para seu preenchimento completo,
               deve-se utilizar as 2 linhas dispon�veis para este registro, repetindo tamb�m o campo
               �IDENTIFICA��O DO REGISTRO� em todas as linhas.
                Para efeito de preenchimento de uma determinada linha, a linha imediatamente anterior deve
                estar completamente preenchida. */

            //Quantidade de linhas usadas para a descri��o do produto
            nQtdLinha:= QtdLinDescEI100(cDescricao, aLayout[nChave][TAM], nTamDesc)

            //Grava��o da linha no aCols
            For nCont:= 1 To nQtdLinha
               aLayout[nChave][FIXO]:= SubStr(cDescricao,;
                                             ((nCont * aLayout[nChave][TAM]) - aLayout[nChave][TAM]) + 1,; //Posi��o inicial
                                               nCont * aLayout[nChave][TAM]) //Posi��o final
               //Grava��o da linha no aCols
               GeraColEI100(aLayout)
            Next
         Else
            aLayout[nChave][FIXO]:= cDescricao
            //Grava��o da linha no aCols
            GeraColEI100(aLayout)
         EndIf


      Case cCodArea == "110"

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "120"

         nChave:= AScan(aLayout, {|x| x[1] == STR0013}) //Acordo Comercial
         aLayout[nChave][FIXO]:= cAcordoCom

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      Case cCodArea == "130"

         //Grava��o da linha no aCols
         GeraColEI100(aLayout)

      OtherWise
         MsgInfo(STR0006, cTitMsg) //C�digo da �rea n�o informado ou inv�lido
         lRet:= .F.
         Break
   End Case

End Sequence

Return lRet

/*
Fun��o    : GeraColEI100
Objetivo  : Gravar no array aCols a linha do arquivo, conforme o layout Fiesp definido no array
            aHeader.
            Antes de gravar no aCols, as informa��es s�o gravadas na posi��o FIXO do aHeader.
Par�metros: aHeader da linha do arquivo txt a ser processado
Retorno   :
Autor     : Wilsimar Fabr�cio da Silva
Data      : 28/10/2009 
Obs.      : Estrutura do array aCols:
                                     {
                                      x.1 - Identifica��o do registro
                                      x.n - Informa��es da linha
                                     }
            Esta fun��o disponibiliza um ponto de entrada para a edi��o dos dados da linha antes
            da gera��o do arquivo de integra��o.
            A estrutura do array � a mesma, alterando apenas o seu tamanho.
            Cada linha � identificada pelo c�digo da �rea (identifica��o do registro) conforme
            o layout disponibilizado pela Fiesp.
            Exemplo de busca da linha:
            AScan(aHeader, {|x| x[FIXO] == "010"}) ou If (aHeader[1][FIXO] == "010")
            "010": identificador da primeira linha da declara��o da fatura comercial/
            certificado de origem.
*/
Static Function GeraColEI100(aHeader)
Local cAlias:= "",;
      cPad  := ""
Local xConteudo
Local nPos,;
      nCont,;
      nRecNo
Private aHeaderTemp:= {}

/* Estrutura aHeader:
             1 - T�tulo (definido pela Fiesp)
             2 - Campo correspondente no dicion�rio de dados do sistema
             3 - Picture
             3 - Tamanho (quantidade de d�gitos definido pela Fiesp)
             4 - Decimais (definido pela Fiesp)
             5 - Tipo (caracteres num�ricos ou alfanum�ricos, definido pela Fiesp)
             6 - Arquivo (tabela)
             7 - Valor fixo, informado pela FIESP ou que ser� tratato antes de ser preenchido no aCols */

Begin Sequence

   AAdd(aCols, Array(Len(aHeader)))
   nPos:= Len(aCols)

   For nCont:= 1 To Len(aHeader)

      //Caracter a ser usado pelo Pad, ao definir os tamanhos dos registros
      If aHeader[nCont][TIPO] == "N"
         cPad:= "0"
      Else
         cPad:= ""
      EndIf

      //Se n�o houver o campo correspondente no dicion�rio de dados, ir� preencher com  valor fixo da posi��o FIXO do array.
      If Empty(aHeader[nCont][ARQ])
         xConteudo:= aHeader[nCont][FIXO]
      Else
         cAlias:= aHeader[nCont][ARQ]
         xConteudo:= (cAlias)->&(aHeader[nCont][CAMPO])
      EndIf

      //Se o conte�do for num�rico, arredonda as casas decimais conforme as defini��es da Fiesp
      If ValType(xConteudo) == "N"

         //O tamanho � somado com um devido ao ponto (separador de decimais)
         xConteudo:= AllTrim(Str(Round(xConteudo, aHeader[nCont][DEC]), aHeader[nCont][TAM] + 1, aHeader[nCont][DEC]))
         xConteudo:= StrTran(xConteudo, ".", "")

      //Se for data, formata como DD/MM/AAAA
      ElseIf ValType(xConteudo) == "D"
         xConteudo:= Padl(Day(xConteudo), 2, "0") + "/" + Padl(Month(xConteudo), 2, "0") + "/" + Padl(Year(xConteudo), 4)

      Else
         xConteudo:= StrTran(AllTrim(xConteudo), ENTER, " ")
      EndIf


      //Fixa��o do tamanho do conte�do que ser� gravado no arquivo txt
      If cPad == "0"
         xConteudo:= Padl(xConteudo, aHeader[nCont][TAM], cPad)

         //Picture
         //A fun��o Transform elimina os espa�os em branco.
         If !Empty(aHeader[nCont][PICT])
            xConteudo:= Transform(xConteudo, aHeader[nCont][PICT])
         EndIf
      Else
         //Picture
         //A fun��o Transform elimina os espa�os em branco.
         If !Empty(aHeader[nCont][PICT])
            xConteudo:= Transform(xConteudo, aHeader[nCont][PICT])
         EndIf

         xConteudo:= Padr(xConteudo, aHeader[nCont][TAM], cPad)
      EndIf

      aHeader[nCont][FIXO]:= xConteudo

      /* Ponto de entrada para altera��o dos valores da linha antes da grava��o no arquivo TXT.
         O ponto de entrada deve alterar a posi��o FIXO (7) do array aHeaderTemp.*/
      
      If EasyEntryPoint("EECEI100")

         nRecNo:= EE9->(RecNo())
         aHeaderTemp:= AClone(aHeader)

         ExecBlock("EECEI100", .F., .F., "ALTERA_ARRAY")

         EE9->(DBGoTo(nRecNo))
         aHeader:= AClone(aHeaderTemp)

      EndIf
            
      AAdd(aDados, AClone(aHeader[nCont]))
      aCols[nPos][nCont]:= aHeader[nCont][FIXO]
      
   Next

End Sequence
Return

/*
Fun��o    : FiespCriaTxtEI100
Objetivo  : Gera��o dos arquivos TXT, com base no array aCols.
Par�metros: cDirTxt - diret�rio para a cria��o do arquivo TXT
            cNomeTxt - nome do arquivo TXT (com a extens�o)
            aCols - array com os dados a serem escritos no arquivo TXT
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 
Obs.      :
*/
Static Function FiespCriaTxtEI100(cDirTxt, cNomeTxt, aCols)
Local cBuffer := "",;
      cMsg    := "",;
      cNomeVis:= ""
Local hFile
Local lRet:= .T.
Local nCont1,;
      nCont2,;
      nLinha

Begin Sequence


   //Arquivo para visualiza��o
   nLinha:= 1
   cBuffer:= STR0160 + ENTER //Obs.: para os campos quantidade e valor, os tr�s �ltimos d�gitos devem ser considerados como decimais.
   For nCont1:= 1 To Len(aDados)
      If aDados[nCont1][TITULO] == STR0008 //Identifica��o do Registro
         cBuffer += ENTER
         cBuffer += STR0153 + StrZero(nLinha++, 3) + ENTER //Linha ###
      EndIf

      cBuffer += aDados[nCont1][TITULO]
      cBuffer += ": "
      cBuffer += aDados[nCont1][FIXO]
      cBuffer += ENTER
   Next

   If MsgYesNo(STR0152, cTitMsg) //Deseja visualizar o arquivo de integra��o antes de concluir a gera��o?
      If !VisualArqEI100(cBuffer)
         lRet:= .F.
         Break
      EndIf
   EndIf

   cNomeVis:= SubStr(cNomeTxt, 1, At(".", cNomeTxt) - 1) + ".txt"

   hFile:= EasyCreateFile(cDirTxt + cNomeVis, FC_READONLY)

   If hFile == -1
      cMsg:= DescErroEI100(FError())
      MsgInfo(STR0108 + cMsg, cTitMsg) //O arquivo n�o pode ser criado. FError()
      lRet:= .F.
      Break
   EndIf

   If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
      cMsg:= DescErroEI100(FError())
      MsgInfo(STR0109 + cMsg, cTitMsg) //O arquivo n�o pode ser gravado. FError()
      lRet:= .F.
      Break
   EndIf

   FClose(hFile)


   //Arquivo de integra��o
   hFile:= EasyCreateFile(cDirTxt + cNomeTxt, FC_READONLY)
   cBuffer:= ""

   If hFile == -1
      cMsg:= DescErroEI100(FError())
      MsgInfo(STR0108 + cMsg, cTitMsg) //O arquivo n�o pode ser criado. FError()
      lRet:= .F.
      Break
   EndIf

   For nCont1:= 1 To Len(aCols)
      For nCont2:= 1 To Len(aCols[nCont1])
      
         cBuffer += aCols[nCont1][nCont2]
      Next
      cBuffer += ENTER
   Next

   If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
      cMsg:= DescErroEI100(FError())
      MsgInfo(STR0109 + cMsg, cTitMsg) //O arquivo n�o pode ser gravado. FError()
      lRet:= .F.
      Break
   EndIf

   FClose(hFile)

   MsgInfo(STR0007, cTitMsg) //Arquivo gerado com sucesso
End Sequence
Return lRet

/*
Fun��o    : CriaDiretorioEI100
Objetivo  : Cria o diret�rio para armazenar os arquivos de integra��o
Par�metros: cDirTxt - diret�rio para a cria��o do arquivo TXT
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 29/10/2009
Obs.      :
*/
Static Function CriaDiretorioEI100(cDirTxt)
Local cDirTemp:= ""
Local nPos
Local lRet:= .T.

Begin Sequence

   //Verifica��o da exist�ncia de cada diret�rio para cria��o
   If !lIsDir(cDirTxt)

      nPos:= At("\", cDirTxt)
      cDirTemp:= Lower(SubStr(cDirTxt, 1, nPos))
      cDirTxt := Lower(SubStr(cDirTxt, nPos + 1, Len(cDirTxt)))
      
      If AllTrim(cDirTemp) == "\"   //LGS-24/12/2014
         nPos     := At("\", cDirTxt)
         cDirTemp += SubStr(cDirTxt, 1, nPos)
         cDirTxt  := SubStr(cDirTxt, nPos + 1, Len(cDirTxt))
      EndIf

      While nPos > 0

         If !lIsDir(cDirTemp)
            MakeDir(cDirTemp)
         EndIf

         nPos:= At("\", cDirTxt)

         cDirTemp += SubStr(cDirTxt, 1, nPos)
         cDirTxt  := SubStr(cDirTxt, nPos + 1, Len(cDirTxt))
   
      End
      cDirTxt:= cDirTemp
   EndIf

   If !lIsDir(cDirTxt)
      MsgInfo(STR0002 + cDirTxt, cTitMsg) //N�o foi poss�vel criar o diret�rio ###
      lRet:= .F.
   EndIf

End Sequence
Return lRet


/*
Fun��o    : TipoIntegracaoEI100
Objetivo  : Verificar qual o tipo de arquivo de integra��o ser� gerado: fatura comercial - certificado de origem ou declara��o de produto
Par�metros: 
Retorno   : cOpc: o tipo de integra��o, com base na Work posicionada na central de integra��es.
Autor     : Wilsimar Fabr�cio da Silva
Data      : 11/11/2009
Obs.      :
*/

Static Function TipoIntegracaoEI100()
Local cAlias:= Alias()

Begin Sequence

   Do Case
      Case DECL_EXP $ cAlias
         cOpc:= DECL_EXP
      Case FAT_CERT $ cAlias
         cOpc:= FAT_CERT
      Case CO_FIERGS $ cAlias
         cOpc:= CO_FIERGS
      OtherWise
         cOpc:= ""
   End Case

End Sequence
Return cOpc


/*
Fun��o    : FiespAtuE09EI100
Objetivo  : Grava��o dos dados da gera��o do arquivo na tabela de hist�ricos
Par�metros: Nome do arquivo: obrigat�rio;
            Tipo de integra��o: se � fatura/ certificado de origem ("CO") ou declara��o de produtos ("DE")
            Embarque:
Retorno   :
Autor     : Wilsimar Fabr�cio da Silva
Data      : 11/11/2009
Obs.      :
*/
Static Function FiespAtuE09EI100(cArquivo, cTipo, cPreemb, cID, cOri)
Local cAlias:= "E09"
Local lInclui:= .F.

Begin Sequence

   (cAlias)->(DBSetOrder(2)) //E09_FILIAL + E09_ARQUIV + E09_PREEMB + E09_STATUS

   //Se o registro n�o existe na tabela, ser� criado outro
   lInclui:= !(cAlias)->(DBSeek(xFilial(cAlias) + AvKey(cArquivo, "E09_ARQUIV") + cPreemb))

   //Se o registro existir, ser� criado outro apenas se o status atual for 'R' - rejeitado
   If !lInclui .And. (cAlias)->E09_STATUS == ST_R
      lInclui:= .T.
   EndIf

   Begin Transaction
      (cAlias)->(RecLock(cAlias, lInclui))

      (cAlias)->E09_FILIAL:= xFilial(cAlias)
      (cAlias)->E09_ARQUIV:= cArquivo
      (cAlias)->E09_TIPO  := cTipo
      (cAlias)->E09_STATUS:= ST_N
      (cAlias)->E09_PREEMB:= cPreemb
      (cAlias)->E09_USUACR:= cUserName
      (cAlias)->E09_DATACR:= dDataBase
      (cAlias)->E09_HORACR:= Time()
      
      If cOri == "FIERGS"
         (cAlias)->E09_ID := cID
      EndIf

      (cAlias)->(MSUnlock())
   End Transaction
End Sequence
Return


/*
Fun��o    : FiespAtuE10EI100
Objetivo  : Gravar a chave do primeiro arquivo gerado com este c�digo de declara��o.
            Com esta chave ser� poss�vel validar a exclus�o/ altera��o dos dados da tabela E10,
            com base no status do arquivo.
Par�metros: Nome do arquivo e n�mero do embarque
Retorno   :
Autor     : Wilsimar Fabr�cio da Silva
Data      : 25/11/2009
Obs.      :
*/
Static Function FiespAtuE10EI100(cArquivo, cPreemb)
Local nCont

Begin Sequence

   /* Array aDeclProd:
      Posi��o 1. o c�digo do produto,
      Posi��o 2. o RecNo correspondente � tabela EE9
      Posi��o 3. o RecNo correspondente � tabela E10
   O array aDeclProd ter� conte�do apenas quando o produto n�o tiver c�digo de declara��o, ou seja,
   sempre ser� realizada apenas a grava��o do primeiro arquivo gerado para a integra��o */

   Begin Transaction
      For nCont:= 1 To Len(aDeclProd)

         E10->(DBGoTo(aDeclProd[nCont][3]))
         E10->(RecLock("E10", .F.))
         E10->E10_CHVE09:= cArquivo + cPreemb
         E10->(MsUnlock())
      Next
   End Transaction

End Sequence
Return


/*
Fun��o    : EI100VerifDeclProd
Objetivo  : Verificar quais os produtos do processo possuem o cadastro da "declara��o do produto" e a validade
            dentro do prazo definido (tabela E10). Os itens que n�o se enquadrarem nestas condi��es dever�o ser
            declarados, sendo adicionados no array private aDeclProd. Esta fun��o tamb�m verificar� se o produto
            possui arquivo gerado atrav�s de outro processo, evitando a redund�ncia de envio de declara��o, e
            permitir� que o usu�rio realize o cadastro dos produtos que n�o possuem o c�digo da declara��o,
            quando a chamada da fun��o for realizada da a��o "Declara��o de Produtos".
            Cadastro X Validade X Arquivo gerado por outro processo
            Ser�o declarados produtos com:
            1. c�digo da declara��o, sem validade e sem arquivo gerado;
            2. c�digo da declara��o, sem validade e com arquivo gerado pelo mesmo processo: ser� considerado que
               na fun��o ValidGeraArqEI100 o usu�rio optou por recriar o arquivo.
            Ser�o cadastrados os produtos com (quando a fun��o que chamou for para a declara��o de produtos):
            1. c�digo da declara��o e validade vencida;
            2. sem o c�digo da declara��o.         
Par�metros: cIntegracao: vari�vel que indica se a chamada foi feita para a declara��o do produto ou para a
            declara��o da fatura comercial e certificado de origem.
            cNomeArq: nome do arquivo que ser� criado
            cPreemp: processo de embarque
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 16/11/2009
Obs.      : Carrega o array private aDeclProd com os dados dos produtos que precisam ser declarados
            conforme segue:
            Posi��o 1. o c�digo do produto,
            Posi��o 2. o RecNo correspondente � tabela EE9
            Posi��o 3. o RecNo correspondente � tabela E10
*/
Function EI100VerifDeclProd(cIntegracao, cNomeArq, cPreemb)
Local lPrimeira:= .T.,;
      lAdd:= .F.
      lRet:= .T.

Begin Sequence

   //Zera o array antes de iniciar o processamento
   aDeclProd:= {}

   EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
   E10->(DBSetOrder(2)) //E10_FILIAL + E10_COD_I + E10_VLDECL

   EE9->(DBSeek(xFilial() + cPreemb))

   While EE9->(!Eof()) .And.;
         EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + cPreemb


      //Se possui o cadastro, a data de validade n�o foi preenchida e n�o foi gerado arquivo
      //para integra��o atrav�s de outro processo, o produto deve ser declarado.
      If E10->(DBSeek(xFilial() + EE9->EE9_COD_I + AvKey("", "E10_VLDECL"))) .And. Empty(E10->E10_CHVE09)

         //Indica que o registro ser� declarado
         lAdd:= .T.

      //Se o usu�rio optou por recriar o arquivo de declara��o do produto, o sistema permitir� a gera��o de um
      //novo arquivo caso o nome do arquivo seja o mesmo (referente ao mesmo processo)
      ElseIf E10->(DBSeek(xFilial() + EE9->EE9_COD_I + AvKey("", "E10_VLDECL"))) .And. !Empty(E10->E10_CHVE09)

         //Indica que o registro ser� declarado
         lAdd:= .T.
         
         //Se a chamada foi realizada da a��o "Declara��o da Fatura/ Certificado de Origem", o usu�rio ser�
         //informado que o produto est� aguardando o envio do arquivo da declara��o do produto ou a aprova��o
         //da FIESP e o arquivo n�o ser� gerado.
         If cIntegracao == FAT_CERT
            MsgInfo(STR0117 + ENTER +; //Este processo possui item(ns) com o c�digo da declara��o do produto aguardando a aprova��o da FIESP ou o envio do arquivo da declara��o do produto. Consulte os seguintes dados antes de prosseguir: 
                    STR0118 + " :" + AllTrim(EE9->EE9_COD_I) + ENTER +; //Produto #####
                    STR0060 + " :" + AllTrim(E10->E10_DECLPR) + ENTER +; //Declara��o do Produto ######
                    STR0080 + AllTrim(SubStr(E10->E10_CHVE09, 1, 20)), cTitMsg) //Arquivo: ########
            lRet:= .F.
            Break
         EndIf
         
      /* Se n�o existe declara��o para o produto ou a declara��o est� vencida, ser� necess�rio
         cadastrar uma nova declara��o */
      ElseIf !E10->(AvSeekLast(xFilial() + EE9->EE9_COD_I)) .Or.;
             (!Empty(E10->E10_VLDECL) .And. E10->E10_VLDECL < dDataBase)

         //Se a chamada foi realizada para a declara��o do produto, permite ao usu�rio realizar o cadastro dos
         //c�digos da declara��o para os itens que n�o possuem.
         If cIntegracao == DECL_EXP

            If lPrimeira
               If !MsgYesNo(STR0089, cTitMsg) //Existe um ou mais itens sem o c�digo da declara��o do produto informado ou com a validade expirada. Caso queira prosseguir, ser�(�o) exibido(s) o(s) produto(s) para que seja informado um novo c�digo de declara��o. Caso opte por n�o prosseguir, ser� necess�rio rever o cadastro antes de gerar o arquivo para a integra��o. Deseja prosseguir?
                  lRet:= .F.
                  Break
               EndIf
               lPrimeira:= .F.
            EndIf

            //Cadastro do c�digo da declara��o do produto
            If !EI101Man("E10", 0, INCLUIR)
               lRet:= .F.
               Break
            EndIf
         EndIf

         //Itens com declara��o e sem data de validade
         //Indica que o registro ser� declarado
         lAdd:= .T.

      EndIf

      If lAdd
         //Tratamento que impede que o mesmo produto seja declarado mais que uma vez
         If AScan(aDeclProd, {|x| x[1] == EE9->EE9_COD_I}) == 0
            AAdd(aDeclProd, {EE9->EE9_COD_I, EE9->(RecNo()), E10->(RecNo())})
         EndIf                                                               
         lAdd:= .F.
      EndIf

      EE9->(DBSkip())
   End

End Sequence
Return lRet


/*
Fun��o    : QtdLinDescEI100
Objetivo  : Calcular o n�mero de linhas que ser�o gerados para a descri��o
Par�metros: String com a descri��o,
            Quantidade de caracteres por linha,
            Quantidade total de caracteres.
Retorno   : Quantidade de linhas
Autor     : Wilsimar Fabr�cio da Silva
Data      : 18/11/2009
Obs.      :
*/
Static Function QtdLinDescEI100(cDesc, nTamLinha, nTamTotal)
Local nQtdLinha:= 0,;
      nTotLinha:= 0

Begin Sequence

   //Quantidade de linhas geradas pela descri��o
   If Len(cDesc)/nTamLinha > Int(Len(cDesc)/nTamLinha)
      nQtdLinha:= Int(Len(cDesc)/nTamLinha) + 1
   Else
      nQtdLinha:= Int(Len(cDesc)/nTamLinha)
   EndIf

   //Quantidade de linhas permitidas pelo layout Fiesp
   If nTamTotal/nTamLinha > Int(nTamTotal/nTamLinha)
      nTotLinha:= Int(nTamTotal/nTamLinha) + 1
   Else
      nTotLinha:= Int(nTamTotal/nTamLinha)
   EndIf

   //Quantidade de linhas geradas para a descri��o
   If nQtdLinha > nTotLinha
      nQtdLinha:= nTotLinha
   EndIf

   If nQtdLinha < 1
      nQtdLinha:= 1
   EndIf

End Sequence
Return nQtdLinha


/*
Fun��o    : AtuValidadeEI100
Objetivo  : Atualizar a data de validade das declara��es de produtos
Par�metros: Processo de embarque
            Nome do arquivo
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 24/11/2009
Obs.      :
*/
Static Function AtuValidadeEI100(cPreemb, cArquivo)
Local bOk    := {|| nOpc:= 1, If(lRet:= VerifDtValEI100(dDataVal), oDlg:End(), Nil)},;
      bCancel:= {|| nOpc:= 0, lRet:= .F., oDlg:End()},;
      bGet   := {|x| If(PCount() > 0, dDataVal:= x, dDataVal)}
Local dDataVal:= CtoD("")
Local lRet:= .T.
Local nOpc,;
      nCont,;
      nInferior:= 100,;
      nDireita := 500
Local oDlg

Begin Sequence

   Define MsDialog oDlg Title If(!lFiergs,STR0066,STR0189) From 0, 0 To nInferior, nDireita Pixel Of oMainWnd //Integra��o FIESP - COOL

      TSay():New(10,  30, {|| STR0114}, oDlg,,,,,, .T.) //Informe a data de validade para as declara��es enviadas:
      TGet():New(9, 175, bGet, oDlg, 40, 08,,,,,,,, .T.)

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered


   If nOpc == 1

      //Carregar array aDeclProd com os produtos do processo posicionado a serem atualizados
      EI100VerifDeclProd(DECL_EXP, cArquivo, cPreemb)

      If Len(aDeclProd) == 0
         MsgInfo(STR0116, cTitMsg) //N�o foram encontradas declara��es de produtos referente � este processo que precisem de atualiza��o.
         lRet:= .F.
         Break
      EndIf

      Begin Transaction
         For nCont:= 1 To Len(aDeclProd)

            /* Array aDeclProd:
               Posi��o 1. o c�digo do produto,
               Posi��o 2. o RecNo correspondente � tabela EE9
               Posi��o 3. o RecNo correspondente � tabela E10 */

            E10->(DBGoTo(aDeclProd[nCont][3]))
            E10->(RecLock("E10", .F.))
            E10->E10_VLDECL:= dDataVal
            E10->(MsUnlock())
         Next
      End Transaction
   EndIf

End Sequence
Return lRet


/*
Fun��o    : VerifEmpImpInsumoEI100
Objetivo  : Listar os fornecedores do insumo para que o usu�rio escolha qual � a empresa importadora
            a ser considerada na declara��o do produto.
Par�metros: C�digo do produto
            cEmpImport - vari�vel recebida por refer�ncia que armazenar� o c�difo e loja da empresa
            importadora do insumo.
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 01/12/2009
Obs.      :
*/
Static Function VerifEmpImpInsumoEI100(cCodProd, cEmpImport)
Local aItens:= {}
Local bList  := {|x| If(Pcount() > 0, cEmpImport:= x, cEmpImport)},;
      bOk    := {|| oDlg:End()},;
      bCancel:= {|| lRet:= .F., oDlg:End()}
Local lRet:= .T.
Local nInferior:= 200,;
      nDireita := 400,;
      nCont
Local oDlg,;
      oList

Begin Sequence

   //Coletando os dados dos fornecedores do insumo
   SA5->(DBSetOrder(2)) //A5_FILIAL + A5_PRODUTO + A5_FORNECE + A5_LOJA
   If SA5->(DBSeek(xFilial() + cCodProd))

      While SA5->(!Eof()) .And.;
            SA5->A5_FILIAL + SA5->A5_PRODUTO == SA5->(xFilial()) + cCodProd

         /* Layout aItens:
            1. C�digo do fornecedor + Loja do fornecedor + Nome do fornecedor */

         AAdd(aItens, SA5->A5_FORNECE + SA5->A5_LOJA + " " + ;
              Posicione("SA2", 1, SA2->(xFilial()) + SA5->A5_FORNECE + SA5->A5_LOJA, "A2_NOME"))

         SA5->(DBSkip())
      End

   EndIf

   If Len(aItens) == 1
      cEmpImport:= aItens[1]
   Else

      //Cria��o da tela para que o usu�rio possa escolher qual o importador do insumo
      Define MsDialog oDlg Title STR0130 + AllTrim(EE9->EE9_COD_I) From 0, 0 To nInferior, nDireita Pixel Of oMainWnd //Sele��o da Empresa Importadora - produto base ###

         TSay():New(5, 30, {|| STR0131 + AllTrim(cCodProd)}, oDlg,,,,,, .T.) //Selecione uma empresa importadora para o insumo ###
         oList:= TListBox():New(15, 20, bList, aItens, 160, 50,, oDlg,,,, .T.,, bOk)
         //oList:Select(1)

      Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered
   
   EndIf

   cEmpImport:= SubStr(cEmpImport, 1, Len(SA5->A5_FORNECE + SA5->A5_LOJA))
End Sequence
Return lRet

/*
Fun��o    : VerifDtValEI100
Objetivo  : Validar a data de validade informada
Par�metros: Data de validade informada pelo usu�rio
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 27/11/2009
Obs.      :
*/
Static Function VerifDtValEI100(dDataVal)
Local lRet:= .T.

Begin Sequence

   If Empty(dDataVal) .Or. dDataVal < dDataBase
      MsgInfo(STR0125, cTitMsg) //A data de validade informada deve ser igual ou posterior a data atual.
      lRet:= .F.
      Break
   EndIf

End Sequence
Return lRet

/*
Fun��o    : VerifAcordoEI100
Objetivo  : Listar os acordos comerciais existentes para o processo de exporta��o com base no c�digo da norma
            gravado no item do processo, quando houver mais de um acordo comercial vinculado.
Par�metros: N�mero do embarque
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 07/12/2009
Obs.      :
*/
Static Function VerifAcordoEI100(cPreemb)
Local aItens   := {},;
      aCodNorma:= {},;
      aAcordo  := {}
Local bList  := {|x| If(Pcount() > 0, cAcordoCom:= x, cAcordoCom)},;
      bOk    := {|| oDlg:End()},;
      bCancel:= {|| lRet:= .F., oDlg:End()}
Local lRet:= .T.
Local nInferior:= 230,;
      nDireita := 400,;
      nCont
Local oDlg,;
      oList

Begin Sequence

   //Coletando os c�digos das normas existentes nos itens do processo
   EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
   EE9->(DBSeek(xFilial() + cPreemb))

   While EE9->(!Eof()) .And.;
         EE9->EE9_FILIAL + EE9->EE9_PREEMB == EE9->(xFilial()) + cPreemb

      //Se o c�digo da norma estiver preenchido adiciona-o no array, caso j� n�o tenha sido.
      If !Empty(EE9->EE9_CODNOR) .And.;
         AScan(aCodNorma, EE9->EE9_CODNOR) == 0

         AAdd(aCodNorma, EE9->EE9_CODNOR)
      EndIf

      EE9->(DBSkip())
   End

   If Len(aCodNorma) == 0
      MsgInfo("Os itens do processo n�o possuem normas vinculadas.", cTitMsg)
      lRet:= .F.
      Break
   EndIf

   //Verifica��o de quais acordos comerciais as normas est�o relacionadas
   EEI->(DBSetOrder(1)) //EEI_FILIAL + EEI_COD
   For nCont:= 1 To Len(aCodNorma)

      If EEI->(DBSeek(xFilial() + aCodNorma[nCont]))

         If Empty(EEI->EEI_ACCOME)
            MsgInfo(STR0155 + aCodNorma[nCont], cTitMsg) //O campo 'Acordo Com.' n�o foi preenchido no cadastro da norma. Atualize a tabela 'Normas' antes de prosseguir: ###
            lRet:= .F.
            Break
         EndIf

         If AScan(aAcordo, EEI->EEI_ACCOME) == 0
            AAdd(aAcordo, EEI->EEI_ACCOME)
         EndIf

      Else
         MsgInfo(STR0156, cTitMsg) //O c�digo da norma vinculado ao item do processo n�o foi localizado. Revise os itens do processo de embarque antes de prosseguir.
         lRet:= .F.
         Break
      EndIf

   Next


   If Len(aAcordo) == 1
      cAcordoCom:= aAcordo[1]
   Else

      For nCont:= 1 To Len(aAcordo)
         /* Layout aItens:
            1. C�digo da norma + descri��o da norma */
         AAdd(aItens, aAcordo[nCont] + " - " + Posicione("E11", 1, E11->(xFilial()) + ;
                                                          aAcordo[nCont], "E11_DESRED"))
      Next


      //Cria��o da tela para que o usu�rio possa escolher qual Acordo Comercial
      //usado na gera��o do arquivo de integra��o
      Define MsDialog oDlg Title STR0013 From 0, 0 To nInferior, nDireita Pixel Of oMainWnd //Acordo Comercial

         oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)  // GFP - 17/08/2015
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         oSay:= TSay():New(2, 20, {|| STR0154}, oPanel,,,,,, .T.,,, 160, 40) //Este processo possui mais de um Acordo Comercial vinculado. Selecione um para a gera��o do arquivo de integra��o com a Fiesp ou revise as normas de origem vinculadas aos itens do processo.
         oSay:lWordWrap:= .T.
         oList:= TListBox():New(32, 20, bList, aItens, 160, 40,, oPanel,,,, .T.,, bOk)
         //oList:Select(1)

      Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered
   
   EndIf

   cAcordoCom:= SubStr(cAcordoCom, 1, AvSX3("EEI_ACCOME", AV_TAMANHO))
   
   If Empty(cAcordoCom)
      MsgInfo(STR0157, cTitMsg) //Foi encontrada uma inconsist�ncia no cadastro de 'Acordos Comerciais'. Favor entrar em contato com o suporte da Average Tecnologia.
      lRet:= .F.
   EndIf

End Sequence
Return lRet


/*
Fun��o    : VisualArqEI100
Objetivo  : Visualizar o arquivo TXT de integra��o.
Par�metros: String com os dados a serem exibidos.
Retorno   : L�gico
Autor     : Wilsimar Fabr�cio da Silva
Data      : 04/12/2009
Obs.      :
*/
Static Function VisualArqEI100(cDados)
Local bOk    := {|| lRet:= .T., oDlg:End()},;
      bCancel:= {|| lRet:= .F., oDlg:End()},;
      bGet   := {|x| If(PCount() > 0, cDados:= x, cDados)}
Local lRet
Local nInferior:= 500,;
      nDireita := 800
Local oDlg,;
      oFont,;
      oMultiGet

Begin Sequence


   oFont:= TFont():New("Arial",, -12) 
   Define MsDialog oDlg Title cTitMsg + STR0151 From 0, 0 To nInferior, nDireita Pixel Of oMainWnd //Declara��o do Produto ou Fatura Comercial - C.Origem +  - Visualiza��o do arquivo

      /* oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS - 16/09/2016
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT */

      oMultiGet:= TMultiGet():New(15, 10, bGet, oDlg, 385, 180, oFont,,,,, .T.,,,,,, .T.)
      oMultiGet:lWordWrap:= .T.
      oMultiGet:Align:= CONTROL_ALIGN_ALLCLIENT

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.) Centered


End Sequence
Return lRet


/*
Fun��o    : EI100VisualArq()
Objetivo  : Ler os arquivos de integra��o gerados e chamar a fun��o para a visualiza��o. Ser� mantido o
            �ltimo arquivo gerado e o �ltimo arquivo enviado, de acordo com o status do processo.
Par�metros: 
Retorno   : 
Autor     : Wilsimar Fabr�cio da Silva
Data      : 08/12/2009
Obs.      :
*/

Function EI100VisualArq(cOrigem)
Local cArquivo   := "",;
      cDiretorio := "",;
      cAlias     := Alias(),;
      cBuffer    := "",;
      cMsg       := "",;
      cIntegracao:= ""
Local nTamArq
Local hFile
Default cOrigem := "FIESP"

Begin Sequence

   cIntegracao := TipoIntegracaoEI100()
   If Empty(cIntegracao)
      lRet:= .F.
      MsgInfo(STR0239,STR0240) //"N�o � poss�vel executar esta a��o na pasta selecionada." ### "Aten��o"
      Break
   EndIf
   
   Do Case
      Case cIntegracao == DECL_EXP
           cTitMsg:= STR0060 //Declara��o do Produto
      Case cIntegracao == FAT_CERT
           cTitMsg:= STR0061 //Fatura Comercial - C.Origem
      Case cIntegracao == CO_FIERGS
           cTitMsg:= STR0172 //"Certificado de Origem - FIERGS"
   EndCase

   If (cAlias)->(EasyRecCount()) == 0
      MsgInfo(STR0081, cTitMsg) //N�o existem arquivos a serem enviados para este servi�o.
      lRet:= .F.
      Break
   EndIf
   
   If (cAlias)->(FieldPos("E09_STATUS")) == 0
      MsgInfo(STR0081, cTitMsg) //N�o existem arquivos a serem enviados para este servi�o.
      lRet:= .F.
      Break
   EndIf
   
   If cOrigem == 'FIERGS'
      cArquivo:= (cAlias)->E09_ARQUIV
      If (cAlias)->E09_STATUS == ST_R .Or. (cAlias)->E09_STATUS == ST_N
         cDiretorio:= cDirGerado + EI100Name(AllTrim((cAlias)->E09_PREEMB)) + "\"
      Else
         cDiretorio:= cDirEnviado + EI100Name(AllTrim((cAlias)->E09_PREEMB)) + "\"
      EndIf    
      
      If File(cDiretorio+cArquivo)
         Do While .T.
            If AvCpyFile(cDiretorio+cArquivo,GetTempPath()+cArquivo)
               Exit
            EndIf
         EndDo
      EndIf
      ShellExecute("open",GetTempPath() + cArquivo,"","", 1)
      
      If (cAlias)->E09_STATUS <> ST_N
          cArquivo := StrTran(cArquivo,"xml","ret")
          If File(cDiretorio+cArquivo)
             Do While .T.
                If AvCpyFile(cDiretorio+cArquivo,GetTempPath()+cArquivo)
                   Exit
                EndIf
             EndDo
          EndIf
          
          nHandle := EasyOpenFile(GetTempPath()+cArquivo,2)
          nSize := Fseek(nHandle,0,2)
          Fseek(nHandle,0)
          cBuffer := Space(nSize)
          nRead   := FRead(nHandle,@cBuffer,nSize)
          Fclose(nHandle)
          
          cArquivo := StrTran(cArquivo, "ret", "txt")
          hFile := EasyCreateFile(GetTempPath() + cArquivo , FC_READONLY)
          
          FWrite(hFile, cBuffer, Len(cBuffer))
          FClose(hFile)
          
          ShellExecute("open",GetTempPath() + cArquivo,"","", 1)
      EndIf      
      Break
   EndIf
   
   If (cAlias)->E09_STATUS == ST_N
      cDiretorio:= cDirGerado + EI100Name(AllTrim((cAlias)->E09_PREEMB)) + "\"
   Else
      cDiretorio:= cDirEnviado + EI100Name(AllTrim((cAlias)->E09_PREEMB)) + "\"
   EndIf
   
   cArquivo:= SubStr((cAlias)->E09_ARQUIV, 1, At(".", (cAlias)->E09_ARQUIV)-1) + If(lECool, ".xml", ".txt")  // RMD - 27/08/2014

   hFile:= EasyOpenFile(cDiretorio + cArquivo, FO_READ)
   If hFile == -1
      cMsg:= DescErroEI100(FError())
      MsgInfo(STR0158 + cMsg, cTitMsg) //O arquivo n�o pode ser aberto. FError()
      lRet:= .F.
      Break
   EndIf
   
   //L� o tamanho do arquivo e retorna � posi��o inicial
   nTamArq:= FSeek(hFile, 0, FS_END)
   FSeek(hFile, 0)

   If FRead(hFile, @cBuffer, nTamArq) <> nTamArq
      cMsg:= DescErroEI100(FError())
      MsgInfo(STR0158 + cMsg, cTitMsg) //O arquivo n�o pode ser aberto. FError()
      lRet:= .F.
      Break
   EndIf

   FClose(hFile)

   //Fun��o para a visualiza��o do arquivo
   VisualArqEI100(cBuffer)

End Sequence

Return

/*
Fun��o    : DescErroEI100
Objetivo  : Retornar a descri��o do erro na cria��o e grava��o do arquivo.
Par�metros: FError()
Retorno   : Descri��o do erro
Autor     : Wilsimar Fabr�cio da Silva
Data      : 19/11/2009
Obs.      :
*/
Static Function DescErroEI100(nErro)
Local cDescErro:= ""

Begin Sequence

      Do Case
         Case nErro == 2
            cDescErro:= STR0135 //Arquivo n�o encontrado
         Case nErro == 3
            cDescErro:= STR0136 //Caminho n�o encontrado
         Case nErro == 4
            cDescErro:= STR0137 //Muitos arquivos abertos
         Case nErro == 5
            cDescErro:= STR0138 //Acessso negado
         Case nErro == 6
            cDescErro:= STR0139 //Manipulador Invalido
         Case nErro == 8
            cDescErro:= STR0140 //Mem�ria Insuficiente
         Case nErro == 15
            cDescErro:= STR0141 //Drive especificado inv�lido
         Case nErro == 19
            cDescErro:= STR0142 //Tentativa de gravar em disco protegido contra grava��o
         Case nErro == 21
            cDescErro:= STR0143 //Drive n�o esta pronto
         Case nErro == 23
            cDescErro:= STR0144 //Dados com erro de CRC
         Case nErro == 29
            cDescErro:= STR0145 //Erro de grava��o
         Case nErro == 30
            cDescErro:= STR0146 //Erro de leitura
         Case nErro == 32
            cDescErro:= STR0147 //Viola��o de compartilhamento
         Case nErro == 33
            cDescErro:= STR0148 //Erro de Lock
         Case nErro == 430 .Or. nErro == 161
            cDescErro:= STR0135 //Arquivo n�o encontrado
         OtherWise
            cDescErro:= STR0149 //Erro desconhecido
      EndCase

End Sequence
Return cDescErro

// RMD - 27/08/2014 - Integra��o via XML
Static Function GetCertECOOL(cDiretorio, cIntegracao)
Local cNomeArq := "", hFile, cBuffer
Local cEYJCodFi := ""
Private cCNPJExp, cIdAssinante, cIdAcordo, cIdEndExp, cIdImp, cNomeCons, cRuaCons, cCidadeCons, cPaisCons, IdLocalEmbarque,;
		cViaTrans, cFatura, cDataFatura
Private nPesoLQ, nPesoBR, nPesoLqTot := 0, nPesoBrTot := 0, nPrecoTot := 0
Private aItens := {}

Begin Sequence

	If !EEC->(DbSeek(xFilial()+MV_PAR01))
		MsgInfo(STR0161,STR0171) // MCF-08/09/2014 - "Erro ao localizar o processo de embarque", "Aviso"
		Break
	EndIf
		
	cFatura := EEC->EEC_PREEMB
	cDataFatura := DToS(EEC->EEC_DTPROC)
	//Ajusta para o padr�o da FIESP
	cDataFatura := Left(cDataFatura, 4) + "-" + SubStr(cDataFatura, 5, 2) + "-" + Right(cDataFatura, 2)

	If !Empty(EEC->EEC_EXPORT)
		If SA2->(DbSeek(xFilial()+EEC->(EEC_EXPORT+EEC_EXLOJA))) .And. !Empty(SA2->A2_CGC) .And. !Empty(cIdEndExp := SA2->A2_CODFI)
			cCNPJExp := Alltrim(SA2->A2_CGC)//CNPJ do Exportador
			cIdEndExp := AllTrim(SA2->A2_CODFI)//C�digo do Endere�o do Exportador cadastrado no site da Fiesp
		Else
			MsgInfo(STR0162,STR0171) // MCF-08/09/2014 - "Erro ao informar o exportador. O c�digo do endere�o na FIESP ou o CNPJ n�o foram informados.", "Aviso"
			Break
		EndIf
	Else
		If SA2->(DbSeek(xFilial()+EEC->(EEC_FORN+EEC_FOLOJA))) .And. !Empty(SA2->A2_CGC) .And. !Empty(cIdEndExp := SA2->A2_CODFI)
			cCNPJExp := AllTrim(SA2->A2_CGC)//CNPJ do Exportador
			cIdEndExp := AllTrim(SA2->A2_CODFI)//C�digo do Endere�o do Exportador cadastrado no site da Fiesp
		Else
			MsgInfo(STR0163,STR0171) // MCF-08/09/2014 - "Erro ao informar o fornecedor. O c�digo do endere�o na FIESP ou o CNPJ n�o foram informados.","Aviso"
			Break
		EndIf
	EndIf
	
	cNomeArq := AllTrim(SA2->A2_CGC) + cIntegracao + ".xml"
	
	cIdAssinante := AllTrim(If(!Empty(EEC->EEC_RESPON), EEC->EEC_RESPON, cUserName))//Assinante (Respons�vel pelo processo ou usu�rio do sistema)
	
	//C�digo do Importador cadastrado no site da Fiesp
	If Empty(cIdImp := AllTrim(Posicione("EXJ", 1, xFilial("SA1")+EEC->(EEC_IMPORT+EEC_IMLOJA), "EXJ_CODFI")))
		MsgInfo(STR0164,STR0171) // MCF-08/09/2014 - "Erro ao informar o importador. O c�digo FIESP n�o foi informado no cadastro.", "Aviso"
		Break
	EndIf
	
	//*** Informa��es do Consignat�rio
	If !Empty(EEC->EEC_CONSIG)
		If !SA1->(DbSeek(xFilial()+EEC->(EEC_CONSIG+EEC_COLOJA)))
			MsgInfo(STR0165,STR0171) // MCF-08/09/2014 - "Erro ao obter dados de endere�o do consignat�rio.", "Aviso"
			Break
		Else
			cNomeCons := AllTrim(SA1->A1_NOME)
			cRuaCons := AllTrim(SA1->(A1_END))
			cCidadeCons := AllTrim(SA1->(A1_MUN + " - " + A1_EST))
			cPaisCons := AllTrim(Posicione("SYA", 1, xFilial("SYA")+SA1->A1_PAIS, "YA_CODFIES"))
		EndIf
	Else
		If !SA1->(DbSeek(xFilial()+EEC->(EEC_IMPORT+EEC_IMLOJA)))
			MsgInfo(STR0165,STR0171) //"Erro ao obter dados de endere�o do consignat�rio.", "Aviso"
			Break
		Else
			cNomeCons := AllTrim(SA1->A1_NOME)
			cRuaCons := AllTrim(SA1->A1_END)
			cCidadeCons := AllTrim(SA1->(A1_MUN + " - " + A1_EST))
			cPaisCons := AllTrim(Posicione("SYA", 1, xFilial("SYA")+SA1->A1_PAIS, "YA_CODFIES"))
		EndIf
	EndIf
	
	If Empty(cPaisCons)
		MsgInfo(STR0166,STR0171) // MCF-08/09/2014 - "O c�digo FIESP do pa�s do cliente/consignat�rio n�o foi informado", "Aviso"
		Break
	EndIf
	//***

	//*** Local de Embarque
	SY9->(DBSetOrder(2)) //Y9_FILIAL + Y9_SIGLA
	If SY9->(DBSeek(xFilial()+EEC->EEC_ORIGEM))
		If Empty(cLocEmb := AllTrim(SY9->Y9_CODFIES))
			MsgInfo(STR0167,STR0171) // MCF-08/09/2014 - "O c�digo FIESP do local de embarque n�o foi informado.","Aviso"
			Break
		EndIf
	EndIf
	//***

	//*** Via de Transporte
	SYQ->(DBSetOrder(1)) //YQ_FILIAL + YQ_VIA
	If SYQ->(DBSeek(xFilial() + EEC->EEC_VIA))
		If Empty(cViaTrans := AllTrim(SYQ->YQ_CODFIES))
			MsgInfo(STR0168,STR0171) // MCF-08/09/2014 - "O c�digo FIESP da via de transporte n�o foi informado.","Aviso"
			Break
		EndIf
	EndIf
	//***

	//Busca os itens do processo
	EE9->(DBSetOrder(3))
	EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))
	While EE9->(!Eof()) .And. EE9->(EE9_FILIAL+EE9_PREEMB == xFilial()+EEC->EEC_PREEMB)

		//*** Verifica a unidade de medida do item
		SAH->(DBSetOrder(1)) //AH_FILIAL + AH_UNIMED
		SAH->(DBSeek(xFilial() + AvKey(EE9->EE9_UNIDAD, "AH_UNIMED")))
		If Empty(SAH->AH_COD_CO)
			MsgInfo(STR0096 + AllTrim(EE9->EE9_UNIDAD),STR0171) // MCF-08/09/2014 - O c�digo da unidade de medidas conforme a tabela FIESP n�o est� cadastrado. Verifique o cadastro desta unidade de medida antes de prosseguir: 
   			Break
		EndIf
		//***
		
        //Embalagem
        If Empty(cCodEmb := AllTrim(Posicione("EE5", 1, xFilial("EE5")+EE9->EE9_EMBAL1, "EE5_CODFI")))
        	MsgInfo((STR0169+" "+Trim(cValToChar(EE9->EE9_EMBAL1))+" "+STR0170),STR0171) // MCF-08/09/2014 - "O c�digo FIESP da embalagem  XXX n�o foi informado.","Aviso"
        	Break
        EndIf

		//*** Peso Liquido
		If !Empty(EE9->EE9_UNPES) .And. ! AvVldUn(EE9->EE9_UNPES) // MPG - 06/02/2018
			nPesoLQ := AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE9->EE9_PSLQTO, .F.)
		Else
			nPesoLQ := EE9->EE9_PSLQTO
		EndIf
		//***
		
		//*** Peso Bruto
		If !Empty(EE9->EE9_UNPES) .And. ! AvVldUn(EE9->EE9_UNPES) // MPG - 06/02/2018
			nPesoBR := AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE9->EE9_PSBRTO, .F.)
		Else
			nPesoBR := EE9->EE9_PSBRTO
		EndIf
		//***

		/* Guarda as informa��es em aItens
		aItens[1] = Descri��o
		aItens[2] = Quantidade
		aItens[3] = Unidade de Medida
		aItens[4] = Embalagem
		aItens[5] = NCM
		aItens[6] = Pre�o FOB Unit�rio
		aItens[7] = Pre�o FOB Total
		aItens[8] = Peso L�quido
		aItens[9] = Peso Bruto
		*/
      cEYJCodFi := If( EYJ->(FieldPos("EYJ_CODFIE" )) > 0, Alltrim(Posicione("EYJ", 1, xFilial("EYJ")+EE9->EE9_COD_I, "EYJ_CODFIE")),"")
		aAdd(aItens, {	cDescricao:= StrTran(AllTrim(MSMM(EE9->EE9_DESC,,,, LERMEMO)), ENTER, " "),;
						EE9->EE9_SLDINI,;
						AllTrim(SAH->AH_COD_CO),;
						AllTrim(cCodEmb),;
						AllTrim(EE9->EE9_POSIPI),;
						EE9->EE9_PRECOI,;
						EE9->EE9_PRCINC,;
						nPesoLQ,;
						nPesoBR,;
						cEYJCodFi;
					})
		
		//Totaliza as informa��es de peso e pre�o
		nPesoLqTot += nPesoLQ
		nPesoBrTot += nPesoBR
		nPrecoTot  += EE9->EE9_PRCINC
	
		EE9->(DbSkip())
	EndDo
	
	//*** Cria o arquivo
	hFile := EasyCreateFile(cDiretorio + cNomeArq, FC_READONLY)
	If hFile == -1
		cMsg:= DescErroEI100(FError())
		MsgInfo(STR0108 + cMsg, cTitMsg) //O arquivo n�o pode ser criado. FError()
		cNomeArq := ""
		Break
	EndIf
   
	cBuffer := h_FIESPCO()

	If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		cMsg:= DescErroEI100(FError())
		MsgInfo(STR0109 + cMsg, cTitMsg) //O arquivo n�o pode ser gravado. FError()
		cNomeArq := ""
		Break
	EndIf
	FClose(hFile)
	//***

End Sequence

Return cNomeArq

//LGS-24/12/2014 - Substitui caracteres especiais no nome do embarque.
Function EI100Name(cEmbarque)
Local cConvName := cEmbarque, i
Local aValTroca := {'\','/',':','*','?','<','>','"','|'}

For i:=1 To Len(aValTroca)
	cConvName := StrTran(cConvName,aValTroca[i],"_")
Next

Return cConvName

//LGS-31/08/2015 - Fun��o utilizada no menu do exporta��o, para separar os certifidos (Fiesp/Fiergs)
Function EI100Fiergs()
  EECEI100("FIERGS")
Return Nil

Static Function EI100EnvXML(cArq, cOrigem, cJusFat, cOriXML)
Local cUsuario := cSenha:= cURL := cRpLegal := cBuffer := ""
Local nPos := nRdOpcoes := 0

Default cOrigem := "FIERGS"
Default cJusFat := ""

Begin Sequence
	
	aCFG := EI100USERCFG(cUserName,cOrigem)
	//Verifica se esta feito a configura��o do WebService
	If Len(aCFG) == 0
	   EI100Configs(cOrigem) 
	EndIf
	
	//Verificando xml gerado...
	If !Empty(cArq)	   
	   cArq := ALLTRIM(cArq)
	   nHandle := EasyOpenFile(cArq,0)
	   If nHandle == -1
	      cSBMsg += DATETIME + CRLF + STR0190 + cArq + LINHA
	      oTMultMSG:Refresh()
	      oTMultMSG:GoEnd()
	      Break
	   EndIf
	   
	   nSize := Fseek(nHandle,0,2)
	   Fseek(nHandle,0)
	   If nSize <= 0
	      cSBMsg += DATETIME + CRLF + STR0191 + cArq + LINHA
	      oTMultMSG:Refresh()
	      oTMultMSG:GoEnd()
	      Fclose(nHandle)
	      Break
	   EndIf
	   
	   If (nSize/1024) >= 1024
	      MsgInfo(STR0192,STR0187)
	      cSBMsg += DATETIME + CRLF + STR0192 + LINHA
	      oTMultMSG:Refresh()
	      oTMultMSG:GoEnd()
	      Break
	   Else
	      cBuffer := Space(nSize)
	      nRead   := FRead(nHandle,@cBuffer,nSize)
	      Fclose(nHandle)
	      If nRead < nSize
	         cSBMsg += DATETIME + CRLF + STR0191 + cArq + LINHA
	         oTMultMSG:Refresh()
	         oTMultMSG:GoEnd()
	         Break
	      EndIf
	   EndIf   	   
	EndIf
	
	aCFG := EI100USERCFG(cUserName,cOrigem)
	If Len(aCFG)>0 
	   
	   nPos := aScan(aCFG, {|x| x[1] == AvKey("ENDSERVER","EWQ_PARAM")})
	   nRdOpcoes := Val(AllTrim(aCFG[nPos][2])) 
	   nPos := aScan(aCFG, {|x| x[1] == AvKey("USUARIO"  ,"EWQ_PARAM")})
	   cUsuario := cValToChar(AllTrim(aCFG[nPos][2]))
	   nPos := aScan(aCFG, {|x| x[1] == AvKey("SENHA"    ,"EWQ_PARAM")})
	   	   
	   cSenha := cValToChar(DECRYPF(AllTrim(aCFG[nPos][2]))) //LGS-17/02/2016 - Descriptografa a senha
	   
	   nPos := aScan(aCFG, {|x| x[1] == AvKey("RPLEGAL"  ,"EWQ_PARAM")})
	   cRpLegal := AllTrim(aCFG[nPos][2])
	   cURL := If(nRdOpcoes == 1, HWSDL, PWSDL)
	   
	   //Pesquisa para saber se o XML foi gerado sem a configura��o com o WebService
	   cBuffer := StrTran(cBuffer, '#USUARIO#',			cUsuario)
	   cBuffer := StrTran(cBuffer, '#SENHA#'  ,			cSenha  )
	   cBuffer := StrTran(cBuffer, '#RPLEGAL#',			cRpLegal)
	   cBuffer := StrTran(cBuffer, '#JUSTIFICAFATURA#',	AllTrim(Left(EncodeUTF8(cSBJusFat),2000)) )
	   
	   //Chama a fun��o para transmitir o XML
	   If WSDLFIERGS(2,cURL,cUsuario,cSenha,cBuffer,.F.)
	      AtualizaStatusEI100(ST_A, cOrigem, cSBJusFat) //Troca o Status do processo
	   Else
	      AtualizaStatusEI100(ST_R, cOrigem, cSBJusFat) //Coloca o Status como rejeitado
	   EndIf
	   
	   hFile := EasyCreateFile(cOriXML, FC_READONLY)
	   If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
	      cSBMsg += DATETIME + CRLF + STR0193 + '"'+cOriXML + '"' + LINHA
	      oTMultMSG:Refresh()
	      oTMultMSG:GoEnd()
	   EndIf
	   FClose(hFile)
	Else
	   cSBMsg += DATETIME + CRLF + STR0194 + LINHA
	   Break
	EndIf
    
End Sequence
Return

/*
Fun��o    : FiergsCriaXML
Objetivo  : Gera��o do arquivo XML para integra��o com a FIERGS
Par�metros: cDirTxt - diret�rio para a cria��o do arquivo TXT
            cNomeTxt- nome do arquivo XML (com a extens�o)
            cPreemb - codigo do embarque utilizado para gerar certificado
            cUndAnas- Unidade de analise
            cUndReti- Unidade de retirada
            aCTRange- Array de informa�oes sobre o capitulo tecnico
Retorno   : L�gico
Autor     : Laercio G Souza Jr - LGS
*/
Static Function FiergsCriaXML(cDirXML, cNomeXML, cPreemb, cUndAnas, cUndReti, aCTRange)
Local cBuffer := cBase64 := "", lRet := .T., hFile
Private aFIERGS, nPos

Begin Sequence
	
	//Retorna o array completo para o certificado de origem
	aFIERGS := FiergsDados(cPreemb, cUndAnas, cUndReti, aCTRange)
	
	EE9->(DbSetOrder(3))
	EE9->(DbSeek(xFilial("EE9") + AvKey(cPreemb,"EE9_PREEMB")))
	
	If FindFunction("H_CO_FIERGS")
	   
	   SY0->(DbSetOrder(6))
	   SY0->(DbSeek(xFilial("SY0") + AvKey(cPreemb,"Y0_PROCESS") + AvKey("FIERGS","Y0_ROTINA")))
	   cBase64 := EI100Base64(SY0->Y0_ARQPDF)
	   If cBase64 == "Erro"
	      lRet := .F.
	      Break
	   EndIf
	   
	   hFile := EasyCreateFile(cDirXML + cNomeXML , FC_READONLY)
	   cBuffer += H_CO_FIERGS()
	      
	   If Len(cBuffer) + Len(cBase64) >= (1024*1024)
	      MsgInfo(STR0195,STR0187)
	      lRet := .F.
	      Break
	   Else
	      cBuffer := StrTran(cBuffer, '#ARQBASE64#',cBase64)
	   EndIf
	   
	   If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
	      lRet := .F.
	      MsgInfo(STR0196,STR0187)
	      FErase(cDirXML + cNomeXML)
	   EndIf
	   FClose(hFile)
	   
	Else
	   MsgInfo(STR0197,STR0187)
	   lRet := .F.
	   Break
	EndIf
	
End Sequence

Return lRet

/*
Fun��o    : EI100USERCFG
Objetivo  : Buscar as informa��es de cfg do webservice por usu�rio e carregar na tela
Autor     : Laercio G Souza Jr
Data      : 21/10/2015
*/
Static Function EI100USERCFG(cUser,cOri)
Local aRet  := {}
Local cUserSIS := AvKey(cUser,"EWQ_USER"),;
      cRotOri  := AvKey(cOri ,"EWQ_ROTORI")

	EWQ->(DbSetOrder(1))
	If EWQ->(DbSeek(xFilial()+cUserSIS+cRotOri))
	   Do While EWQ->(!Eof()) .And. EWQ->(EWQ_USER+EWQ_ROTORI) == (cUserSIS + cRotOri)
	      aaDD(aRet,{ EWQ->EWQ_PARAM, EWQ->EWQ_XCONT })
	      EWQ->(DbSkip())
	   EndDo
	EndIf	
Return aRet

/*
Fun��o    : EI100Configs
Objetivo  : Montar a tela de configura��es do webservice por usu�rio
Autor     : Laercio G Souza Jr
Data      : 21/10/2015
*/
Static Function EI100Configs(cOri)
Local cTitulo  := STR0198 + cUserName ,;
      nRdOpcoes, nOp, i
      
Local bBTeste  := {|| WSDLFIERGS(1,cURL,cUsuario,cSenha,"",.T.) },;
      bBGrvCFG := {|| nOp := 2, oDlgCFG:End() },;
      bBSair   := {|| oDlgCFG:End() },;
      bTexto   := {|| cSBMsg }

Private oUsuario,oSenha,oTMultMSG,oDlgCFG,oURL,;
        cUsuario := cSenha := cRpLegal := Space(30),;
        cSBMsg   := cURL   := "" 
              
Default cOri := ""

Begin Sequence
	
	If Empty(cOri)
	   Break
	EndIf
	
	aCFG := EI100USERCFG(cUserName,cOri)
	
	If Len(aCFG) > 0
		nPos := aScan(aCFG, {|x| x[1] == AvKey("ENDSERVER","EWQ_PARAM")})
		nRdOpcoes := Val(AllTrim(aCFG[nPos][2])) 
		nPos := aScan(aCFG, {|x| x[1] == AvKey("USUARIO"  ,"EWQ_PARAM")})
		cUsuario := PADR(AllTrim(aCFG[nPos][2]),30)
		nPos := aScan(aCFG, {|x| x[1] == AvKey("SENHA"    ,"EWQ_PARAM")})
		
		
		cSenha := PADR(cValToChar(DECRYPF(AllTrim(aCFG[nPos][2]))),30) //LGS-17/02/2016
		
		nPos := aScan(aCFG, {|x| x[1] == AvKey("RPLEGAL"  ,"EWQ_PARAM")})
		cRpLegal := PADR(AllTrim(aCFG[nPos][2]),30)
		cURL := If(nRdOpcoes == 1, HWSDL, PWSDL)
	Else
		nRdOpcoes := 1
		cURL := HWSDL		                              
	EndIf

	DEFINE MSDIALOG oDlgCFG TITLE cTitulo FROM 000, 000  TO 380, 485 PIXEL
		
		oPanel:= tPanel():New(01,01,"",oDlgCFG,,,,,,100,100)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT
		
		@ 005, 006 GROUP oGroup1 TO 185, 239 PROMPT STR0199 OF oPanel PIXEL
		@ 018, 010 RADIO nRdOpcoes ITEMS STR0200,STR0201 SIZE 100, 019 On Change EI100AtuInfo(nRdOpcoes) OF oPanel PIXEL
		@ 043, 010 GROUP oGroup2 TO 163, 233 PROMPT STR0202 OF oPanel PIXEL
		
		@ 055, 015 SAY STR0203 SIZE 060, 007 OF oPanel PIXEL
		@ 065, 015 MSGET oUsuario VAR cUsuario SIZE 065, 010 OF oPanel PIXEL
		
		@ 055, 085 SAY STR0204 SIZE 060, 007 OF oPanel PIXEL
		@ 065, 085 MSGET oSenha VAR cSenha SIZE 065, 010 OF oPanel PIXEL PICTURE "@!" PASSWORD
		
		@ 055, 155 SAY STR0205 SIZE 060, 007 OF oPanel PIXEL
		@ 065, 155 MSGET oSenha VAR cRpLegal SIZE 073, 010 OF oPanel PIXEL
		
		@ 080, 015 SAY STR0206 SIZE 060, 007 OF oPanel PIXEL
		@ 090, 015 MSGET oURL VAR cURL SIZE 213, 010 OF oPanel PIXEL WHEN .F.
		
		oTMultMSG := TMultiget():New(109,15,{|u|if(Pcount()>0,cSBMsg:=u,cSBMsg)},oPanel,213,50,,,,,,.T.,,,,,,.T.,,,,,.T.)
					
		@ 167, 193 BUTTON STR0182 ACTION Eval(bBSair) SIZE 039,012 PIXEL OF oPanel
		@ 167, 152 BUTTON STR0207 ACTION Eval(bBGrvCFG) SIZE 037,012 PIXEL OF oPanel
		@ 167, 105 BUTTON STR0208 ACTION Eval(bBTeste) SIZE 043,012 PIXEL OF oPanel
		
		oDlgCFG:Refresh()

	ACTIVATE MSDIALOG oDlgCFG CENTERED
	
	If nOp == 2
	   aCPO := {{"ENDSERVER","N",nRdOpcoes},{"USUARIO","C",cUsuario},{"SENHA","C",cSenha},{"RPLEGAL","C",cRpLegal}}
	   lRec := (Len(aCFG) == 0)
	   
	   EWQ->(DbSetOrder(1))
	   For i := 1 To Len(aCPO)
	      If lRec
	         EWQ->(RecLock("EWQ", lRec))
	         EWQ->EWQ_FILIAL	:= xFilial("EWQ")
	         EWQ->EWQ_USER	:= cUserName //Usuario logado no sistema
	         EWQ->EWQ_ROTORI	:= cOri//'FIERGS'
	         EWQ->EWQ_PARAM	:= AllTrim(aCPO[i][1])
	         EWQ->EWQ_TIPO	:= AllTrim(aCPO[i][2])
	         EWQ->EWQ_XCONT	:= If(AllTrim(EWQ->EWQ_PARAM) == "SENHA", cValToChar(ENCRYPF(cValToChar(AllTrim(aCPO[i][3]))) ), cValToChar(aCPO[i][3]) ) //LGS-17/02/2016 - Criptografa a senha
	      Else
	         If EWQ->(DbSeek(xFilial()+AvKey(cUserName,"EWQ_USER")+AvKey(cOri ,"EWQ_ROTORI")+AvKey(aCPO[i][1],"EWQ_PARAM") ))
	            EWQ->(RecLock("EWQ", lRec))
	            EWQ->EWQ_XCONT	:= If(AllTrim(EWQ->EWQ_PARAM) == "SENHA", cValToChar(ENCRYPF(cValToChar(AllTrim(aCPO[i][3]))) ), cValToChar(aCPO[i][3]) ) //LGS-17/02/2016 - Criptografa a senha
	         EndIf
	      EndIf
	      EWQ->(MsUnlock())
	   Next
	EndIf    
End Sequence
Return Nil

Static Function EI100AtuInfo(nOp)
	If nOp == 1
	   cURL := HWSDL
	Else
	   cURL := PWSDL
	EndIf
	oURL:Refresh()
Return

/*
Fun��o    : TelaFIERGS
Objetivo  : Montar a tela de escolha do embarque
Retorno   : .T./.F.
Autor     : Laercio G Souza Jr
Data      : 27/10/2015
*/
Static Function TelaFIERGS()
Local bOK       := {|| nOp := 1, If(Empty(cEmbarque), MsgAlert(STR0210,STR0187), oDlg:End() )}
Local bCancel   := {|| oDlg:End() }
Local cRet      := ""
Private cEmbarque := Space(AvSx3("EEC_PREEMB", AV_TAMANHO)), nOp := 0
  DEFINE MSDIALOG oDlg TITLE STR0209 FROM 000, 000  TO 165, 400 COLORS 0, 16777215 PIXEL

    oPanel:= tPanel():New(01,01,"",oDlg,,,,,,100,100)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    @ 005, 004 GROUP oGroup1 TO 078, 194 PROMPT STR0212 OF oPanel PIXEL
    @ 059, 100 BUTTON STR0211 ACTION Eval(bOK)     SIZE 039,012 PIXEL OF oPanel
    @ 059, 148 BUTTON STR0182 ACTION Eval(bCancel) SIZE 039,012 PIXEL OF oPanel
    
    @ 017, 009 GROUP oGroup2 TO 054, 187 PROMPT STR0213 OF oPanel PIXEL
    @ 030, 011 SAY oSay1 PROMPT STR0214 SIZE 025, 007 OF oPanel PIXEL
    @ 030, 040 MSGET cEmbarque Size 118, 010 F3 "EEC" VALID (Vazio() .Or. ExistCPO("EEC",cEmbarque,1)) OF oPanel PIXEL HASBUTTON

  ACTIVATE MSDIALOG oDlg CENTERED
  
  If nOp == 1
     cRet := cEmbarque 
  EndIf
  
Return cRet

/*
Fun��o    : EI100Param
Objetivo  : Montar o pergunte do FIERGS
Retorno   : .T./.F.
Autor     : Laercio G Souza Jr
Data      : 14/09/2015
*/
Static Function EI100Param(cEmb)
Local aPergs := {},;
      aRet   := {},;
      aCombo := {},;
      lLoop  := .T.,;
      lRet, i
      
Private aCPTec := {}//, cAcordo:= "        " //LGS-04/03/2016
 
Begin Sequence    
  	
  	EEC->(DbSetOrder(1))  // GFP - 15/03/2016
  	EEC->(DbSeek(xFilial("EEC")+AvKey(cEmb,"EEC_PREEMB")))
  	aCPTec := EI100CapTec(cEmb)
  	aSort(aCPTec,,, {|x, y| x[5] < y[5]})
  	
  	aCapitulo := Array(Len(aCPTec))
  	For i:=1 To Len(aCPTec)
  	    aCapitulo[i] := cValToChar(Alltrim(aCPTec[i][1]))
  	Next
  	
  	If SX5->(DbSeek(xFilial('SX5')+"E7"))
  	   Do While SX5->(!Eof()) .And. SX5->X5_TABELA == "E7"
  	      aAdd(aCombo,{ SX5->X5_DESCRI, Val(SX5->X5_CHAVE) })
  	      SX5->(DbSkip())
  	   EndDo
  	   aSort(aCombo,,, {|x, y| x[2] < y[2]})
  	EndIf
  	
  	aUnidEmis := Array(Len(aCombo))
  	For i:=1 To Len(aCombo)
  	    aUnidEmis[i] := cValToChar(Alltrim(aCombo[i][1]))
  	Next
  	
  	aAdd( aPergs ,{1, STR0215 , cEmb,   "@!",  '',    '', '.F.', 70, .T.})
  	//LGS-11/02/2016 - Incluido a oitava posi��o para for�ar o WHEN do combo como .T.
  	aAdd( aPergs ,{2, STR0216 , 0, aUnidEmis, 100, '.T.', .T.,.T.})
  	aAdd( aPergs ,{2, STR0217 , 0, aUnidEmis, 100, '.T.', .T.,.T.})
  	aAdd( aPergs ,{2, STR0218 , 0, aCapitulo, 100, '.T.', .T.,.T.})
  	//aAdd( aPergs ,{1, "Acordo Comercial" , cAcordo,   "@!",  '', 'EI100NormaTec(aCPTec)', '.T.', 70, .T.})
  	
  	
  	Do While lLoop
  	   If ParamBox(aPergs ,STR0219,aRet,,,.T.,,,,,.F.,)
  	      If Empty(MV_PAR02) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04)// .Or. Empty(MV_PAR05)
  	         Loop
  	      EndIf
  	      
  	      nPos := aScan(aCPTec, {|x| x[1] == MV_PAR04 })
  	      /*              { Capitulo Tecnico, ID Capitulo    , Inicio Range   , Fim Range       }*/
  	      aAdd(@aCTRange, { aCPTec[nPos][1] , aCPTec[nPos][2], aCPTec[nPos][3], aCPTec[nPos][4] } )
  	      lRet := .T.
  	      lLoop:= .F.
  	   Else
  	      lLoop := lRet := .F.
  	   EndIf
    EndDo

End Sequence    
Return lRet

Function EI100NormaTec(aCapitulo) //EI100NormaTec(cEmb,aCTRange)
Local cRet := "", cArqTemp
Local aSemSX3 := {}, TB_Campos :={}
lOCAL bOK  :={|| lOK := .T., oDlg:End() }
Local cMarca := GetMark()
Local nPos, lOK :=.F.
Local lTela := .T.
 
Begin Sequence
	AvZap("WorkAC")
  	AvZap("WorkNR")
  	If Len(aCapitulo) > 0
  	   EE9->(DbSeek(xFilial("EE9") + AvKey(MV_PAR01,"EE9_PREEMB")))
	   Do While EE9->(!Eof()) .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB
	      SB1->(DbSeek(xFilial("SB1") + EE9->EE9_COD_I))
	      nCapTec := Val(SubStr(EE9->EE9_POSIPI,1,2))
	      /* Se for Zero � apenas o inicio*/ 
	      If aCapitulo[1][4] == 0
	         If nCapTec <> aCapitulo[1][3]
	            EE9->(DBSkip())
	         EndIf
	      Else
	         If nCapTec >= aCapitulo[1][3] .And. nCapTec <= aCapitulo[1][4]
	            EEI->(DbSeek(xFilial("EEI") + EE9->EE9_CODNOR))	            
	            If !WorkAC->(DBSEEK(EEI->EEI_ACCOME))
	                WorkAC->(DbAppend())
	                WorkAC->WK_ACCOME := EEI->EEI_ACCOME
	                WorkAC->(DbGoTop())
	            EndIf
	            
	            If !WorkNR->(DBSEEK(EEI->EEI_ACCOME+EE9->EE9_CODNOR))
	                WorkNR->(DbAppend())
	                WorkNR->WK_ACCOME := EEI->EEI_ACCOME
	                WorkNR->WK_CODNOR := EE9->EE9_CODNOR
	                WorkNR->(DbGoTop())
	            EndIf	            
	         Else
	            EE9->(DBSkip())
	            Loop
	         EndIf
	         EE9->(DBSkip())
	      EndIf
	   EndDo
	   
	   TB_Campos	:=	{{"WKFLAG"   ,,"  "},;
	   	               {"WK_ACCOME",,"Acordo Comercial"}}
	   	               
	   bMarca    := {|| EI100Mark(@cMarca), oMark:oBrowse:Refresh() }
	   Do While lTela
	      WorkAC->(DbGoTop())
	      DEFINE MSDIALOG oDlg TITLE "Consulta Acordos Comerciais" FROM 62,05 TO 300,382 OF oMainWnd PIXEL
	         aPos := PosDlg(oDlg)
	         oMark:= MsSelect():New("WorkAC",'WKFLAG',,TB_Campos,.F.,@cMarca,{aPos[1],aPos[2],aPos[3]-20,aPos[4]})
	         oMark:bAval := bMarca
	         
	         DEFINE SBUTTON FROM 105,05 TYPE 1  ACTION (Eval(bOk)) ENABLE OF oDlg PIXEL
	         DEFINE SBUTTON FROM 105,40 TYPE 2  ACTION (lOk:=.F.,oDlg:End()) ENABLE OF oDlg PIXEL
             
	      ACTIVATE MSDIALOG oDlg CENTERED
	      
	      If lOK
	         WorkAC->(DbGoTop())
	         Do While WorkAC->(!Eof())
	            If !Empty(WorkAC->WKFLAG)
	               cAcordo:= WorkAC->WK_ACCOME
	               lTela  := .F.
	            EndIf
	            WorkAC->(DbSkip())
	         EndDo
	         If Empty(cAcordo)
	            Loop
	         EndIf
	      Else
	         lTela := .F.
	      EndIf
	   EndDo	   
  	EndIf
End Sequence    
Return lOK

Function EI100Mark(cMark)
Local cAcordo := WorkAC->WK_ACCOME    

	WorkAC->WKFLAG := If(Empty(WorkAC->WKFLAG),cMark,"")
	WorkAC->(DbGoTop())
	Do While WorkAC->(!Eof())
	   If WorkAC->WK_ACCOME <> cAcordo
	      WorkAC->WKFLAG := ""
	   EndIf
	   WorkAC->(DbSkip())
	EndDo
   WorkAC->(DbGoTop())
Return .T.

/*
Fun��o    : EI100CapTec
Objetivo  : Retornar o array com o capitulo tecnico com base nas NCM dos itens do processo
Retorno   : Array
Autor     : Laercio G Souza Jr
Data      : 27/10/2015
*/
Static Function EI100CapTec(cEmbarque)
Local aNCM := {}, aCapTec := {}, nPos := 0, nCapTec ,i

Begin Sequence
    
    If Empty(cEmbarque)
       Break
    EndIf
    
    EE9->(DbSetOrder(3))
    If EE9->(DbSeek(xFilial("EE9") + AvKey(cEmbarque,"EE9_PREEMB")))
       Do While EE9->(!Eof()) .And. EE9->EE9_PREEMB == AvKey(cEmbarque,"EE9_PREEMB")
          nCapTec := Val(SubStr(EE9->EE9_POSIPI,1,2))
          If Len(aNCM) == 0
             AAdd(aNCM,{nCapTec})
          Else
             If (nPos := aScan(aNCM, {|x| x[1] == nCapTec }) ) == 0
                AAdd(aNCM,{nCapTec})
             EndIf
          EndIf
          EE9->(DbSkip())
       EndDo
       
       /**********
       aCapTec{ Capitulo Tecnico, ID Capitulo, Inicio Range, Fim Range, Indexador }
       *****************************************************************************/
       If Len(aNCM) > 0
          For i := 1 To Len(aNCM)
              Do Case
                 Case aNCM[i][1] >= 1  .And. aNCM[i][1] <= 24
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "21 - CAP�TULO 1 A 24" }) ) == 0
                         AAdd(aCapTec,{ "21 - CAP�TULO 1 A 24", 21, 1, 24, 1 })
                      EndIf                      
                 Case aNCM[i][1] >= 25 .And. aNCM[i][1] <= 27
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "22 - CAP�TULO 25 A 27" }) ) == 0
                         AAdd(aCapTec,{ "22 - CAP�TULO 25 A 27", 22, 25, 27, 2 })
                      EndIf                      
                 Case aNCM[i][1] >= 28 .And. aNCM[i][1] <= 40
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "23 - CAP�TULO 28 A 40" }) ) == 0
                         AAdd(aCapTec,{ "23 - CAP�TULO 28 A 40", 23, 28, 40, 3 })
                      EndIf                      
                 Case aNCM[i][1] >= 41 .And. aNCM[i][1] <= 43
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "24 - CAP�TULO 41 A 43" }) ) == 0
                         AAdd(aCapTec,{ "24 - CAP�TULO 41 A 43", 24, 41, 43, 4 })
                      EndIf                      
                 Case aNCM[i][1] >= 44 .And. aNCM[i][1] <= 49
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "25 - CAP�TULO 44 A 49" }) ) == 0
                         AAdd(aCapTec,{ "25 - CAP�TULO 44 A 49", 25, 44, 49, 5 })
                      EndIf                      
                 Case aNCM[i][1] >= 50 .And. aNCM[i][1] <= 63
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "26 - CAP�TULO 50 A 63" }) ) == 0
                         AAdd(aCapTec,{ "26 - CAP�TULO 50 A 63", 26, 50, 63, 6 })
                      EndIf                      
                 Case aNCM[i][1] >= 64 .And. aNCM[i][1] <= 67
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "27 - CAP�TULO 64 A 67" }) ) == 0
                         AAdd(aCapTec,{ "27 - CAP�TULO 64 A 67", 27, 64, 67, 7 })
                      EndIf
                 Case aNCM[i][1] >= 68 .And. aNCM[i][1] <= 70
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "28 - CAP�TULO 68 A 70" }) ) == 0
                         AAdd(aCapTec,{ "28 - CAP�TULO 68 A 70", 28, 68, 70, 8 })
                      EndIf
                 Case aNCM[i][1] == 71
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "29 - CAP�TULO 71" }) ) == 0
                         AAdd(aCapTec,{ "29 - CAP�TULO 71", 29, 71, 0, 9 })
                      EndIf
                 Case aNCM[i][1] == 72 .Or.  aNCM[i][1] == 73
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "30 - CAP�TULO 72 a 73" }) ) == 0
                         AAdd(aCapTec,{ "30 - CAP�TULO 72 a 73", 30, 72, 73, 10 })
                      EndIf
                 Case aNCM[i][1] >= 74 .And. aNCM[i][1] <= 81
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "31 - CAP�TULO 74 a 81" }) ) == 0
                         AAdd(aCapTec,{ "31 - CAP�TULO 74 a 81", 31, 74, 81, 11 })
                      EndIf
                 Case aNCM[i][1] == 82 .Or.  aNCM[i][1] == 83
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "32 - CAP�TULO 82 a 83" }) ) == 0
                         AAdd(aCapTec,{ "32 - CAP�TULO 82 a 83", 32, 82, 83, 12 })
                      EndIf
                 Case aNCM[i][1] >= 84 .And. aNCM[i][1] <= 90
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "33 - CAP�TULO 84 a 90" }) ) == 0
                         AAdd(aCapTec,{ "33 - CAP�TULO 84 a 90", 33, 84, 90, 13 })
                      EndIf
                 Case aNCM[i][1] == 91
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "34 - CAP�TULO 91" }) ) == 0
                         AAdd(aCapTec,{ "34 - CAP�TULO 91", 34, 91, 0, 14 })
                      EndIf                 
                 Case aNCM[i][1] >= 92 .And. aNCM[i][1] <= 97                 
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "35 - CAP�TULO 92 a 97" }) ) == 0
                         AAdd(aCapTec,{ "35 - CAP�TULO 92 a 97", 35, 92, 97, 15 })
                      EndIf                 
                 OtherWise
                      If ( nPos := aScan(aCapTec, {|x| x[1] == "41 - SEM CAP�TULO" }) ) == 0
                         AAdd(aCapTec,{ "41 - SEM CAP�TULO", 41, 98, 99, 16 })
                      EndIf                      
              EndCase
          Next
       EndIf       
    EndIf
End Sequence
Return aCapTec

/*
Fun��o    : EI100ValFiergs
Objetivo  : Realizar a valida��o dos campos que s�o utilizados na gera��o do XML de integra��o
Retorno   : .T./.F.
Autor     : Laercio G Souza Jr
Data      : 14/09/2015
*/
Static Function EI100ValFiergs(cEmbarque)
Local lRet:= .T., i
Local cMsg:= ""
Local cRotina := "FIERGS"
Local aAcordo := {}
Local nPos    := 0
Default cEmbarque := ""

Begin Sequence
	SY0->(DbSetOrder(6))
	EE9->(DbSetOrder(3))
	SY9->(DbSetOrder(2))
	SYU->(DbSetOrder(4))
	/********
	Anexo fatura em PDF
	*******************/	
	If !SY0->(DbSeek(xFilial("SY0")+AvKey(cEmbarque,"Y0_PROCESS")+AvKey(cRotina,"Y0_ROTINA")))
	   cMsg += STR0220 + ENTER
	Else
	   If !FILE("\HistDoc\"+Alltrim(SY0->Y0_ARQPDF))
	      cMsg += STR0221 + ENTER + STR0222 + ENTER
	   EndIf
	EndIf
	/********
	Unidade Medida / Codigo Produto
	*******************************/
	If EE9->(DbSeek(xFilial("EE9") + AvKey(cEmbarque,"EE9_PREEMB")))
	   cMsg1 := cMsg2 := cMsg3 := ""
	   Do While EE9->(!Eof()) .And. EE9->EE9_PREEMB == AvKey(cEmbarque,"EE9_PREEMB")
	      /********
	      Valida Unidade de Medida
	      ************************/
	      If !SYU->(DbSeek(xFilial("SYU") + cYUDESP + UN_MEDIDA + AvKey(AllTrim(EE9->EE9_UNIDAD),"YU_EASY")))
	         cMsg1 += STR0223 + cValToChar(Alltrim(EE9->EE9_UNIDAD)) + ENTER 
	      EndIf
	      
	      /********
	      Valida Produto (Item)
	      *********************/
	      If !SYU->(DbSeek(xFilial("SYU") + cYUDESP + PRODUTO + AvKey(AllTrim(EE9->EE9_COD_I),"YU_EASY") ))
	         cMsg2 += STR0224 + cValToChar(Alltrim(EE9->EE9_COD_I)) + ENTER 
	      EndIf
	      
	      /******** NORMA
	      Valida Norma (Uma norma possui um acordo associado, direto no cadastro de Norma)
	      *********************************************************************************/
	      If !Empty(EE9->EE9_CODNOR)
	         EEI->(DbSeek(xFilial("EEI") + EE9->EE9_CODNOR))
	         /******** NORMA ACORDO MERCADO COMUM
	         * Deve Validar o de/Para da norma apenas se n�o for uma Norma para Acordo Comercial de Mercado Comum
	         *****************************************************************************************************/	                   
           //MFR OSSME-6139 25/08/2021 
	         //If EEI->EEI_ACCOME <> "1"
            If EEI->(fieldPos("EEI_ACOCOM")) == 0 .Or. EEI->EEI_ACOCOM <> "1"
	            If !SYU->(DbSeek(xFilial("SYU") + cYUDESP + NORMA + AvKey(AllTrim(EE9->EE9_CODNOR),"YU_EASY")))
	               cMsg3 += STR0225 + cValToChar(Alltrim(EE9->EE9_CODNOR)) + ENTER
	            EndIF 
	         Else
	            //
	            //Valida Acordo Comercial
	            //
	            EEI->(DbSeek(xFilial("EEI")+EE9->EE9_CODNOR))
	            If Empty(EEI->EEI_ACCOME)
	               cMsg3 += STR0226 + cValToChar(Alltrim(EE9->EE9_CODNOR)) + ENTER
	            Else
	               If !SYU->(DbSeek(xFilial("SYU") + cYUDESP + ACORDO + AvKey(AllTrim(EEI->EEI_ACCOME),"YU_EASY")))
	                  cMsg3 += STR0227 + cValToChar(Alltrim(EEI->EEI_ACCOME)) + ENTER
	               EndIf
	            EndIf
	         EndIf           
	      Else
	         cMsg3 += STR0228 + cValToChar(Alltrim(EE9->EE9_COD_I)) + ENTER
	      EndIf
	      EE9->(DbSkip())
	   EndDo
	   cMsg += cMsg1 + cMsg2 + cMsg3
	EndIf
	
	/********
	Pa�s Consignatario
	******************/
	If SA1->(DbSeek(xFilial("SA1") + EEC->(EEC_CONSIG+EEC_COLOJA)))
	   If Empty(SA1->A1_PAIS)
	      cMsg += STR0229 + cValToChar(Alltrim(EEC->EEC_CONSIG)) + ENTER
	   EndIf
	   
	   If !SYU->(DbSeek(xFilial("SYU") + cYUDESP + PAIS + SA1->A1_PAIS))
	      cMsg += STR0230 + cValToChar(Alltrim(SA1->A1_PAIS)) + ENTER
	   EndIf
	EndIf
	
	/********
	Pa�s Importador
	***************/
	If SA1->(DbSeek(xFilial("SA1") + EEC->(EEC_IMPORT+EEC_IMLOJA)))
	   If Empty(SA1->A1_PAIS)
	      cMsg += STR0231 + cValToChar(Alltrim(EEC->EEC_IMPORT)) + ENTER
	   EndIf
	   
	   If !SYU->(DbSeek(xFilial("SYU") + cYUDESP + PAIS + SA1->A1_PAIS))
	      cMsg += STR0232 + cValToChar(Alltrim(SA1->A1_PAIS)) + ENTER
	   EndIf
	EndIf
	
	/********
	Pa�s Destino
	************/
	If SY9->(DbSeek(xFilial("SY9") + EEC->EEC_DEST  ))
	   If !SYU->(DbSeek(xFilial("SYU") + cYUDESP + PAIS + SY9->Y9_PAIS))
	      cMsg += STR0233 + cValToChar(Alltrim(SY9->Y9_PAIS)) + ENTER
	   EndIf	   
	EndIf
	
	/********
	Valida se todos os itens utilizam o mesmo acordo comercial
	**********************************************************/
	/*If Empty(cMsg)
	   EE9->(DbSeek(xFilial("EE9") + AvKey(cEmbarque,"EE9_PREEMB")))
	   Do While EE9->(!Eof()) .And. EE9->EE9_PREEMB == AvKey(cEmbarque,"EE9_PREEMB")
	      EEI->(DbSeek(xFilial("EEI")+EE9->EE9_CODNOR))
	      If Len(aAcordo) == 0 //Item + Norma + Acordo
	         aAdd(aAcordo,{EE9->EE9_COD_I,EE9->EE9_CODNOR,EEI->EEI_ACCOME}) 
	      Else
	         If (nPos := aScan(aAcordo, {|x| x[3] == EEI->EEI_ACCOME })) == 0
	            aAdd(aAcordo,{EE9->EE9_COD_I,EE9->EE9_CODNOR,EEI->EEI_ACCOME})
	         EndIf
	      EndIf
	      EE9->(DbSkip())
	   EndDo
	   If Len(aAcordo) > 1
	      cMsg := STR0234
	      nTam := Len(cMsg)
	      cMsg += ENTER + REPLICATE("-",nTam) + ENTER
	      For i := 1 To Len(aAcordo)
	        cMsg += STR0235 + aAcordo[i][1] + ENTER
	        cMsg += STR0236 + aAcordo[i][2] + ENTER
	        cMsg += STR0237 + aAcordo[i][3] + ENTER + REPLICATE("-",nTam) + ENTER
	      Next
	   EndIf
	EndIf */
End Sequence    

If !Empty(cMsg)
   EECView(cMsg,STR0174)
   lRet := .F.
EndIf

Return lRet

/*
Fun��o    : EI100Base64
Objetivo  : Realizar a leitura e convers�o de um arquivo para Base64 para poder ser utilizado no XML do FIERGS
Retorno   : String com a convers�o do documento
Autor     : Laercio G Souza Jr
Data      : 16/09/2015
*/
Function EI100Base64(cNameFile)
Local cBuffer := cString := "", cString2 := "", i, nLimite, nCount
Local cFile   := "\HistDoc\"
Default cNameFile := ""

Begin Sequence

	If !Empty(cNameFile)
	   
	   cFile := cFile + ALLTRIM(cNameFile)
	   nHandle := EasyOpenFile(cFile,0)
	   If nHandle == -1
	      MsgInfo(STR0190 + ALLTRIM(cNameFile), STR0171)
	      cString := "Erro" 
	      Break
	   EndIf
	   
	   nSize := Fseek(nHandle,0,2)
	   Fseek(nHandle,0)
	   If (nSize/1024) >= 756
	      MsgInfo(STR0191 + ALLTRIM(cNameFile) + STR0238, STR0171)
	      cString := "Erro"
	      Break
	   ElseIf nSize <= 0
	      MsgInfo(STR0191 + ALLTRIM(cNameFile), STR0171)
	      cString := "Erro"
	      Fclose(nHandle)
	      Break
	   EndIf
	   
	   cBuffer := Space(nSize)
	   nRead   := FRead(nHandle,@cBuffer,nSize)
	   Fclose(nHandle)
	   
	   If nRead < nSize
	      MsgInfo(STR0191 + ALLTRIM(cNameFile), STR0171)
	      cString := "Erro"
	      Break
	   EndIf
	   
	   cString := Encode64(cBuffer)
	   nLimite := INT( Len(cString)/76 )+1
	   nCount  := 1
	   For i := 1 To nLimite
	      cString2 += SubStr(cString, nCount, 76) + If( i <> nLimite, ENTER,"")
	      nCount += 76
	   Next
	   
	EndIf	
End Sequence

cString2 := if( !empty(cString) .and. alltrim(upper(cString)) == "ERRO", cString, ALLTRIM(cString2))

Return cString2

/*
Fun��o    : FiergsDados
Objetivo  : Montar o array de dados para gera��o do certificado origem fiergs
Retorno   : array, {campo xml, dados}
Autor     : Laercio G Souza Jr
Data      : 18/09/2015
*/
Static Function FiergsDados(cPreemb, cUndAnas, cUndReti, aCTRange)
Local nValFobT   := nValFatAd := nPesLq := nPesBt := 0, nCont := 1
Local lTriangular:= .F., lOk
Local cCodNorma  := ""
Local cCOInfAdc  := ""
Local aProd      := {}
Local cImpEstado := "" 
Local cImpCEP    := ""
local lCpoDscImp := .F.
local lCpoDscCon := .F.
//Arrays para utilizar nos pontos de entrada
Private aRetorno := {}
Private aItem    := {}

Default cPreemb  := ""
Default cUndAnas := ""
Default cUndReti := ""

lCpoDscImp := VldCpoReal("EEC","EEC_IMPODE")
lCpoDscCon := VldCpoReal("EEC","EEC_CONSDE")

Begin Sequence
	
	EEC->(DbSetOrder(1))
	IndRegua("WorkNR",cArqWKNR+TEOrdBagExt(),"WK_CODNOR+WK_ACCOME")
	
	If EEC->(DbSeek(xFilial("EEC") + AvKey(cPreemb,"EEC_PREEMB")))
	   /**********
	   Anexo PDF da Fatura Comercial - Base64
	   *****************************************************************************/
	   SY0->(DbSetOrder(6))
	   SY0->(DbSeek(xFilial("SY0") + EEC->EEC_PREEMB + AvKey("FIERGS","Y0_ROTINA")))
	   AADD(aRetorno,{"Arquivo"			, "#ARQBASE64#"						})/*EI100Base64(SY0->Y0_ARQPDF)*/
	   AADD(aRetorno,{"dataCertificado", EasyTimeStamp(dDataBase,.T.,.F.) })
	   AADD(aRetorno,{"dataFatura" , EasyTimeStamp(SY0->Y0_DATA,.T.,.F.) })
	   AADD(aRetorno,{"nomeArquivo",Alltrim(SY0->Y0_DOC)+".pdf"	}) // GFP - 15/03/2016
	   
	   /**********
	   Despachante associado ao embarque
	   *****************************************************************************/	   
	   
	   EEB->(DbSetOrder(1))
	   SYU->(DbSetOrder(4))
	   SY5->(DbSetOrder(3))
	   If EEB->(DbSeek(xFilial("EEB") + EEC->EEC_PREEMB))
	      SY5->(DbSeek(xFilial("SY5") + AvKey("6-DESPACHANTE","Y5_TIPOAGE") + EEB->EEB_CODAGE)) 
	      If SYU->(DbSeek(xFilial("SYU") + cYUDESP + DESPACHANTE + AvKey(AllTrim(SY5->Y5_COD),"YU_EASY"))) .And. SYU->YU_ORIGEM == "EEC"
	         AADD(aRetorno,{"cnpjDespachante",0						})
	         AADD(aRetorno,{"idDespachante"  ,Alltrim(SYU->YU_GIP_1)})
	      Else
	         AADD(aRetorno,{"cnpjDespachante",If(!Empty(SY5->Y5_NRCPFCG),Alltrim(SY5->Y5_NRCPFCG),0)})
	         AADD(aRetorno,{"idDespachante"  ,0														})
	      EndIf
	   Else
	      AADD(aRetorno,{"cnpjDespachante",0})
	      AADD(aRetorno,{"idDespachante"  ,0})
	   EndIf
	   
	   /**********
	   Exportador associado ao embarque
	   Se o c�digo exportador estiver vazio o sistema assume o c�digo do fornecedor
	   *****************************************************************************/
	   SYU->(DbSetOrder(1))
	   SA2->(DbSetOrder(1))
	   cChave := If(!Empty(EEC->EEC_EXPORT) ,EEC->(EEC_EXPORT+EEC_EXLOJA) ,EEC->(EEC_FORN+EEC_FOLOJA) )
	   If SYU->(DbSeek(xFilial("SYU") + cYUDESP + EXPORTADOR + cChave )) .And. SYU->YU_ORIGEM == "EEC" 
	      AADD(aRetorno,{"cnpjExportador",0						})
	      AADD(aRetorno,{"idExportador"  ,Alltrim(LEFT(SYU->YU_GIP_1,30))})
	   Else
	      SA2->(DbSeek(xFilial("SA2") + cChave ))
	      AADD(aRetorno,{"cnpjExportador",If(!Empty(SA2->A2_CGC),Alltrim(SA2->A2_CGC),0)})
	      AADD(aRetorno,{"idExportador"  ,0												})
	   EndIf
	   
	   /**********
	   Informa��es do importador do processo
	   *****************************************************************************/
	   //RMD - 18/08/16 - Considera dados do endere�o complementar
	   SA1->(DbSetOrder(1))
	   SA1->(DbSeek(xFilial("SA1") + EEC->(EEC_IMPORT+EEC_IMLOJA)))
	   EXJ->(DbSetOrder(1))
	   If EXJ->(FieldPos("EXJ_END") > 0 .And. FieldPos("EXJ_BAIRRO") > 0 .And. FieldPos("EXJ_MUN") > 0);
	      .And. EXJ->(DbSeek(xFilial()+EEC->(EEC_IMPORT+EEC_IMLOJA)))
	      cImpBairro := Alltrim(LEFT(If(!Empty(EXJ->EXJ_BAIRRO), EXJ->EXJ_BAIRRO, SA1->A1_BAIRRO), 100))
	      cImpCidade := Alltrim(LEFT(If(!Empty(EXJ->EXJ_MUN), EXJ->EXJ_MUN, SA1->A1_MUN), 100))
	      cImpEstado := Alltrim(LEFT(If(!Empty(EXJ->EXJ_EST), EXJ->EXJ_EST, SA1->A1_EST), 100))
         cImpCEP    := Alltrim(LEFT(If(!Empty(EXJ->EXJ_CEP), EXJ->EXJ_CEP, SA1->A1_CEP), 100))
         cImpEnd    := Alltrim(LEFT(If(!Empty(EXJ->EXJ_END), EXJ->EXJ_END, SA1->A1_END),200)) + IIF(!Empty(cImpBairro),", " + cImpBairro,"") + IIF(!Empty(cImpEstado),", " + cImpEstado,"") + IIF(!Empty(cImpCEP),", " + cImpCEP,"")
	   Else
	      cImpBairro := Alltrim(LEFT(SA1->A1_BAIRRO, 100))
	      cImpCidade := Alltrim(LEFT(SA1->A1_MUN, 100))
         cImpEstado := Alltrim(LEFT(SA1->A1_EST, 100))
	      cImpCEP    := Alltrim(LEFT(SA1->A1_CEP, 100))
         cImpEnd    := Alltrim(LEFT(SA1->A1_END,200)) + IIF(!Empty(cImpBairro),", " + cImpBairro,"") + IIF(!Empty(cImpEstado),", " + cImpEstado,"") + IIF(!Empty(cImpCEP),", " + cImpCEP,"")
	   EndIf

       AADD(aRetorno,{"importadorBairro"  ,AvTrocaChar(cImpBairro)	})
	   AADD(aRetorno,{"importadorCidade"  ,AvTrocaChar(cImpCidade)	})
	   AADD(aRetorno,{"importadorEndereco",AvTrocaChar(cImpEnd)		})

       AADD(aRetorno,{"importadorCnpj"    ,Alltrim(LEFT(SA1->A1_CGC,20))		})
       AADD(aRetorno,{"importadorEmail"   ,Alltrim(LEFT(SA1->A1_EMAIL,255))	})	   
       AADD(aRetorno,{"importadorFax"     ,Alltrim(LEFT(SA1->A1_FAX,20))		})
       AADD(aRetorno,{"importadorFone"    ,Alltrim(LEFT(SA1->A1_TEL,20))		})
       AADD(aRetorno,{"importadorNome"    ,AvTrocaChar(Alltrim(LEFT(if( lCpoDscImp .and. !empty(EEC->EEC_IMPODE) , EEC->EEC_IMPODE ,SA1->A1_NOME),200) ) ) })
       AADD(aRetorno,{"importadorURL"     ,Alltrim(LEFT(SA1->A1_HPAGE,255))	})	      
       SYU->(DbSeek(xFilial("SYU") + cYUDESP + PAIS + SA1->A1_PAIS))
       AADD(aRetorno,{"siglaPaisImportador"    ,Alltrim(LEFT(SYU->YU_GIP_1,3))})
	   
	   /**********
	   Informa��es do consignatario do processo
	   *****************************************************************************/
	   If !Empty(EEC->EEC_CONSIG) .And. !Empty(EEC->EEC_COLOJA)//Tem consignatario no processo
         SA1->(DbSeek(xFilial("SA1") + EEC->(EEC_CONSIG+EEC_COLOJA)))
      Else //Nao tem consignatario no processo, utilizar os dados do Importador
         SA1->(DbSeek(xFilial("SA1") + EEC->(EEC_IMPORT+EEC_IMLOJA)))         	   
      EndIf
      If EXJ->(FieldPos("EXJ_END") > 0 .And. FieldPos("EXJ_BAIRRO") > 0 .And. FieldPos("EXJ_MUN") > 0);
	      .And. EXJ->(DbSeek(xFilial()+SA1->(A1_COD+A1_LOJA)))
         cImpBairro := Alltrim(LEFT(If(!Empty(EXJ->EXJ_BAIRRO), EXJ->EXJ_BAIRRO, SA1->A1_BAIRRO), 100))
         cImpCidade := Alltrim(LEFT(If(!Empty(EXJ->EXJ_MUN), EXJ->EXJ_MUN, SA1->A1_MUN), 100))
         cImpEstado := Alltrim(LEFT(If(!Empty(EXJ->EXJ_EST), EXJ->EXJ_EST, SA1->A1_EST), 100))
         cImpCEP    := Alltrim(LEFT(If(!Empty(EXJ->EXJ_CEP), EXJ->EXJ_CEP, SA1->A1_CEP), 100))
         cImpEnd    := Alltrim(LEFT(If(!Empty(EXJ->EXJ_END), EXJ->EXJ_END, SA1->A1_END),200)) + IIF(!Empty(cImpBairro),", " + cImpBairro,"") + IIF(!Empty(cImpEstado),", " + cImpEstado,"") + IIF(!Empty(cImpCEP),", " + cImpCEP,"")
      Else
         cImpBairro := Alltrim(LEFT(SA1->A1_BAIRRO, 100))
         cImpCidade := Alltrim(LEFT(SA1->A1_MUN, 100))
         cImpEstado := Alltrim(LEFT(SA1->A1_EST, 100))
         cImpCEP    := Alltrim(LEFT(SA1->A1_CEP, 100))
         cImpEnd    := Alltrim(LEFT(SA1->A1_END,200)) + IIF(!Empty(cImpBairro),", " + cImpBairro,"") + IIF(!Empty(cImpEstado),", " + cImpEstado,"") + IIF(!Empty(cImpCEP),", " + cImpCEP,"")
      EndIf      

      AADD(aRetorno,{"consignatarioEndereco",AvTrocaChar(cImpEnd)})
      AADD(aRetorno,{"consignatarioNome"    ,AvTrocaChar(Alltrim(LEFT( if( lCpoDscCon .and. !empty(EEC->EEC_CONSDE) , EEC->EEC_CONSDE , SA1->A1_NOME) ,200) )) })
      SYU->(DbSeek(xFilial("SYU") + cYUDESP + PAIS + SA1->A1_PAIS))
      AADD(aRetorno,{"siglaPaisConsignatario"    ,Alltrim(LEFT(SYU->YU_GIP_1,3))})

	   /**********
	   ID Unidade Analise/Retirada
	   *****************************************************************************/
	   If SX5->(DbSeek(xFilial('SX5') + "E7"))
  	      Do While SX5->(!Eof()) .And. SX5->X5_TABELA == "E7"
  	         If AllTrim(SX5->X5_DESCRI) == AllTrim(cUndAnas)
  	            AADD(aRetorno,{"idUnidadeAnalise",AllTrim(SX5->X5_CHAVE)})
  	            Exit
  	         EndIf
  	         SX5->(DbSkip())
  	      EndDo
  	   EndIf
  	   If SX5->(DbSeek(xFilial('SX5') + "E7"))
  	      Do While SX5->(!Eof()) .And. SX5->X5_TABELA == "E7"
  	         If AllTrim(SX5->X5_DESCRI) == AllTrim(cUndReti)
  	            AADD(aRetorno,{"idUnidadeRetirada",AllTrim(SX5->X5_CHAVE)})
  	            Exit
  	         EndIf
  	         SX5->(DbSkip())
  	      EndDo
  	   EndIf
  	   
  	   /**********
	   Local de embarque //Municipio destino
	   *****************************************************************************/
  	   SY9->(DbSetOrder(2))
  	   SY9->(DbSeek(xFilial("SY9") + EEC->EEC_ORIGEM))
  	   AADD(aRetorno,{"localEmbarque",AllTrim(SY9->Y9_CIDADE)})
  	   SY9->(DbSeek(xFilial("SY9") + EEC->EEC_DEST  ))
  	   AADD(aRetorno,{"municipio"    ,AllTrim(SY9->Y9_CIDADE)})
	   SYU->(DbSeek(xFilial("SYU") + cYUDESP + PAIS + SY9->Y9_PAIS)) //Pa�s Destino
	   AADD(aRetorno,{"siglaPaisDestino"    ,Alltrim(LEFT(SYU->YU_GIP_1,3))})
  	   
  	   /**********
	   Informa�oes sobre produtor
	   *****************************************************************************/   
	   EE9->(DbSetOrder(3))
	   EE9->(DbSeek(xFilial("EE9") + AvKey(cPreemb,"EE9_PREEMB")))
	   SA2->(DbSeek(xFilial("SA2") + EE9->(EE9_FABR+EE9_FALOJA)))
	   AADD(aRetorno,{"produtorEndereco",AvTrocaChar(AllTrim(SA2->A2_END))		})
	   AADD(aRetorno,{"produtorNome"    ,AvTrocaChar(AllTrim(SA2->A2_NOME))		})
	   
	   /**********
	   Informa�oes sobre os itens
	   Array Itens do Processo
	   ****************************************************************/	   
	   EE9->(DbSeek(xFilial("EE9") + AvKey(cPreemb,"EE9_PREEMB")))
	   Do While EE9->(!Eof()) .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB
	      SB1->(DbSeek(xFilial("SB1") + EE9->EE9_COD_I))	      
	      /**********
	      Valida��o do Capitulo Tecnico escolhido para gerar o XML
	      aCTRange
	      {Capitulo Tecnico, ID Capitulo, Inicio Range, Fim Range}
	      ********************************************************/
	      nCapTec := Val(SubStr(EE9->EE9_POSIPI,1,2))
	      /* Se for Zero � apenas o inicio */
	      If aCTRange[1][4] == 0
	         If nCapTec <> aCTRange[1][3]
	            EE9->(DBSkip())
	         EndIf
	      Else
	         If nCapTec >= aCTRange[1][3] .And. nCapTec <= aCTRange[1][4]
	            lOk := .T.
	         Else
	            lOk := .F.
	         EndIf
	         If !lOk
	            EE9->(DBSkip())
	            Loop
	         EndIf  
	      EndIf
	      
	      If !WorkNR->(DbSeek(EE9->EE9_CODNOR))
	         EE9->(DBSkip())
	         Loop
	      EndIf
	      
	      nValFobT	+= EE9->EE9_PRCTOT
	      nPesLq		+= EE9->EE9_PSLQTO /*Peso Liq. Total*/
	      nPesBt		+= EE9->EE9_PSBRTO /*Peso Bruto Total*/
	      cCodNorma 	:= If(Empty(cCodNorma), EE9->EE9_CODNOR, cCodNorma) 
	      aItem		:= {}
	      
          cDescricao := AllTrim(MSMM(EE9->EE9_DESC, 996,,, LERMEMO))
          cDescricao := StrTran(cDescricao, ENTER, " ")
          
          cDescricao += " CODE " + AllTrim(EE9->EE9_POSIPI)
          If !Empty(EE9->EE9_NALSH)
             cDescricao += " NALADI " + AllTrim(EE9->EE9_NALSH)
          EndIf
	      
	      AADD(aItem,{"codigoNomenclaturaComum"	,AllTrim(EE9->EE9_POSIPI)	})
	      AADD(aItem,{"descricacaoProduto"		,AvTrocaChar(AllTrim(cDescricao))		})
	      AADD(aItem,{"ordem"					,nCont++						}) /*AllTrim(EE9->EE9_SEQUEN)*/
	      AADD(aItem,{"qtdPesoLiquido"			,EE9->EE9_PSLQTO				})
	      AADD(aItem,{"valorFob"				,EE9->EE9_PRCTOT				})
	      
	      /**********
	      Deve mandar a informa��o do id norma, apenas para norma que n�o foram do acordo mercado comum
	      *********************************************************************************************/
	      EEI->(DbSeek(xFilial("EEI") + EE9->EE9_CODNOR)) //LGS-04/03/2016
         //MFR OSSME-6139 25/08/2021 
         //If EEI->EEI_ACCOME <> "1" 
         If EEI->(fieldPos("EEI_ACOCOM")) == 0 .Or.  EEI->EEI_ACOCOM <> "1"
	         SYU->(DbSeek(xFilial("SYU") + cYUDESP + NORMA + AvKey(AllTrim(EE9->EE9_CODNOR),"YU_EASY"))) 
	         AADD(aItem,{"idNormaOrigem"				,AllTrim(SYU->YU_GIP_1)		}) 
	      EndIf 
	    
	      /**********
	      N�o � obrigatorio, se precisar enviar precisa mapear a informa��o 
	      ***************************************************************************************/
	      AADD(aItem,{"marca"						,"desc. marca"				})
	      AADD(aItem,{"observacao"					,"desc. obs."					})
	      /**************************************************************************************/
	      SYU->(DbSeek(xFilial("SYU") + cYUDESP + PRODUTO + AvKey(AllTrim(EE9->EE9_COD_I),"YU_EASY")))
	      AADD(aItem,{"idDeclaracao"				,AllTrim(SYU->YU_GIP_1)		})      
	      SYU->(DbSeek(xFilial("SYU") + cYUDESP + UN_MEDIDA + AvKey(AllTrim(EE9->EE9_UNIDAD),"YU_EASY")))
	      AADD(aItem,{"idUnidadeMedida"			,AllTrim(SYU->YU_GIP_1)		})
	      
	      /**********
	      Ponto de entrada para manipular o Array aItem
	      *******************************************************/	      	            
	      If EasyEntryPoint("EECEI100")
	         ExecBlock("EECEI100", .F., .F., "ALTERA_ARRAY_AITEM")
	      EndIf
	      
	      AADD(aProd, aItem)   
	      EE9->(DBSkip())
	   EndDo
	   
	   /**********
	   Adicionando o array dos itens ao principal para gerar o xml de envio 
	   ******************************************************************************/
	   AADD(aRetorno,{"ArrayItens", aProd })   
	   
	   /**********
	   Utilizo o FOB calculado pelos Itens, por que � preciso filtrar os itens que se
	   enquadr�o ao capitulo tecnico escolhido para gerar o xml. - EEC->EEC_VLFOB 
	   ******************************************************************************/
	   AADD(aRetorno,{"valorFatura", DITrans(nValFobT,2)  })
	   
	   /**********
	   Invoice adicional do embarque
	   *****************************************************************************/
	   EXP->(DbSetOrder(1))
	   If EXP->(DbSeek(xFilial("EXP") + EEC->EEC_PREEMB))
	      AADD(aRetorno,{"dataFaturaAdicional" ,EasyTimeStamp(EXP->EXP_DTINVO,.T.,.F.) })
	      AADD(aRetorno,{"faturaAdicional"     ,Alltrim(LEFT(EXP->EXP_NRINVO,30))})
	      AADD(aRetorno,{"faturaComercial"     ,Alltrim(LEFT(EXP->EXP_NRINVO,30))})
	      /**********
	      Fa�o o rateio porque o FOB � calculado com base nos itens que se enquadrao no 
	      filtro do capitulo tecnico, dessa forma nao posso usar o FOB do Embarque
	      ******************************************************************************/	      
	      nValFatAd := DITrans( DITrans((EXP->EXP_VLFOB/EEC->EEC_VLFOB),2) * nValFobT,2) 
	      AADD(aRetorno,{"valorFaturaAdicional", nValFatAd 	})
	   Else
	      AADD(aRetorno,{"faturaComercial"     ,Alltrim(EEC->EEC_PREEMB)	})
	   EndIf
	   
	   /**********
	   Opera��o Triangular / Peso Bruto / Peso Liquido / Informacoes Adicionais
	   *****************************************************************************/
  	   If !Empty(EEC->EEC_EXPORT)
  	      lTriangular := EEC->EEC_FORN <> EEC->EEC_EXPORT
  	   EndIf
  	   AADD(aRetorno,{"operacaoTriangular",If(lTriangular,"S","N")	})
  	   AADD(aRetorno,{"pesoBruto"  , DITrans(nPesBt,3) }) /*EEC->EEC_PESBRU*/
  	   AADD(aRetorno,{"pesoLiquido", DITrans(nPesLq,3) }) /*EEC->EEC_PESLIQ*/
  	   
  	   cCOInfAdc := MSMM(EEC->EEC_INFCOF,AVSX3("EEC_VMDCOF",AV_TAMANHO),,,LERMEMO)
  	   AADD(aRetorno,{"informacoesAdicionais",AllTrim(Left(EncodeUTF8(cCOInfAdc),2000))	})

	   /**********
	   observa��o da capa do processo
	   *****************************************************************************/
  	   AADD(aRetorno,{"observacao"			  ,alltrim( EncodeUTF8( MSMM(EEC->EEC_CODOBP,AVSX3("EEC_OBSPED",AV_TAMANHO),,,LERMEMO) ) )} )

	   /**********
	   Acordo Comercial / Capitulo Tecnico
	   {Capitulo Tecnico, ID Capitulo, Inicio Range, Fim Range}
	   *****************************************************************************/
	   EEI->(DbSetOrder(1))
	   EEI->(DbSeek(xFilial("EEI")+AvKey(cCodNorma,"EEI_COD")))
	   SYU->(DbSeek(xFilial("SYU") + cYUDESP + ACORDO + AvKey(AllTrim(EEI->EEI_ACCOME),"YU_EASY")))
	   AADD(aRetorno,{"idAcordo"      , AllTrim(SYU->YU_GIP_1) })
	   cCapTec := aCTRange[1][2]
	   AADD(aRetorno,{"idCapituloTec" , cCapTec	      })
	   
	   /**********
	   Usuario / Senha / Representante Legal / Justificativa Fatura
	   A Justificativa � feito na hora do envio do arquivo
	   *****************************************************************************/
	   EWQ->(DbSetOrder(1))
	   If EWQ->(DbSeek(xFilial()+AvKey(cUserName,"EWQ_USER")+AvKey("FIERGS" ,"EWQ_ROTORI")+AvKey("USUARIO","EWQ_PARAM") ))
	      AADD(aRetorno,{"usuario",	AllTrim(EWQ->EWQ_XCONT)	})
	   Else
	      AADD(aRetorno,{"usuario",	"#USUARIO#"			})
	   EndIf
	   If EWQ->(DbSeek(xFilial()+AvKey(cUserName,"EWQ_USER")+AvKey("FIERGS" ,"EWQ_ROTORI")+AvKey("SENHA","EWQ_PARAM") ))
	      AADD(aRetorno,{"senha",	cValToChar(DECRYPF(AllTrim(EWQ->EWQ_XCONT)))	}) //LGS-17/02/2016 - Descriptografa a senha	      
	   Else
	      AADD(aRetorno,{"senha",	"#SENHA#" 				})
	   EndIf
	   If EWQ->(DbSeek(xFilial()+AvKey(cUserName,"EWQ_USER")+AvKey("FIERGS" ,"EWQ_ROTORI")+AvKey("RPLEGAL","EWQ_PARAM") ))
	      AADD(aRetorno,{"representantesLegais",	AllTrim(EWQ->EWQ_XCONT)	})
	   Else
	      AADD(aRetorno,{"representantesLegais",	"#RPLEGAL#" 		})
	   EndIf	   
	   AADD(aRetorno,{"justificaFatura",	"#JUSTIFICAFATURA#"  	})
	   
	   /**********
	   Ponto de entrada para manipular o Array aRetorno (Inf. montar xml)
	   ******************************************************************/
	   If EasyEntryPoint("EECEI100")
	      ExecBlock("EECEI100", .F., .F., "ALTERA_ARRAY_ARETORNO")
	   EndIf
	
	EndIf

End Sequence

Return aRetorno

/*
Funcao    : VldCpoReal()
Objetivos : Validar se o campo � real e existe na tabela
Autor     : Bruno Akyo Kubagawa
Data/Hora : 
Obs.      : 
*/
static function VldCpoReal(cTb,cCampo)
   local lRet := .F.

   default cTb    := ""
   default cCampo := ""

   if !empty(cTb) .and. !empty(cCampo)
      cReal := alltrim(upper(GetSX3Cache(cCampo, "X3_CONTEXT")))
      lRet := !(cReal == "V") .and. (cTb)->(ColumnPos(cCampo)) > 0
   endif

return lRet

Static Function MenuDef(cOrigem,lMBrowse)

Local aRotina := {}
Default cOrigem  := AvMnuFnc()
Default lMBrowse := OrigChamada()

Do Case
   Case cOrigem == "EI100FIERG"
      
      aAdd(aRotina, { "", "", 0, 2 }) 
      	  	
   EndCase
   

Return aRotina
