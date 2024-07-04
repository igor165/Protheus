/*
Programa        : AVCRW.PRW
Objetivo        : Integracao com Crystal Report's
Autor           : Cristiano A. Ferreira
Data/Hora       : 25/10/2000 19:34
Obs.            : AVGCRW32.EXE - Programa de interface com o Crystal
*/

#include "EEC.CH"
#include "AVCRW.CH" 
#include "ap5mail.ch"
#Include "XmlXFun.ch"
#INCLUDE "fileio.ch"
#INCLUDE "shell.ch"

#Define MAXIMO_STR (1024*1024)-1   // Tamanho máximo de caracteres em uma string
#Define MARGEM_STR 50000           // Margem de Segurança para controle de variável do tipo String
#DEFINE DATA_BASE "D"+Chr(00)+"a"+Chr(00)+"t"+Chr(00)+"a"+Chr(00)+"b"+Chr(00)+"a"+Chr(00)+"s"+Chr(00)+"e"
#DEFINE QESession "Q"+Chr(00)+"E"+Chr(00)+"S"+Chr(00)+"e"+Chr(00)+"s"+Chr(00)+"s"+Chr(00)+"i"+Chr(00)+"o"+Chr(00)+"n" 
//#DEFINE PromptManager "P"+Chr(00)+"r"+Chr(00)+"o"+Chr(00)+"m"+Chr(00)+"p"+Chr(00)+"t"+Chr(00)+"M"+Chr(00)+"a"+Chr(00)+"n"+Chr(00)+"a"+Chr(00)+"g"+Chr(00)+"e"+Chr(00)+"r"
#define CRW_NewPage "### " + STR0040 + " ##########"

/*
Funcao   : E_ARQCRW(lABRE)
Autor    : Heder M Oliveira    
Data     : 17/09/99 16:29
Revisao  : 17/09/99 16:29
Uso      : Abre/Fecha arquivos padrao Crystal
Recebe   : .T./.F.                                	
Retorna  : .T. 
Alteracao: Cristiano A Ferreira 21/10/2000
           Compatilizar com acesso remoto
*/
Function E_ARQCRW(lAbre,lPrint,lAbreForc)

Local lRet:=.T., nSelect := Select()
Local aArqs, aInds
Local nCont, lTOP
Local cDirClient := DirClient()
Local cDRVOpen

// ** JPM - 24/02/06 - Reabrir arquivos Crystal quando é mudada a empresa
Local lReabre := .F.

Static cEmpAnterior := SM0->M0_CODIGO
// **

Static lAbrir

Default lAbre := .t.
Default lPrint := .f.
Default lAbreForc := .f.
PRIVATE cDADTOP,aALITOP

// ** JPM - 24/02/06 - Reabrir arquivos Crystal quando é mudada a empresa
If cEmpAnterior <> SM0->M0_CODIGO
   lReabre := .T.
   cEmpAnterior := SM0->M0_CODIGO
   // ** reinicializa variáveis públicas
   //cDirRpt := Nil
   //cDirCrw := Nil
   //lAmbRmt := Nil FSM - 13/05/11
   cFileHeader := Nil
   cFileDetail := Nil
EndIf


// by CAF 14/10/2003 - Possibilidade de especificar diretório de gravação dos temp do Crystal
//IF cDirClient == "."
//   //cDirClient := GetWinDir()
//   cDirClient := IF(Left(cModulo,1) == "E",GetTempPath()/*GetWinDir()*/,"C:\") //ER - 31/08/05 - Alteração de função para funcionar em Linux
//Else
//  cDirClient := IF(Right(cDirClient,1)="\",Left(cDirClient,Len(cDirClient)-1),cDirClient)
//   
//  IF !lIsDir(cDirClient)
//     MakeDir(cDirClient)
//  Endif
//Endif


lTOP := .F.

#IFDEF TOP
   //lTOP := EasyGParam("MV_AVG0042",,.F.)  // .T.=TOP E .F.=DBF
   lTOP := TETempBanco() .Or. EasyGParam("MV_AVG0042",,.F.) //RMD - 16/11/17 - Força o uso do arquivo de histórico no banco de dados quando os temporários estiverem no banco
   //RMD - 16/11/17 - Se não tiver arquivo de histórico também força criar no banco
   If !lTop .And. !(File(DirRpt01()+"/"+"HEADER_H"+GetDbExtension()) .And. File(DirRpt01()+"/"+"DETAIL_H"+GetDbExtension()))
      lTOP := .T.
      SetMv("MV_AVG0042", lTop)
   EndIf
#ENDIF

Begin Sequence
   IF lAbrir == Nil
      lAbrir := lAbreForc
   Else
      lAbreForc := lAbrir
   Endif
   
   // by CAF 18/02/2004 - A partir da versã 8.11 não é necessário testar o módulo, pois a chamada da
   // função foi eliminada do SX2.
   /*
   IF ! lAbreForc
      IF cModulo <> "EFF" .And. cModulo <> "EEC"
         Break
      Endif
   Endif
   */

   /*
   AMS - 11/10/2005. Tratamento para utilizar o RDD "DBFCDX" quando o ADS Server for para o RDD local.
   */
   /* Utiliza o driver local quando não for temporário no banco
   If (EasyGetRDD() == "ADSSERVER") //.OR. ("CTREE" $ EasyGetRDD()) //AAF 01/03/2007 - Utilizar driver "DBFCDX" também para CTREE, independente do SO.
      cDRVOpen := "DBFCDX"
   Else
      //If IsSrvUnix()
      //   cDRVOpen := ""
      //Else
      If /*IsSrvUnix() .and./ "CTREE" $ EasyGetRDD() //ER - 14/09/2007 - Para CTREE Linux usa DBFCDX, para CTREE Windows, usa SBFCDXADS.
         cDRVOpen := "DBFCDX"
      Else
         cDRVOpen := "DBFCDXADS"   
      EndIf
   EndIf
   */

   //IF Type("cDirRpt") <> "C" .Or. Type("cDirCrw") <> "C"
      // *** CAF 21/10/2000 Variaveis para o Crystal ...
      //Public cDirRpt := EasyGParam("MV_CRYSTAL")  // Path dos Rpt's
      //Public cDirCrw := ""  // Diretorio de Execucao dos Rpt's
      //Public lAmbRmt := .T. // indica se o ambiente eh remoto ou nao.
      
      /*IF Empty(cDirRpt)
         Help(" ",1,"MV_CRYSTAL")
         Break
      Endif*/
      
      //cDirRpt := AllTrim(cDirRpt)
      //cDirRpt := IF(Right(cDirRpt,1)="\",Left(cDirRpt,Len(cDirRpt)-1),cDirRpt)

     /* IF lAmbRmt // Indica se o ambiente eh remoto
         
         //IF !lIsDir(cDirClient+"\TEMP")          //ER - 31/08/05. A função GetTempPath() já carrega o diretorio Temp
           // MakeDir(cDirClient+"\TEMP")
         //Endif
         
         cDirCrw := cDirClient+"\AVGCRW32" // "AVGCRW32" //"\TEMP\AVGCRW32" // By JPP - 05/06/2006 - 09:35 - Inclusão da Barra "\" Para indicar o diretório AVGCRW32
         IF ! lIsDir(cDirCrw)
            MakeDir(cDirCrw)
         Endif
      Else
         IF SX6->(dbSeek(SM0->M0_CODFIL+"MV_AVG0007")) .Or. SX6->(dbSeek("  "+"MV_AVG0007"))
            cDirCrw := EasyGParam("MV_AVG0007")
         Endif
         
         IF Empty(cDirCrw)
            cDirCrw := GetSrvProfString("ROOTPATH","")
         Endif                  
              
         cDirCrw := AllTrim(cDirCrw)
         cDirCrw := IF(Right(cDirCrw,1)="\",Left(cDirCrw,Len(cDirCrw)-1),cDirCrw)

         cDirCrw += DirRpt01()
      Endif*/            

      Public cFileHeader := "HEADER_P" // Nome do arquivo header_p
      Public cFileDetail := "DETAIL_P" // Nome do arquivo detail_p
      
      IF lAmbRmt
         cFileHeader := CriaTrab(,.f.) // Nome do arquivo header_p
         cFileDetail := CriaTrab(,.f.) // Nome do arquivo detail_p
         While cFileHeader == cFileDetail
            cFileDetail := CriaTrab(,.f.)
         Enddo
      Endif
	  
	  If Select("HEADER_P") > 0
         HEADER_P->(DBCLOSEAREA())
      EndIf
      If Select("DETAIL_P") > 0
         DETAIL_P->(DBCLOSEAREA())
      EndIf	       
	  
	  If !lPrint .And. lAbre .And. Select("HEADER_H") > 0   // TDF - 17/04/2012
         HEADER_H->(DBCLOSEAREA())
      EndIf
      If !lPrint .And. lAbre .And. Select("DETAIL_H") > 0   // TDF - 17/04/2012
         DETAIL_H->(DBCLOSEAREA())
      EndIf
      // ***
   //Endif

   aArqs := { { "HEADER_H" + If( lTOP, "", GetDBExtension() ), "HEADER_H" },;
              { "DETAIL_H" + If( lTOP, "", GetDBExtension() ), "DETAIL_H" },;
              { cFileHeader + /*".dbf"*/ GetDbExtension(), "HEADER_P" },; //RMD - 16/11/17
              { cFileDetail + /*".dbf"*/ GetDbExtension(), "DETAIL_P" } } //RMD - 16/11/17
 
   
   aInds := { { "HEADER_H" + TEOrdBagExt(), "AVG_FILIAL+AVG_SEQREL+AVG_CHAVE", { || AVG_FILIAL + AVG_SEQREL + AVG_CHAVE } },;
              { "DETAIL_H" + TEOrdBagExt(), "AVG_FILIAL+AVG_SEQREL+AVG_CHAVE", { || AVG_FILIAL + AVG_SEQREL + AVG_CHAVE } },;
			  { cFileHeader +  TEOrdBagExt(), "AVG_FILIAL+AVG_SEQREL+AVG_CHAVE", { || AVG_FILIAL + AVG_SEQREL + AVG_CHAVE } },;
			  { cFileDetail +  TEOrdBagExt(), "AVG_FILIAL+AVG_SEQREL+AVG_CHAVE", { || AVG_FILIAL + AVG_SEQREL + AVG_CHAVE } } }

   //checar existencia dos arq para crystal
   IF lAbre  
      
      IF Select("HEADER_P") > 0 
         Break
      Endif
      
      AvCriaArqCrw(aArqs,aInds)

      For nCont:=1 To Len(aArqs)
   
          IF lPrint .And. "_H" $ aArqs[nCont,2]
             Loop
          Endif
   
          //RMD - 16/11/17 - Tratamento Unificado
          //IF lTOP //Verifica a abertura dos arquivos deve ser por TOP ou CODEBASE.
         cDADTOP := aARQS[nCONT,1]
         cALITOP := aARQS[nCont,2]             
			 
 			 If !("_H" $ cAliTop)//RMD - 16/11/17 - Se for temporário no banco a área já estará aberta para os arquivos "_P" (foram criados com E_CRIATRAB na função AvCriaArqCRW)
 			    DbSelectArea(cALITOP)
 			    IndRegua(cALITOP, aINDS[nCONT,1], aINDS[nCONT,2]) 
 			 Else
 			    dbUseArea( .T., If(lTop, "TOPCONN", "DBFCDX"), cDADTOP, cALITOP, .T., .F. )
 			    dbSetIndex( aINDS[ nCont, 1 ] )
 			 EndIf
          
      Next
      
   Else
      
      For nCont:=1 To Len(aArqs)

         IF lPrint .And. "_H" $ aArqs[nCont,2]
            Loop
         Endif

         IF Select(aArqs[nCont,2]) <> 0
            (aArqs[nCont,2])->(dbCloseArea())
         Endif

      Next nCont

   Endif

End Sequence
Select(nSelect)
Return lRet

*--------------------------------------------------------------------
/*
Funcao      : DirRpt01()
Parametros  : --
Retorno     : 
Objetivos   : 
Autor       : Flavio D. Ricardo
Data/Hora   : 23/12/2010 09:30
Revisao     : Guilherme Fernandes Pilan - GFP
Data/Hora   : 03/08/2011 17:50
Obs.        :
*/

Function DirRpt01()

Local cDirRpt := EasyGParam("MV_CRYSTAL")  // Path dos Rpt's

Begin Sequence

   If Empty(cDirRpt)
      Help(" ",1,"MV_CRYSTAL")
      Break
   Endif

   cDirRpt := AllTrim(cDirRpt)
   cDirRpt := IF(Right(cDirRpt,1)="\",Left(cDirRpt,Len(cDirRpt)-1),cDirRpt)

End Sequence

Return cDirRpt

*--------------------------------------------------------------------
/*
Funcao      : DirCrw()
Parametros  : --
Retorno     : 
Objetivos   : 
Autor       : Flavio D. Ricardo
Data/Hora   : 23/12/2010 11:00
Revisao     :
Obs.        :
*/

Function DirCrw()

Local cDirCrw01 := ""

IF lAmbRmt // Indica se o ambiente eh remoto
   // *** GFP - 03/08/2011 - Retirado "\" - Duplicando           
   cDirCrw01 := DirClient()+"AVGCRW32"//"\AVGCRW32" //"\TEMP\AVGCRW32" // By JPP - 05/06/2006 - 09:35 - Inclusão da Barra "\" Para indicar o diretório AVGCRW32
   IF ! lIsDir(cDirCrw01)
      MakeDir(cDirCrw01)
   Endif      

Endif  

Return cDirCrw01


*--------------------------------------------------------------------
/*
Funcao      : AvCriaArqCrw
Parametros  : 
Retorno     : .T./.F.
Objetivos   : Criar arquivos HEADER_P/DETAIL_P,HEADER_H/DETAIL_H
Autor       : Cristiano A. Ferreira
Data/Hora   : 09/10/2000 15:30
Revisao     :
Obs.        :
*/
Static Function AvCriaArqCrw(aArqs,aInds)

Local lRet := .t.
Local i, aStruct, j
Local aDir := Directory(DirRpt01()+"\"+"SC*" + ".dbf")
Local cDRVOpen

Private cDirHeader,cDirDetail
Private aHeader_Str,aDetail_Str

Default aInds := {}

cDirHeader:=DirRpt01()+"\HEADER_P" + GetDBExtension()//".dbf"
cDirDetail:=DirRpt01()+"\DETAIL_P" + GetDBExtension()//".dbf"

   aHeader_Str := {;
     {"AVG_FILIAL","C", FwSizeFilial(),0},; //DFS - 28/09/12 - Tratamento para pegar o tamanho da filial da tabela SY0
     {"AVG_SEQREL","C", 8,0},;
     {"AVG_CHAVE" ,"C", 20,0},;
     {"AVG_C01_10","C", 10,0},;
     {"AVG_C02_10","C", 10,0},;
     {"AVG_C03_10","C", 10,0},; 
     {"AVG_C04_10","C", 10,0},; 
     {"AVG_C05_10","C", 10,0},; 
     {"AVG_C06_10","C", 10,0},; 
     {"AVG_C07_10","C", 10,0},; 
     {"AVG_C08_10","C", 10,0},; 
     {"AVG_C09_10","C", 10,0},; 
     {"AVG_C10_10","C", 10,0},; 
     {"AVG_C01_20","C", 20,0},; 
     {"AVG_C02_20","C", 20,0},; 
     {"AVG_C03_20","C", 20,0},; 
     {"AVG_C04_20","C", 20,0},; 
     {"AVG_C05_20","C", 20,0},; 
     {"AVG_C06_20","C", 20,0},; 
     {"AVG_C07_20","C", 20,0},; 
     {"AVG_C08_20","C", 20,0},; 
     {"AVG_C09_20","C", 20,0},; 
     {"AVG_C10_20","C", 20,0},; 
     {"AVG_C01_30","C", 30,0},; 
     {"AVG_C02_30","C", 30,0},; 
     {"AVG_C03_30","C", 30,0},; 
     {"AVG_C04_30","C", 30,0},; 
     {"AVG_C05_30","C", 30,0},; 
     {"AVG_C01_60","C", 60,0},; 
     {"AVG_C02_60","C", 60,0},; 
     {"AVG_C03_60","C", 60,0},;
     {"AVG_C04_60","C", 60,0},;
     {"AVG_C05_60","C", 60,0},;
     {"AVG_C06_60","C", 60,0},;
     {"AVG_C07_60","C", 60,0},;
     {"AVG_C08_60","C", 60,0},;
     {"AVG_C09_60","C", 60,0},;
     {"AVG_C10_60","C", 60,0},;
     {"AVG_C11_60","C", 60,0},;
     {"AVG_C12_60","C", 60,0},;
     {"AVG_C06_30","C", 30,0},;
     {"AVG_C13_60","C", 60,0},;
     {"AVG_C14_60","C", 60,0},;
     {"AVG_C01100","C",100,0},;
     {"AVG_C02100","C",100,0},;
     {"AVG_D01_08","D",  8,0},;
     {"AVG_D02_08","D",  8,0},;
     {"AVG_D03_08","D",  8,0},;
     {"AVG_D04_08","D",  8,0},;
     {"AVG_D05_08","D",  8,0},;
     {"AVG_D06_08","D",  8,0},;
     {"AVG_D07_08","D",  8,0},;
     {"AVG_D08_08","D",  8,0},;
     {"AVG_D09_08","D",  8,0},;
     {"AVG_D10_08","D",  8,0},;
     {"AVG_M01_06","C",  6,0},;
     {"AVG_M02_06","C",  6,0},;
     {"AVG_M03_06","C",  6,0},;
     {"AVG_C03100","C",100,0},;
     {"AVG_C04100","C",100,0},;
     {"AVG_N01_04","N",  4,0},;
     {"AVG_N02_15","N", 15,2},;
     {"AVG_N03_15","N", 15,2},;
     {"AVG_N04_15","N", 15,2},;
     {"AVG_N05_15","N", 15,2},;
     {"AVG_C11_20","C", 20,0},;
     {"AVG_C12_20","C", 20,0},;
     {"AVG_C13_20","C", 20,0},;
     {"AVG_C14_20","C", 20,0},;
     {"AVG_C15_20","C", 20,0},;
     {"AVG_C16_20","C", 20,0},;
     {"AVG_C17_20","C", 20,0},;
     {"AVG_C18_20","C", 20,0},;
     {"AVG_C15_60","C", 60,0},;
     {"AVG_C16_60","C", 60,0},;
     {"AVG_C17_60","C", 60,0},;
     {"AVG_C18_60","C", 60,0},;
     {"AVG_C19_60","C", 60,0},;
     {"AVG_C20_60","C", 60,0},;
     {"AVG_C07_30","C", 30,0},;
     {"AVG_C21_60","C", 60,0},;
     {"AVG_C22_60","C", 60,0},;
     {"AVG_C23_60","C", 60,0},;
     {"AVG_C19_20","C", 20,0},;
     {"AVG_C20_20","C", 20,0},;
     {"AVG_C21_20","C", 20,0},;
     {"AVG_C24_60","C", 60,0},;
     {"AVG_C08_30","C", 30,0},;
     {"AVG_C09_30","C", 30,0},;
     {"AVG_C25_60","C", 60,0},;
     {"AVG_C26_60","C", 60,0},;
     {"AVG_C27_60","C", 60,0},;
     {"AVG_C28_60","C", 60,0},;
     {"AVG_C29_60","C", 60,0},;
     {"AVG_C30_60","C", 60,0},;
     {"AVG_C31_60","C", 60,0},;
     {"AVG_C32_60","C", 60,0},;
     {"AVG_LOGO  ","C", 20,0}}    
     
     // Complementa campos do Header
     aAdd(aHeader_Str,{"AVG_C01150","C",150,0})
     aAdd(aHeader_Str,{"AVG_C02150","C",150,0})
     aAdd(aHeader_Str,{"AVG_C03150","C",150,0})
     aAdd(aHeader_Str,{"AVG_C04150","C",150,0})
     aAdd(aHeader_Str,{"AVG_C05150","C",150,0})
     aAdd(aHeader_Str,{"AVG_C06150","C",150,0})     

   aDetail_Str := {;
     {"AVG_FILIAL","C",  FwSizeFilial(), 0},; //DFS - 28/09/12 - Tratamento para pegar o tamanho da filial da tabela SY0
     {"AVG_SEQREL","C",  8, 0},;
     {"AVG_CHAVE" ,"C", 20, 0},;
     {"AVG_CONT"  ,"C",  6, 0},;
     {"AVG_LINHA" ,"C",  6, 0},;
     {"AVG_C01_10","C", 10, 0},;
     {"AVG_C02_10","C", 10, 0},;
     {"AVG_C03_10","C", 10, 0},;
     {"AVG_C04_10","C", 10, 0},;
     {"AVG_C05_10","C", 10, 0},;
     {"AVG_C01_20","C", 20, 0},;
     {"AVG_C02_20","C", 20, 0},;
     {"AVG_C03_20","C", 20, 0},;
     {"AVG_C04_20","C", 20, 0},;
     {"AVG_C05_20","C", 20, 0},;
     {"AVG_C06_20","C", 20, 0},;
     {"AVG_C07_20","C", 20, 0},;
     {"AVG_C08_20","C", 20, 0},;
     {"AVG_C09_20","C", 20, 0},;
     {"AVG_C10_20","C", 20, 0},;
     {"AVG_C01_60","C", 60, 0},;
     {"AVG_C02_60","C", 60, 0},;
     {"AVG_C03_60","C", 60, 0},;
     {"AVG_C04_60","C", 60, 0},;
     {"AVG_C05_60","C", 60, 0},;
     {"AVG_C01100","C",100, 0},;
     {"AVG_C02100","C",100, 0},;
     {"AVG_C03100","C",100, 0},;
     {"AVG_N01_04","N",  4, 0},;
     {"AVG_N01_15","N", 15, 3},;
     {"AVG_N02_15","N", 15, 3},;
     {"AVG_N03_15","N", 15, 3},;
     {"AVG_N04_15","N", 15, 3},;
     {"AVG_N05_15","N", 15, 3},;
     {"AVG_N06_15","N", 15, 3},;
     {"AVG_N07_15","N", 15, 3},;
     {"AVG_N08_15","N", 15, 3},;
     {"AVG_N09_15","N", 15, 3},;
     {"AVG_N10_15","N", 15, 3},;
     {"AVG_N11_15","N", 15, 3},;
     {"AVG_N06_17","N", 17, 7},;
     {"AVG_N07_17","N", 17, 7},;
     {"AVG_N06_18","N", 17, 7},;
     {"AVG_C01120","C",120, 0},;
     {"AVG_C01150","C",150, 0} }

//ER - 25/05/2007
If EasyEntryPoint("AVCRW")
   ExecBlock("AVCRW",.F.,.F.,{"CRIA_ARQ_CRW"})
EndIf

Begin Sequence
   
   For j:=1 To 2
      For i:=1 To Len(aDir)         
         IF aDir[i][3] <> dDataBase .Or. ;
            cFileHeader $ aDir[i][1] .Or.;
            cFileDetail $ aDir[i][1]
            /* by CAF 27/10/2004 - Correção de problema identificado na 3M, qdo um usuário ia imprimir
                                   e outro entrava no sistema o arquivo era deletado antes de copiar para
                                   o C:
             .Or.;
            (Val(Substr(aDir[i][4],1,2))*60+Val(Substr(aDir[i][4],4,2)))+2 ;
               < (Val(Substr(Time(),1,2))*60+Val(Substr(Time(),4,2)))
            */
         
            // Apaga os arqs. com diferenca de no minimo 2 minutos.
            FErase(DirRpt01()+"\"+aDir[i][1])
         Endif
      Next i
      aDir := Directory(DirRpt01()+"\"+"SC*" + IndexExt())
   Next j

   For i:=1 To Len(aArqs) 
      IF "HEADER" $ Upper(aArqs[i][2])
         aStruct := aHeader_Str
      Else
         aStruct := aDetail_Str
      Endif
      
      // ** - JBJ  19/12/01 17:37 - Apaga os arquivos (Inicio) ...
      //If Len(aInds) > 1      
      //   IF File(cDirRpt+"\"+aInds[i][1])
      //      FErase(cDirRpt+"\"+aInds[i][1])
      //   Endif    
      //EndIf
      // ** (Fim)
     
      //RMD - 16/11/17 - Se for temporário no banco faz a criação dos arquivos "_P" com E_Criatrab e atualiza as variáveis de controle com os nomes dos arquivos e índice
	  If ("_P" $ aArqs[i][2])
         aArqs[i][1] := E_CRIATRAB(,aStruct,aArqs[i][2])
         aInds[i][1] := aArqs[i][1] + TEOrdBagExt()
         If ("HEADER_P" $ aArqs[i][2])
            cFileHeader := aArqs[i][1]
         ElseIf ("DETAIL_P" $ aArqs[i][2])
            cFileDetail := aArqs[i][1]
         EndIf
      Else
         If !MSFILE(aARQS[I,1])
            MSCREATE(aArqs[i,1],aStruct, "TOPCONN")
            dbUseArea( .T., "TOPCONN", aARQS[I,1], aARQS[I,1], .T., .F. )
            Index on &( aINDS[i,2] ) To (aINDS[i,1])
            (aARQS[I,1])->(dbCloseArea())
         Else//Caso a tabela ja exista, verifica a existencia do Indice
            If !MSFILE(aARQS[I,1],aINDS[I,1],"TOPCONN")
              dbUseArea( .T., "TOPCONN", aARQS[I,1], aARQS[I,1], .T., .F. )
              Index on &( aINDS[I,2] ) To (aINDS[I,1])
              (aARQS[I,1])->(dbCloseArea())
            EndIf
         EndIf
      EndIf
   Next
   
End Sequence                
                            
Return lRet                 

/*
Funcao      : AvgCrw32(cRpt,cTit,cSeqRel,lShedule,cTo,lEmail,cTitEmail,cTxtEmail)
Parametros  : cRpt := Nome do rpt com a extensao
              cTit := Titulo do Relatorio
              cSeqRel := Sequencia                  
//            lShedule: Se for Shedulado (L)
//            cTo     : E-Mail destino   (C)
//            lEMail  : Se for p/ enviar e-mail (L) 
              cTitEmail : Titulo do E-mail            // JPP - 15/02/2005 - 14:45 - Criação dos novos parametros cTitEmail= titulo do E-mail, cTxtEmail = Corpo do E-mail.
              cTxtEmail : Corpo do E-mail

Retorno     : .T./.F.
Objetivos   : Chamada do AvgGrw32
Autor       : Cristiano A. Ferreira
Data/Hora   : 14/09/99 14:41
Revisao     :
Obs.        :
*/
Function AvgCrw32(cRpt,cTitulo,cSeqRel1,lShedule,cTo,lEmail,cTitEmail,cTxtEmail)

Local lRet := .T.
//Local cCmd, cRpt1, cTit := cTitulo
Local cRpt1, cTit := cTitulo
Local cFileTemp, i, cArq, aArqs, cArqDest
Local aTmpDbfCristal := {}, aDir := {} //AOM - 25/07/11

// ** Variavel utilizada na verificacao da existencia ou nao do arquivo AVGCRW32.EXE no diretorio BIN do sistema...
//Local nFound:=0                                                                                                    
Local lDetail := .f., lHeader := .f., cFiles := ""
Local cBody:=STR0010 //"Segue em anexo "
Local cTituloEm, cCorpoEm   // JPP - 15/02/2005 - 14:45 - Criação dos novos parametros cTituloEm = titulo do E-mail, cCorpo = Corpo do E-mail.

Local cPathRpt := "" //FSM - 21/10/2011
Local cPathExe := ""
Private lNewCrystal := .F. //FSM - 21/10/2011

cPathExe := GetClientDir()

Private lErrorNewCrystal := (!EasyIsExeInstalled('Protheus Crystal Integration') .AND. !EasyIsExeInstalled('Protheus Crystal Integration without BDE')) .Or.  ( !EasyIsExeInstalled("sgcrys32.exe",,2) .And. !EasyIsExeInstalled("sgcrys32.exe",,2,cPathExe) .And. !File("\Comex\Crystal\sgcrys32.exe")  )

Begin Sequence 

   If GetRemoteType() == 5      //NCF - 05/10/2017 - SmarClient Html
      MsgAlert(STR0044,STR0002) //"O Documento/Carta/Relatório não pode ser emitido/impresso via acesso do usuário por SmartClient HTML."
      lRet := .F.
      Break
   EndIf

   If Select("Header_p") = 0
      AbreEEC()
   EndIf
   
   IF ! Empty(cSeqRel1)
      cSeqRel := cSeqRel1
   Endif

   cRpt1 := AllTrim(cRpt)
      
   IF At(".RPT",Upper(cRpt1)) == 0
      cRpt1 += ".RPT"
   Endif
   cRpt:=cRpt1
   // ** JBJ - 15/10/01 16:25 (Inicio)
   If !File(DirRpt01()+"\"+cRpt1)
      Help("", 1, "AVG0000174",,cRpt1 +STR0007 + " !",1,22) //MsgStop("Arquivo de relatório "+cRpt1+" não encontrado !","Atenção") //" não encontrado"
      Break
   Endif
   // ** (Fim)
   
   // ** FSM - 21/10/2011 - Tratamento para o novo Crystal Report 2008
   If (cPathRpt := DirRpt01()+"\"+cRpt1) # ""  
      lNewCrystal := EasyRptNewVersion(cPathRpt) 
   EndIf
   
   If lNewCrystal
      If lErrorNewCrystal
          MsgInfo(STR0036 + ENTER +; //#STR0036->"Este ambiente não esta preparado para executar o Crystal Report 2008."
                  STR0037 + ; //#STR0037->"Favor veririficar se o programa 'Protheus_Crystal_Integration.msi' esta instalado corretamente ou "
                  STR0038 + Replic(ENTER,2) +; //#STR0038->" se o executavel 'sgccrys32.exe' se encontra na pasta do SmartClient."
                  STR0039 , STR0002) //#STR0039->"Caso contrario entre em contato com o seu suporte." ##STR0002->"Aviso"
          break          
       EndIf           
   EndIf

   // ** (FIM)

   cTit := AllTrim(IF(Empty(cTit),STR0003,StrTran(AllTrim(cTit)," ",","))) //"Sem,Titulo"
   // cSeqRel := if(Empty(cSeqRel),"X",cSeqRel)
   
   IF Empty(cSeqRel)
      cSeqRel := GetSXENum("SY0","Y0_SEQREL")
      ConfirmSX8()
   Endif
   
   IF lAmbRmt // Indica se o ambiente eh remoto
      // Copia o RPT para o Cliente ...
      AvChkArqSrv(cRpt1,If(lNewCrystal, cSeqRel,))
      
      IF !lIsDir(DirCrw()+"\"+cSeqRel)
         MakeDir(DirCrw()+"\"+cSeqRel)
      Endif
      
      // Copia os DBF/CDX do Rpt
      aArqs := AvCrwFiles(cRpt1,lShedule,If(lNewCrystal, cSeqRel,)) // By JPP - 28/12/2009
      
      For i:=1 To Len(aArqs)
         cArq     := aArqs[i]
         cArqDest := nil 
         AADD(aTmpDbfCristal,cArq) //AOM - 25/07/11
         
         IF "HEADER_P" $ cArq
            cArqDest:= "HEADER_P" + ".dbf"
			//RMD - 16/11/17 - Utiliza a referência do temporário no banco (nome da tabela no banco sem os pontos)
            If TETempBanco()
               cArq := StrTran(TeTempName("HEADER_P"), ".", "")
            Else
               //cArq    := (cFileHeader := AvTrabName("HEADER_P")) + ".dbf" //DFS - 24/08/12 - Tratamento para que quando alterar algum campo, seja alterado na impressão do relatório
               //RMD - 16/11/17 - Considera que o arquivo foi criado com E_CRIATRAB
               cArq    := (cFileHeader := AvTrabName("HEADER_P")) + GetDbExtension()
            EndIf
            lHeader := .t.
            HEADER_P->(dbCloseArea())
            
            IF i == 1
               cFiles += " -c="+DirCrw()+"\"+cSeqRel+"\"+cArqDest
            Elseif i == 2
               cFiles += " -d="+DirCrw()+"\"+cSeqRel+"\"+cArqDest
            Endif
         Elseif "DETAIL_P" $ cArq
            cArqDest:= "DETAIL_P" + ".dbf"
			//RMD - 16/11/17 - Utiliza a referência do temporário no banco (nome da tabela no banco sem os pontos)
            If TETempBanco()
               cArq := StrTran(TeTempName("DETAIL_P"), ".", "")
            Else
               //cArq    := (cFileDetail := AllTrim(AvTrabName("DETAIL_P")))+ ".dbf" //DFS - 24/08/12 - Tratamento para que quando alterar algum campo, seja alterado na impressão do relatório
               //RMD - 16/11/17 - Considera que o arquivo foi criado com E_CRIATRAB
               cArq    := (cFileDetail := AllTrim(AvTrabName("DETAIL_P")))+ GetDbExtension()
            EndIf
            lDetail := .t.
            DETAIL_P->(dbCloseArea())
            
            IF i == 1
               cFiles += " -c="+DirCrw()+"\"+cSeqRel+"\"+cArqDest
            Elseif i == 2
               cFiles += " -d="+DirCrw()+"\"+cSeqRel+"\"+cArqDest
            Endif
         Endif

         //IF File(DirRpt01()+"\"+cArq)
         IF File(cArq) .Or. TETempBanco()//RMD - 16/11/17 - Se for temporário no banco não tem arquivo físico, deve assumir que já está criado. Caso contrário, considera que foi criado com E_CRIATRAB na pasta System
            // Copia o DBF/CDX/RPT
            AvCpyArqSrv(cArq,cArqDest,cSeqRel)
         ENDIF
      Next i
      
      cRpt1 := DirCrw()+"\"+If(lNewCrystal, cSeqRel+"\","")+cRpt1
      
      cFile := CriaTrab(,.F.)+".CFG"   // GFP - 14/10/2014
      cFileTemp := DirCrw()+"\"+cFile  // GFP - 14/10/2014      
      MemoWrite(cFileTemp,"-t="+cTit+" -r="+cRpt1+cFiles+" -s="+cSeqRel)
//    cCmd := "AVGCRW32.EXE "+cFileTemp

   Else
      cRpt1 := DirCrw()+"\"+If(lNewCrystal, cSeqRel+"\","")+cRpt1
      
      IF !File(cRpt1)
          Help("", 1, "AVG0000174",,DirRpt01(), +STR0007 +" !",1,22)//MsgStop(STR0004+cRpt1+STR0005,STR0002) //"Arquivo de relatório "###" não encontrado !"###"Atenção" //" não encontrado"
         lRet := .f.
         Break
      Endif
      
//    cCmd := "AVGCRW32.EXE -r="+cRpt1+" -t="+cTit+" -s="+cSeqRel
      cFileTemp := DirCrw()+"\"+CriaTrab(,.F.)+".CFG"
      MemoWrite(cFileTemp,"-r="+cRpt1+" -t="+cTit+" -s="+cSeqRel)
//    cCmd := "AVGCRW32.EXE "+cFileTemp
   Endif
   
   // ** JBJ - 16/10/01 -  Controle para a execucao do avgcrw32 ... (Inicio)
   //WinExec(cCmd)   
   
   // JPP - 15/02/2005 - 14:45 - Passagem dos novos paramentros cTitEmail e cTxtEmail para função AVEMAIL
   If Empty(cTitEmail)
      cTituloEm := cTitulo
   Else
      cTituloEm := cTitEmail
   EndIf
   If Empty(cTxtEmail)
      cCorpoEm := cBody+Capital(cTitulo)
   Else
      cCorpoEm := cTxtEmail
   EndIf
   
   lRet:=AVEMAIL(cFileTemp,;              //Diretorio e arquivo com os comandos
                 DirCrw()+"\"+cSeqRel+"\",;//Diretorio do RPT
                 cRpt,;                   //Nome do RPT
                 cTitulo,;                //Titulo do Relatorio
                 cTituloEm,;              //Titulo do E-Mail
                 cCorpoEm,;               //Corpo do E-Mail                 
                 lShedule,cTo,lEmail,aTmpDbfCristal) // Parametros para envio por e-mail
   
// nFound:=WinExec(cCmd)
   
   If !lRet//nFound = 2
      Break
   EndIf   
   // ** (Fim)
   
   IF lAmbRmt
      IF lHeader .Or. lDetail
         E_ArqCrw(.F.,.T.)
         E_ArqCrw(.T.,.T.)
      Endif
   Endif   

End Sequence

Return lRet

/*
Funcao      : AvChkArqSrv(cFile)
Parametros  : cFile
Retorno     : .T./.F.
Objetivos   : Verificar se existe uma nova versao do arquivo no Server e
              copia para o diretorio de execucao do crystal
Autor       : Cristiano A. Ferreira
Data/Hora   : 11/10/2000 11:07
Revisao     :
Obs.        :
*/
Static Function AvChkArqSrv(cFile,cSeqRel)

Local lRet := .t., lCopy := .f.
Local aInfSrv

Begin Sequence    

   IF DirCrw() == DirRpt01()
      Break
   Endif

   IF !File(DirRpt01()+"\"+cFile)
      lRet := .f.
      Break
   Endif
   
   aInfSrv := Directory(DirRpt01()+"\"+cFile)      
   
   
   IF !FILE(DirCrw()+"\"+ If(lNewCrystal, cSeqRel+"\","")+cFile) .OR. !AvExiste(DirCrw()+"\AVLOGREL.TXT",68,cFile,aInfSrv)
      lCopy:=.T.
   ENDIF   
   
   IF lCopy 
      AvCpyArqSrv(cFile,,If(lNewCrystal, cSeqRel,),aInfSrv,DirRpt01()+"\")
   Endif
   
End Sequence

Return lRet

/*
Funcao      : AvCpyArqSrv(cFile,cFileDest,cSeqRel)
Parametros  : cFile,cFileDest,cSeqRel
Retorno     : .T./.F.
Objetivos   : Copia arquivo do diretorio cDirRpt para o cDirCrw
Autor       : Cristiano A. Ferreira
Data/Hora   : 25/10/2000 19:30
Revisao     :
Obs.        :
*/
Function AvCpyArqSrv(cFile,cFileDest,cSeqRel,aInfSrv,cDir)

Local lRet := .t.
Local cFileAux1, cFileAux2

Local cDirDest := DirCrw()+IF(!Empty(cSeqRel),"\"+cSeqRel,"")

Default cFileDest := cFile
Default cDir := ""

Begin Sequence   
   
   IF !lIsDir(cDirDest)
     MakeDir(cDirDest)
   Endif
   
   //FSM - 05/11/2011
   If lNewCrystal .And. ((TETempBanc() .And. !File(DirRpt01()+"\"+cFile)) .Or. At(Upper(GetDbExtension()),Upper(cFile)) <> 0) //RMD - 16/11/17 - Se for temporário no banco não existe arquivo físico
      SetFilialPrint(cFile) //RMD - 16/11/17 - Não cria mais temporários na basta Crystal
   EndIf
   
   // __CopyFile(cDirRpt+"\"+cFile,cDirDest+"\"+cFileDest)
   //AvCpyFile(DirRpt01()+cFile,cDirDest+"\"+cFileDest)
   AvCpyFile(cDir + cFile,cDirDest+"\"+cFileDest) //RMD - 16/11/17 - Não cria mais temporários na basta Crystal
   /* RMD - 16/11/17 - Descontinuado - Sempre cria os arquivos em DTC ou no banco
   IF At(".DBF",Upper(cFile)) <> 0
      cFileAux1 := StrTran(Upper(cFile),".DBF",".CDX")
     
      // ** BY JBJ - 05/09/01 - 16:32 (Inicio)
      cFileAux2 := StrTran(Upper(cFileDest),".DBF",".CDX")
      // ** (Fim)
      
      IF File(DirRpt01()+"\"+cFileAux1)  
         // __CopyFile(cDirRpt+"\"+cFileAux1,cDirDest+"\"+cFileAux2)
         AvCpyFile(DirRpt01()+"\"+cFileAux1,cDirDest+"\"+cFileAux2)
      Endif

      cFileAux1 := StrTran(Upper(cFile),".DBF",".FPT")
      
      // ** BY JBJ - 05/09/01 - 16:35 (Inicio)
      cFileAux2 := StrTran(Upper(cFileDest),".DBF",".FPT")
      // ** (Fim)      
      
      IF File(DirRpt01()+"\"+cFileAux1)     
         // __CopyFile(cDirRpt+"\"+cFileAux1,cDirDest+"\"+cFileAux2)
         AvCpyFile(DirRpt01()+"\"+cFileAux1,cDirDest+"\"+cFileAux2)
      Endif
   Endif
   */
   
   IF aInfSrv#NIL          
   
      IF ! FILE(DirCrw()+"\AVLOGREL.TXT")
         fHandle:=EasyCreateFile(DirCrw()+"\AVLOGREL.TXT")   
      ELSE
         fHandle := EasyOpenFile(DirCrw()+"\AVLOGREL.TXT",2)
      ENDIF
      
      cString :=aInfSrv[1][1]+IF(LEN(aInfSrv[1][1])<40,SPACE(40-LEN(aInfSrv[1][1])),"")+StrZero(aInfSrv[1][2],10)+DTOC(aInfSrv[1][3])+aInfSrv[1][4]+CHR(13)+CHR(10)
      
      IF !Avexiste(,68,cFile,aInfSrv,FHandle)
         FSEEK(fHandle,0,2)
      ELSE
         FSEEK(fHandle,-68,1)
      ENDIF   
      
      FWRITE(fHandle,cString)
      FCLOSE(fHandle)            
      
   ENDIF   
   
   
End Sequence

Return lRet

/*
Funcao      : AVEject()
Parametros  : Nenhum
Retorno     : Identificador de mudanca de pagina
Objetivos   : Trocar pagina
Autor       : Cristiano A. Ferreira
Data/Hora   : 17/01/2000 17:39
Revisao     :
Obs.        :
*/
Function AVEject()

Return CRLF+CRW_NewPage+CRLF // Proxima Pagina

/*
    Funcao   : E_AVGLTT(cPARAM,cTITJANELA)
    Autor    : Heder M Oliveira
    Data     : 15/09/99 14:55
    Revisao  : 15/09/99 14:55
    Uso      : Editar arquivo para AVGLTT.RPT
    Recebe   :
    Retorna  :

*/
FUNCTION E_AVGLTT(cPARAM,cTITJANELA,cField,cP_DET, lCharDOS)
  LOCAL lRET:=.T.,nOPCAO:=0,lLOOP,aESTHEADER
  LOCAL bOk := {|| nOpcao := 1,oDLG:END()},bCancel := {|| nOPCAO:=2,oDlg:End() }
  Local nCont := 1, cTexto
  Local nCol, xAux, nLinha
  Local bFieldH,bFieldP
  
  Local oBtnOk, oBtnCancel
  Local aPos, nWidht, nHeight, nLinIni, nColIni
  
  Local bLastHandler,nTMEMO,cCHAVE
  Local aButtons :={}
  Local oPanel
  Local cParamIxb:= "" 
  //Local oDLG,oMEMO,oFONT2
  
  STATIC cFILEWRK  
  
  Private oDLG,oMEMO,oFONT2
  
  Private aCampos := {}, aHeader := {}

  Default cField := "AVG_C01120"
  DEFAULT cTITJANELA:="Trade-Easy"
  Default lCharDOS := .F.
  
  nTMEMO := 60*1024 // (64kB EM BYTES) MAXIMO DO CAMPO MEMO = 64K

  If Type("ParamIxb") == "A" .And. Len(ParamIxb) == 1
     cParamIxb:= ParamIxb[1]
  EndIf

  BEGIN SEQUENCE
  
     xAux := Right(cField,3)
     While ! IsDigit(Left(xAux,1)) .And. !Empty(xAux)
        xAux := Subst(xAux,2)
     Enddo
         
     nCol := Val(xAux)   
  
     DO CASE
        CASE UPPER(cPARAM)=="G"  //gerar work com alias AVGLTT
           aESTHEADER:=HEADER_P->(DBSTRUCT())
           AADD(aESTHEADER,{"WK_DETALHE","M",10,0})
           cFILEWRK:=E_CRIATRAB(,aESTHEADER,"AVGLTT")
        CASE (UPPER(cPARAM)=="M" .Or. UPPER(cPARAM) == "W") .And. !CAA100isAph()   //editar work e gravar arquivo impressao
           cCHAVE := AVGLTT->AVG_CHAVE
           IF UPPER(cPARAM) == "M"
              DEFINE MSDIALOG oDlg FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM TITLE cTitJanela OF oMainWnd PIXEL
                 
                 //ER - 29/08/05. Alteração para funcionar corretamente em baixas resoluções de tela.
                 @01.5,01 MSPANEL oPanel PROMPT "" SIZE DLG_LIN_FIM,DLG_COL_FIM OF oDlg//30,285 OF oDlg // 30,300
                 
                 oFont2 := TFont():New("Courier New",8,15)
                 oDlg:SetFont(oFont2)

                 nLinIni := 04
                 nColIni := 05

                 nHeight := DLG_LIN_FIM//290 ER - 29/08/05
                 nWidth  := DLG_COL_FIM//500

                 IF cP_DET = NIL
                    @ nLinIni,nColIni GET oMEMO VAR AVGLTT->WK_DETALHE MEMO HSCROLL SIZE nWidth,nHeight OF oPanel PIXEL FONT oDlg:oFont
                 ELSE
                    @ nLinIni,nColIni GET oMEMO VAR cP_DET MEMO HSCROLL SIZE nWidth,nHeight OF oPanel PIXEL FONT oDlg:oFont
                 ENDIF                

                 bLastHandler := ErrorBlock({|| .t. })
                 
                 Begin Sequence
                    oMemo:lWordWrap := .F.
                    oMemo:EnableVScroll(.T.)
                    oMemo:EnableHScroll(.T.)
                 End Sequence
                 
                 ErrorBlock(bLastHandler) 
                 
                 oDlg:lMaximized := .t. 
                 
                 If EasyEntryPoint("AVCRW")
                    ExecBlock("AVCRW",.F.,.F.,{"TELA"}) 
                 EndIf
				 
				 oPanel:Align:=CONTROL_ALIGN_ALLCLIENT //TOP,; ER - 29/08/05 //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                 oMemo:Align :=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                   
              ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,bOk,bCancel)) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
           Else 
              nOpcao:=1
           Endif
           
           /* 
           	RMD - 17/10/14
           	Na Build atual o Chr(13) está sendo removido da string pelo objeto GET após a exibição da tela.
           	Para isso, será utilizada a função EasySetMemo() para recolocar as quebras de linha
           */
           
           If cP_DET <> Nil
              cP_DET := EasySetMemo(cP_DET)
           Else
              AVGLTT->WK_DETALHE := EasySetMemo(AVGLTT->WK_DETALHE)
           EndIf
           
           DO CASE
              CASE nOPCAO==1  //botao Confirmar
                   // LCS - 31/10/2002 - 13:32
  
                   IF cP_DET # NIL
                      IF LEN(cP_DET) <= nTMEMO
                         AVGLTT->WK_DETALHE := cP_DET
                      ELSE
                         cDET    := cP_DET
                         cNEWDET := ""
                         cAUX    := ""
                         DO WHILE .T.
                            n2   := AT(ENTER,cDET)
                            cAUX := SUBSTR(cDET,1,n2+1)
                            IF LEN(cNEWDET+cAUX) > nTMEMO .OR. n2 = 0
                               AVGLTT->WK_DETALHE := cNEWDET
                               IF n2 = 0
                                  EXIT
                               ENDIF
                               AVGLTT->(DBAPPEND())
                               AVGLTT->AVG_CHAVE := cCHAVE
                               cNEWDET           := ""
                            ENDIF
                            cNEWDET := cNEWDET+cAUX
                            cDET    := SUBSTR(cDET,n2+2)
                         ENDDO
                      ENDIF
                   ENDIF
                 bFieldP := FieldWBlock(cField,Select("DETAIL_P"))
                 bFieldH := FieldWBlock(cField,Select("DETAIL_H"))
                 
                 IF ValType(bFieldP) != "B"
                    Help("", 1, "AVG0000201",,cField + STR0004 + ".dbf" + " !",1,9)//MsgStop("O Campo "+cField+" não foi encontrado no arquivo DETAIL_P" + ".dbf" + " !","Aviso") //" não foi encontrado no arquivo DETAIL_P"
                    lRet := .F.
                    Break
                 Endif
                 
                 IF ValType(bFieldH) != "B"
                    Help("", 1, "AVG0000201",,cField + STR0005 + GetDBExtension() + " !",1,9)//MsgStop("O Campo "+cField+" não foi encontrado no arquivo DETAIL_H" + GetDBExtension() + " !","Aviso") //" não foi encontrado no arquivo DETAIL_H"
                    lRet := .F.
                    Break
                 Endif
                 AVGLTT->(DBGOTOP())
                 WHILE (!AVGLTT->(EOF()) )
                   //gravar arquivo de impressao
                   HEADER_P->(RecLock("HEADER_P",.T.))
                   AvReplace("AVGLTT","HEADER_P")
                   
                   HEADER_P->AVG_CHAVE    := AVGLTT->AVG_CHAVE
                   HEADER_P->AVG_FILIAL   := XFILIAL("SY0")
                   HEADER_P->AVG_SEQREL   := cSEQREL

                   // BAK - Alteração realizada para impressao dos certificados de origem, para respeitar a impressao do historico de documentos.
                   If Empty(AVGLTT->AVG_C01_10)
                      HEADER_P->AVG_C01_10 := cParamIxb
                   EndIf
                   
                   HEADER_P->(MSUnlock())
                   
                   //gravar arquivo de historico da impressao
                   HEADER_H->(RecLock("HEADER_H",.T.))
                   AvReplace("AVGLTT","HEADER_H")
                   
                   HEADER_H->AVG_CHAVE    := AVGLTT->AVG_CHAVE
                   HEADER_H->AVG_FILIAL   := XFILIAL("SY0")
                   HEADER_H->AVG_SEQREL   := cSEQREL
                   
                   // BAK - Alteração realizada para impressao dos certificados de origem, para respeitar a impressao do historico de documentos.
                   If Empty(AVGLTT->AVG_C01_10)
                      HEADER_H->AVG_C01_10 := HEADER_P->AVG_C01_10
                   EndIf
                   
                   HEADER_H->(MSUnlock())
                      
                   //detalhe arquivo impressao e historico
                   FOR nLINHA:=1 TO MLCOUNT(AVGLTT->WK_DETALHE,nCol)
                      cTexto := MEMOLINE(AVGLTT->WK_DETALHE,nCol,nLINHA)

                      IF (CRW_NewPage $ cTexto)
                         nCont ++
                         Loop
                      Endif
                   
                      
                      DETAIL_P->(RecLock("DETAIL_P",.T.))
                      DETAIL_P->AVG_FILIAL := XFILIAL("SY0")
                      DETAIL_P->AVG_SEQREL := cSEQREL
                      DETAIL_P->AVG_CHAVE  := AVGLTT->AVG_CHAVE
                      DETAIL_P->AVG_CONT   := STRZERO(nCont,6)
                      DETAIL_P->AVG_LINHA  := STRZERO(nLINHA,6)
                      
                      //If lCharDOS
                      //   Eval(bFieldP,ANSItoOEM(cTexto))                        
                      //Else
                         Eval(bFieldP,cTexto)
                      //EndIf
                      
                      DETAIL_H->(RecLock("DETAIL_H",.T.))
                      AVREPLACE("DETAIL_P","DETAIL_H")
                      
                      
                      DETAIL_P->(MSUnlock())
                      DETAIL_H->(MSUnlock())
                   NEXT nLINHA
                   AVGLTT->(DBSKIP(1))
                 ENDDO
              CASE nOPCAO==2  //botao Cancelar
                 lRET:=.F.
              OTHERWISE
                 lRET:=.F.  //ALT+F4   
           END
           AVGLTT->(E_EraseArq(cFILEWRK))
     ENDCASE
  END SEQUENCE
RETURN lRET

/*
    Funcao   : E_HISTDOC(cFilial,cTitulo,dDtHist,cHorHist,cUsuario,cRPT,cSeqrel,cFASE,cPROCES)
    Autor    : Heder M Oliveira
    Data     : 18/09/99 16:55
    Revisao  : 18/09/99 16:55
    Uso      : Gravar historico de impressao de documentos
    Recebe   :
    Retorna  :
    Parâmetro: Caso a função CAA100isAph() retorne true será enviado o parâmetro cHtml
*/
FUNCTION E_HISTDOC(cFILIAL,cTITRPT,dDTHIST,cHORHIST,cUSRPT,cRPT,cSEQREL,cFASE,cPROCES,cCODRPT,cHtml)
   LOCAL lRET:=.T.,nOLDAREA:=SELECT()
   DEFAULT cFILIAL:=XFILIAL("SY0")
   DEFAULT cTITRPT:=STR0006 //"Sem Título"
   DEFAULT dDTHIST:=dDATABASE
   DEFAULT cHORHIST:=TIME()
   DEFAULT cUSRPT:=Subs(cUsuario,7,15)
   DEFAULT cFASE := "1"
   DEFAULT cPROCES := ""
   DEFAULT cCODRPT :=""
   DEFAULT cHtml := ""
   BEGIN SEQUENCE
      IF (EMPTY(cRPT) .or. EMPTY(cSEQREL)) .and. !CAA100isAph()
         Help("", 1, "AVG0000202")//MSGINFO("Não é possível gravar histórico sem ter o nome do RPT ou o SEQREL","Atenção")
         lRET:=.F.
         BREAK
      ENDIF
      //novo registro
      RECLOCK("SY0",.T.)//novo registro
      SY0->Y0_FILIAL:= cFILIAL
      SY0->Y0_DOC   := cTITRPT
      SY0->Y0_DATA  := dDTHIST
      SY0->Y0_HORA  := cHORHIST
      SY0->Y0_USUARIO:=cUSRPT
      SY0->Y0_ARQWMF :=cRPT
      SY0->Y0_CHVDTHR:=Str( CTOD("31/12/2999") - dDTHIST,6,0) + ;
                       Str( 86400 - SECONDS(),6,0)
      SY0->Y0_SEQREL :=cSEQREL
      SY0->Y0_PROCESS:= cPROCES
      SY0->Y0_FASE   := cFASE
      SY0->Y0_CODRPT := cCODRPT
      If SY0->(FieldPos("Y0_APTHTML")) # 0
          SY0->Y0_APTHTML := cHtml
      EndIf
      SY0->(MSUNLOCK())
   END SEQUENCE
   DBSELECTAREA(nOLDAREA)
   
   IF(EasyEntryPoint("AVCRW"),Execblock("AVCRW",.F.,.F.,"EDITA_SY0"),) //LRS - 08/01/2015
RETURN lRET

/*
Funcao      : CrwPreview(aCrw,cRpt,cTit,cSeqRel,lShedule,cTo,lEmail,cTitEmail,cTxtEmail)
Parametros  : aCrw := Array criado pela funcao CrwNewFile
              cRpt := Nome do rpt com a extensao
              cTit := Titulo do Relatorio
              cSeqRel := Sequencia
//            lShedule: Se for Shedulado (L)
//            cTo     : E-Mail destino   (C)
//            lEMail  : Se for p/ enviar e-mail (L)
              cTitEmail : Titulo do E-mail            // JPP - 15/02/2005 - 15:15 - Criação dos novos parametros cTitEmail= titulo do E-mail, cTxtEmail = Corpo do E-mail.
              cTxtEmail : Corpo do E-mail

Retorno     : .T./.F.
Objetivos   : Preview Crystal
Autor       : Cristiano A. Ferreira
Data/Hora   : 28/05/2000 08:37
Revisao     :
Obs.        :
*/
Function CrwPreview(aCrw,cRpt,cTitulo,cSeqRel,lShedule,cTo,lEmail,cTitEmail,cTxtEmail)

Local lRet := .f.
Local cDbfs := ""
//Local cCmd, i
Local i
Local cTit := AllTrim(cTitulo)
Local cTemp, cRpt1, aArqs 
Local cBody:=STR0010 //"Segue em anexo "

// ** Variavel utilizada na verificacao da existencia ou nao do arquivo AVGCRW32.EXE no diretorio BIN do sistema...
//Local nFound:=0
Local cTituloEm, cCorpoEm   // JPP - 15/02/2005 - 15:15 - Criação dos novos parametros cTituloEm = titulo do E-mail, cCorpo = Corpo do E-mail.


Local aTmpDbfCristal //AOM - 15/07/2011
Local cPathExe := ""

cRpt := Alltrim(cRpt)

Private aTmpDbfCristal //AOM - 15/07/2011

//Default cBody:=STR0010 //"Segue em anexo "

Private lNewCrystal := .F. //FSM - 21/10/2011

cPathExe := GetClientDir()

Private lErrorNewCrystal := (!EasyIsExeInstalled('Protheus Crystal Integration') .AND. !EasyIsExeInstalled('Protheus Crystal Integration without BDE')) .Or. ( !EasyIsExeInstalled("sgcrys32.exe",,2) .And. !EasyIsExeInstalled("sgcrys32.exe",,2,cPathExe) .And. !File("\Comex\Crystal\sgcrys32.exe")) 

Begin Sequence
   CrwCloseFile(aCrw)
          
   // ** JBJ - 16/10/01 11:00 (Inicio)
   IF At(".RPT",Upper(cRpt)) == 0
      cRpt += ".RPT"
   Endif      

   If !File(DirRpt01()+"\"+cRpt)
      Help("", 1, "AVG0000174",,cRpt +STR0007 + " !",1,22) //MsgStop("Arquivo de relatório "+cRpt1+" não encontrado !","Atenção") //" não encontrado"         
      Break      
   Endif         
   // ** (Fim)   
   
   // ** FSM - 21/10/2011 - Tratamento para o novo Crystal Report 2008
   If (cPathRpt := DirRpt01()+"\"+cRpt) # ""
      lNewCrystal := EasyRptNewVersion(cPathRpt) 
   EndIf
   
   If lNewCrystal
       If lErrorNewCrystal
           MsgInfo(STR0036 + ENTER +; //#STR0036->"Este ambiente não esta preparado para executar o Crystal Report 2008."
                  STR0037 + ; //#STR0037->"Favor veririficar se o programa 'Protheus_Crystal_Integration.msi' esta instalado corretamente ou "
                  STR0038 + Replic(ENTER,2) +; //#STR0038->" se o executavel 'sgccrys32.exe' se encontra na pasta do SmartClient."
                  STR0039 , STR0002) //#STR0039->"Caso contrario entre em contato com o seu suporte." ##STR0002->"Aviso"
           Break          
       EndIf           
   EndIf
   // ** (Fim)
  
   IF lAmbRmt // Indica se o ambiente eh remoto
      // Copia o RPT para o Cliente ...
      AvChkArqSrv(cRpt,If(lNewCrystal, cSeqRel,))
      
      IF !lIsDir(DirCrw()+"\"+cSeqRel)
         MakeDir(DirCrw()+"\"+cSeqRel)
      Endif

      // Copia os arqs do Servidor para o Client
      aArqs := AvCrwFiles(cRpt,,If(lNewCrystal, cSeqRel,),aCrw) 
      aTmpDbfCristal := aClone(aArqs) //AOM - 15/07/2011  
      //MFR 26/03/2019 OSSME-2704
      aTmpDbfCristal := aEval(aTmpDbfCristal,{|x,y| aTmpDbfCristal[y] := SetExtensionDbf(x)}) 

      //aEval(aArqs,{|x,y| AvCpyArqSrv(aCrw[y][1]+".dbf",x,cSeqRel) }) //RMD - 16/11/17 - A referência do temporário no banco deve ser passado sem alterações
      //MFR 26/03/2019 OSSME-2704
      aEval(aTmpDbfCristal,{|x,y| AvCpyArqSrv(aCrw[y][1]+If(TETempBanco(),"", GetDbExtension()),x,cSeqRel) }) //RMD - 16/11/17 - Passa a referência correta
      
      // Apaga os arquivos do Servidor   
      aEval(aCrw,{|x| FErase(DirRpt01()+"\"+x[1]+/*".dbf"*/GetdbExtension()),;//RMD - 16/11/17
                      FErase(DirRpt01()+"\"+x[1]+".CDX"),;
                      FErase(DirRpt01()+"\"+x[1]+".FPT") })
     
      cRpt1 := DirCrw()+"\"+If(lNewCrystal, cSeqRel+"\","")+cRpt
      
      For i := 1 To Len(aArqs)
         IF i > 2
            Exit
         Endif      
         cDbfs += IF(i==1,"-c="," -d=")+DirCrw()+"\"+cSeqRel+"\"+aArqs[i]
      Next i
   Else
      cRpt1 := DirCrw()+"\"+If(lNewCrystal, cSeqRel+"\","")+cRpt
      
      IF !File(cRpt1)
         Help("", 1, "AVG0000174",,cRpt1 +STR0007 + " !",1,22) //MsgStop("Arquivo de relatório "+cRpt1+" não encontrado !","Atenção") //" não encontrado"
         lRet := .f.
         Break
      Endif   
      
      For i := 1 To Len(aCrw)
         IF i > 2
            Exit
         Endif      
         cDbfs += IF(i==1,"-c="," -d=")+DirCrw()+"\"+aCrw[i][1]+".dbf"
      Next i
   Endif         
   
   IF !File(cRpt1)
      Help("", 1, "AVG0000204")//MsgStop("Arquivo Rpt não encontrado !","Aviso - CrwPreview")
      Break
   Endif
   
   cRpt1 := "-r="+cRpt1
   
   IF !Empty(cTit)
      cTit := "-t="+StrTran(cTit," ",",")
   Else
      cTit := "-t="+STR0003 //"Sem,Titulo"
   Endif
   
// IF !Empty(cSeqRel)
//    cSeqRel := "-s="+cSeqRel
// Else
//    cSeqRel := ""
// Endif
   
   cTemp := AllTrim(CriaTrab(,.f.))+".CFG"
   
   MemoWrite(DirCrw()+"\"+cTemp,cTit+" "+cRpt1+" "+cDbfs+IF(!EMPTY(cSeqRel)," -s="+cSeqRel,""))
// cCmd := "AvgCrw32.exe "+cDirCrw+"\"+cTemp

   // ** JBJ - 16/10/01 - Controle para a execucao do avgcrw32 ... (Inicio)
   // WinExec(cCmd)   

  // JPP - 15/02/2005 - 15:15 - Passagem dos novos paramentros cTitEmail e cTxtEmail para função AVEMAIL
   If Empty(cTitEmail)
      cTituloEm := cTitulo
   Else
      cTituloEm := cTitEmail
   EndIf
   If Empty(cTxtEmail)
      cCorpoEm := cBody+Capital(cTitulo)
   Else
      cCorpoEm := cTxtEmail
   EndIf

   lRet:=AVEMAIL(DirCrw()+"\"+cTemp,;      //Diretorio e arquivo com os comandos
                 DirCrw()+"\"+cSeqRel+"\",;//Diretorio do RPT
                 cRpt,;                   //Nome do RPT
                 cTitulo,;                //Titulo do Relatorio
                 cTituloEm,;              //Titulo do E-Mail
                 cCorpoEm,;               //Corpo do E-Mail
                 lShedule,cTo,lEmail,aTmpDbfCristal) // Parametros para envio por e-mail

// nFound:=WinExec(cCmd)
   
   If !lRet//nFound = 2
      Break
   EndIf
   // ** (Fim)
   
   lRet := .t.   
End Sequence

Return lRet

/*
Funcao      : CrwNewFile(aFiles)
Parametros  : aFiles por Dimensao:
                 aFiles[i][1] := Nome do Dbf
                 aFiles[i][2] := Estrutura do Dbf
                 aFiles[i][3] := Alias do Dbf
                 aFiles[i][4] := Chave do Indice
Retorno     : aCrw
Objetivos   : Preview Crystal
Autor       : Cristiano A. Ferreira
Data/Hora   : 28/05/2000 08:37
Revisao     :
Obs.        :
*/
Function CrwNewFile(aFiles)

Local nSelect := Select()
Local aCrw    := {}
Local i

Begin Sequence

   If Select("Header_p") = 0
      AbreEEC()
   EndIf

   For i:=1 To Len(aFiles)
      //RMD 16/11/17 - Utiliza sempre E_CRIATRAB
      //cFile := CriaTrab(,.f.)
      //CrwFile(cFile,aFiles[i][2],aFiles[i][3],aFiles[i][4])
      If Select(aFiles[i][3]) > 0 //Necessário realizar esse teste e fechar a tabela, pois existe uma tabela no dicionario com alias CAB, e se estiver aberta, da error.log
		   (aFiles[i][3])->(dbCloseArea())
	   EndIf
      cFile := E_CRIATRAB(, aFiles[i][2], aFiles[i][3])
      IndRegua(aFiles[i][3], cFile + TEOrdBagExt(), aFiles[i][4])
      aAdd(aCrw,{cFile,aFiles[i][3],aFiles[i][1] + IF(!TeTempBanc(),GetDBExtension(),"")})
   Next i

End Sequence

Select(nSelect)

Return aCrw


/*
Funcao      : CrwCloseFile(aCrw)
Parametros  : aCrw := Array criado pela funcao CrwNewFile
Retorno     : Nenhum
Objetivos   : Preview Crystal
Autor       : Cristiano A. Ferreira
Data/Hora   : 28/05/2000 08:37
Revisao     :
Obs.        :
*/
Function CrwCloseFile(aCrw,lDel)

Local i
Default lDel := .f.

Begin Sequence
   For i:=1 To Len(aCrw)
      IF lDel
         //(aCrw[i][2])->(E_EraseArq(DirRpt01()+"\"+aCrw[i][1]))
		 //RMD - 16/11/17 - Como os temporários passaram a ser criados com E_CRIATRAB, o diretório fisico passa a ser a pasta SYSTEM
		 (aCrw[i][2])->(E_EraseArq(aCrw[i][1]))
      Else
         (aCrw[i][2])->(dbCloseArea())
      Endif
   Next i
   dbSelectArea("SX3")
End Sequence

Return NIL

/*
Funcao      : AvCrwFiles(cRpt,lShedule)
Parametros  : cRpt := Nome do Rpt       
              lShedule = Indica se a função está rodoando no modo Scheduler
Retorno     : aRet := Nome dos arq's utilizados no cRpt
Objetivos   : Lista dos arq's utilizados no RPT
Autor       : Cristiano A. Ferreira
Data/Hora   : 18/11/2000 13:53
Revisao     :
Obs.        :
*/
Static Function AvCrwFiles(cRpt,lShedule,cSeqRel,aCrw)

Local aRet := {}
Local cFileTemp, cArqs, i, cArq   

Default lShedule := .F.

Begin Sequence

   If !lNewCrystal
      // *** by CAF 09/02/2001 12:34
      MsAguarde({|| cFileTemp := AvCrwFWait(cRpt,lShedule) })
    
      // *** by CAF 09/02/2001 12:34
   
      cArqs := MemoRead(DirCrw()+"\"+cFileTemp+".TXT")
      IF(File(DirCrw()+"\"+cFileTemp+".TXT"),FErase(DirCrw()+"\"+cFileTemp+".TXT"),)
   
      For i:=1 To MlCount(cArqs)
          cArq := AllTrim(MemoLine(cArqs,,i))
          cArq := Upper(Substr(cArq,Rat("\",cArq)+1))
          aAdd(aRet,cArq)
      Next i
   
   Else
   
       IF ValType(aCrw) == "A"
          For i := 1 To Len(aCrw)
              aAdd(aRet,aCrw[i][3])
          Next i
       Else
          aRet := {"DETAIL_P","HEADER_P"}       
       EndIf
       
   EndIf
   
End Sequence

Return aRet

/*
Funcao      : AvCrwFWait()
Parametros  : cRpt := Nome do Rpt
              lShedule = Indica se a função está rodando no modo agendado.
Retorno     : cFileTemp
Objetivos   : Auxiliar a funcao AvCrwFiles
Autor       : Cristiano A. Ferreira
Data/Hora   : 09/02/2001 12:37
Revisao     :
Obs.        :
*/
Static Function AvCrwFWait(cRpt,lShedule,cSeqRel)

Local cFileTemp := CriaTrab(,.F.),;
      cMsg := STR0008, nPontos := 0 //"Abrindo Arquivo de Relatório"
      

// ** Variavel utilizada na verificacao da existencia ou nao do arquivo AVGCRW32.EXE no diretorio BIN do sistema...
Local nFound:=0  
LOCAL nMin

Default lShedule := .F.

Begin Sequence 
   If ! lShedule
      MsProcTxt(cMsg)
   Else
      ConOut(cMsg)
   EndIf
   
   IF(File(DirCrw()+"\"+cFileTemp+".TXT"),FErase(DirCrw()+"\"+cFileTemp+".TXT"),)
   IF(File(DirCrw()+"\"+cFileTemp+".OK"),FErase(DirCrw()+"\"+cFileTemp+".OK"),)

   // ** JBJ - 16/10/01 - Controle para a execucao do avgcrw32... (Inicio)   
   
   //WinExec("AVGCRW32.EXE -R="+cDirCrw+"\"+cRpt+" -L="+cDirCrw+"\"+cFileTemp+".TXT")      
   
   If !File("AVGCRW32.EXE",2)
      AvCpyFile("\Comex\Crystal\AVGCRW32.exe",GetClientDir()+"AVGCRW32.exe")
   EndIf
   
   nFound:=WinExec("AVGCRW32.EXE -R="+DirCrw()+"\"+If(lNewCrystal, cSeqRel+"\","")+cRpt+" -L="+DirCrw()+"\"+cFileTemp+".TXT")
      
   If nFound = 2 // ** A funcao WinExec retorna 2 caso o executavel nao seja encontrado ...
      If ! lShedule
         MsgInfo(STR0009,STR0002) //"O arquivo AVGCRW32.EXE não foi encontrado !"###"Aviso"
      Else
         ConOut(STR0009) // "O arquivo AVGCRW32.EXE não foi encontrado !"
      EndIf
      Break
   EndIf         
   
   // ** (Fim)
   
   nMin:= EasyGParam("MV_AVG0071",,5) //FMB - 14/09/04  
   nTimeOut := Seconds()+60*nMin 

   While !File(DirCrw()+"\"+cFileTemp+".OK")
      If !lShedule
         MsProcTxt(cMsg+" "+Replic(".",++nPontos))
      Else 
         ConOut(cMsg+" "+Replic(".",++nPontos))
      EndIf
      IF(nPontos>9,nPontos:=0,)
      
      IF nTimeOut < Seconds()
         If ! lShedule
            Help("", 1, "AVG0000205")//MsgStop("Versão do AvgCrw32.exe inferior a 10/10/2000, favor atualizar !","Aviso")
         Else
            ConOut("Versão do AvgCrw32.exe inferior a 10/10/2000, favor atualizar !")
         EndIf                                                                       
               
         Break
      Endif
      
      AvDelay(3)
   Enddo
      
   IF(File(DirCrw()+"\"+cFileTemp+".OK"),FErase(DirCrw()+"\"+cFileTemp+".OK"),)
End Sequence

Return cFileTemp

/*
Funcao      : AvCpyFile(cOrigem,cDestino)
Parametros  : cOrigem  := Arquivo Origem
              cDestino := Arquivo Destino
              lBack    - Indica se serão exibidas mensagens em caso de erro
              lMove    - Indica se o arquivo de origem será excluido no final da execução (mover ao invés de copiar)
Retorno     : .T./.F.
Objetivos   : Copia arquivo
Autor       : Cristiano A. Ferreira
Data/Hora   : 20/11/2000 14:18
Revisao     : RMD - 02/08/07 - Incluída opção de excluir o arquivo de origem
Obs.        :
*/


Function AvCpyFile(cOrigem,cDestino,lBack, lMove, lGrava,lValidaAvg)

Local lRet := .f.  
Local hFile1, hFile2
Local cBuffer, nBuffer := 0, nRead, nReadTot := 0, nTotal := 0
Local cExtension := ""
Local lIsWebApp := GetRemoteType() == 5

If(lBack==NIL,lBack:=.F.,)
Default lMove := .F.
Default lGrava := .F. //LRS - 22/09/2015

Begin Sequence   

   //RMD - 16/11/17 - Não altera a referência da origem quando for temporário no banco
   If !TETempBanco() .Or. !("DBF" $ Upper(cDestino))
      cOrigem  := Upper(cOrigem)
   EndIf
   cDestino := Upper(cDestino)

   /*
   AMS - 13/12/2005. Imposta condição com a função IsSrvUnix() onde retornando .T. indica que o ambiente de execução do servidor é
                     Linux ou Unix, sendo necessário que os arquivos .DTC(Ctree) no servidor, sejam convertidos para .XML no terminail e
                     executada a ferramenta AvgXML2DBF.EXE, para converter em .DBF.
   */
   If !lGrava .And. IsSrvUnix() .or. Upper(Alltrim(EasyGetRDD(lValidaAvg))) $ "CTREE|ADS" //NCF - 20/02/2019

      If ".DBF" $ cDestino
        cExtension := '.DBF'
      EndIf

      If ".DTC" $ cDestino
        cExtension := '.DTC'
      EndIf

      Do Case

         Case cExtension != ""
                     
            If !lBack
                MsAguarde( {||AvgDBF2XML(cOrigem, StrTran(cDestino, cExtension, ".XML"))}, STR0032 )  //"Preparando Arquivo de Relatório"
            Else    
                 
                 If IsSrvUnix()           
                    AvgDBF2XML(cOrigem, StrTran(cDestino, cExtension, ".XML")) 
                 
                 //DFS - 08/09/09 - Se não for Unix, copia o arquivo .DBF
                 Else
                     __CopyFile(cOrigem, cDestino)
                 Endif       
            EndIf

         Case !(".CDX" $ cDestino) .And. !(".FPT" $ cDestino)
            __CopyFile(cOrigem, cDestino)

      End Case

   Else //NCF - 21/02/2019 - O bloco abaixo será mantido temporariamente apenas para efeitos de compatibilidade visto que em todos os os casos da novas versões do ERP, somente o bloco acima é executado.

      hFile1 := EasyOpenFile(cOrigem,FO_READ) // Abre origem somente para leitura   // GFP - 22/04/2013 - Força abertura

      IF hFile1 == -1 // Erro na abertura do arquivo
         If !lBack
            Help("", 1, "AVG0000206",,LTrim(Str(FError())),1,32)//MsgStop("Erro na abertura do arquivo nro. "+LTrim(Str(FError())),"AvCpyFile")
         EndIf
         Break
      Endif
      
      hFile2 := EasyCreateFile(cDestino,16/*0*/) // Cria destino                   // GFP - 22/04/2013 - Força abertura

      IF hFile2 == -1 // Erro na criacao do arquivo
         If !lBack
            Help("", 1, "AVG0000207",,LTrim(Str(FError())),1,31)//MsgStop("Erro na criação do arquivo nro. "+LTrim(Str(FError())),"AvCpyFile")
         EndIf
         Break
      Endif

      nTotal := FSeek(hFile1,0,2) // Tamanho do Arquivo

      // Tamanho do buffer 
      nBuffer := Min(50*1024,nTotal) // Aloca no maximo 50kb

      // Posiciona no 1o. Byte
      FSeek(hFile1,0,0)

      While nReadTot < nTotal
         cBuffer  := Space(nBuffer) // Aloca buffer
         nRead    := FRead(hFile1,@cBuffer,nBuffer) // Efetua leitura
         nReadTot += nRead

         IF (nRead <> nBuffer .And. nReadTot <> nTotal)
            If !lBack
               Help("", 1, "AVG0000208")//MsgStop("Erro na leitura do arquivo !","Aviso")
            EndIf
            Break
         Endif

         FWrite(hFile2,cBuffer,nRead)
      Enddo
   
      FClose(hFile1)
      FClose(hFile2)

   EndIf
   
   If lMove
      If FErase(cOrigem) < 0 .And. !lBack
         MsgInfo(StrTran("Foi encontrado o seguinte erro ao excluir o arquivo ###." + ENTER + cValToChar(FError()), "###", cOrigem)) //LGS-09/06/2016
         Break
      EndIf
   EndIf

   lRet := .t.

End Sequence

Return lRet

/*
    Funcao   : AVTIPODOC()
    Autor    : Jeferson Barros Jr.
    Data     : 11/06/01 15:00
    Revisao  : 
    Uso      : Auxilio a funcao EICY0100 para validacao do tipo de arquivo
    Recebe   :
    Retorna  : .T. se for um arquivo .RPT, caso contrário retorna .F. 
*/                 
Function AVTIPODOC()

Local lRet:=.T., cTipoDoc:=CriaVar("Y0_ARQWMF")

Begin Sequence
   
   cTipoDoc := SY0->Y0_ARQWMF  // Nome do arquivo.
   
   If Upper(Right(AllTrim(cTipoDoc),3)) <> "RPT" 
      Help("", 1, "AVG0000209")//MsgStop("Essa impressão não pode ser visualizada pelo modo de exportação.","Aviso")
      lRet:=.F.
      Break
   Else
      AvRptView()
   EndIf
   
End Sequence
Return lRet


/*
    Funcao   : AVRPTVIEW()
    Autor    : Heder M Oliveira    
    Data     : 26/10/99 15:04
    Revisao  : 26/10/99 15:04
    Uso      : IMPRESSAO DE IMAGEM DE RPT
    Recebe   :
    Retorna  : .T.

*/
FUNCTION AVRPTVIEW()
   LOCAL lRET:=.T.,nOLDAREA:=SELECT(),cFILSY0:=XFILIAL("SY0")
   BEGIN SEQUENCE
      // Alterado por Heder M Oliveira - 5/26/2000
      // copiar do _h para o _p
      // cabecalho
         
      // ** JBJ - 07/06/01 - 15:00 (Inicio)                                              
          
      // BAK - Validação para caso a busca da impressao do documento nao for encontrado
      IF (lRet := HEADER_H->(DBSEEK(cFILSY0+SY0->Y0_SEQREL)))
         
         WHILE (!HEADER_H->(EOF()).AND.;
            HEADER_H->AVG_FILIAL+HEADER_H->AVG_SEQREL==cFILSY0+SY0->Y0_SEQREL)
            HEADER_P->(RecLock("HEADER_P",.T.))
            AVREPLACE("HEADER_H","HEADER_P")
            HEADER_P->(MSUNLOCK())
            HEADER_H->(DBSKIP())
         END
      ENDIF               
      
      //DETALHE   
      IF DETAIL_H->(DBSEEK(XFILIAL("SY0")+SY0->Y0_SEQREL))
         WHILE (!DETAIL_H->(EOF()).AND.;
            DETAIL_H->AVG_FILIAL+DETAIL_H->AVG_SEQREL==cFILSY0+SY0->Y0_SEQREL)
            DETAIL_P->(RecLock("DETAIL_P",.T.))
            AVREPLACE("DETAIL_H","DETAIL_P")
            DETAIL_P->(MSUNLOCK())
            DETAIL_H->(DBSKIP())
         END
      ENDIF
      // ** (Fim)
       
      If lRet
         //forcar atualizacao
         HEADER_P->(DBCOMMIT())
         DETAIL_P->(DBCOMMIT())
  
         AvgCrw32(SY0->Y0_ARQWMF,SY0->Y0_DOC,SY0->Y0_SEQREL)           
      EndIf            

   END SEQUENCE
   DBSELECTAREA(nOLDAREA)
   
   If !lRet
      MsgInfo("Não foram encontrados dados para impressão do documento","Atenção")
   EndIf
RETURN lRET

/*
    Funcao   : AVEXISTE()
    Autor    : Cleverson / Sidney
    Data     : 03/01/00 09:57   
    Uso      : Verifica existencia do RPT
    Recebe   : o Arquivo,Tamanho de bytes a serem lidos,RPT,Tamanho do RPT no Server
    Retorna  : .T.

*/

*--------------------------------------------*
FUNCTION AVEXISTE(cArq,nLen,cRPT,aInfSrv,nHandle)
*--------------------------------------------*
LOCAL cLinha:=space(nLen),lRetorno:=.f.,nHandF
LOCAL nTamanho,cData,cHora

IF nHandle==NIL 
   nHandF:=EasyOpenFile(AllTrim(cArq))
ELSE
   nHandF:=nHandle
ENDIF

nTamanho:=aInfSrv[1][2]   
cData:=Dtoc(aInfSrv[1][3])
cHora:=aInfSrv[1][4]

IF nHandF>0
   
   DO WHILE Len(cLinha)==nLen
      
      FREAD(nHandF,@cLinha,nlen)
     
      IF cRpt$cLinha .AND. IF(nHandle==NIL,nTamanho==VAL(SUBSTR(cLinha,41,10)),.T.).AND.;
                            IF(nHandle==NIL,cData==(SUBSTR(cLinha,51,8)),.T.).AND.;
                            IF(nHandle==NIL,cHora==(SUBSTR(cLinha,59,8)),.T.)
         lRetorno:=.T.
         Exit
      Endif
      
   ENDDO 
   IF nHandle==NIL
      Fclose(nHandF)
   ENDIF   
ENDIF

RETURN lRetorno
/*
Funcao      : AvCpyLogo
Parametros  : cFileLogo => Arquivo Logo
Retorno     : .T.
Objetivos   : Copia o logo para o diretorio de execucao do crystal
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/12/2001 16:37
Revisao     :
Obs.        :
*/
*--------------------------------------------*
Function AvCpyLogo(cFileLogo)
*--------------------------------------------*
Local lRet:=.T., cFileTmp, aInfSrv

Begin Sequence               
   
   If !Empty(cFileLogo)
      
      If File(DirRpt01()+"\"+cFileLogo)
      
         cFileTmp:=Upper(cFileLogo)
      
         // ** Array com as propriedades do arquivo cFileTmp ...      
         aInfSrv := Directory(DirRpt01()+"\"+cFileTmp)
                  
         // ** Copia o arquivo para o diretorio de execucao do crystal ...
         AvCpyArqSrv(cFileTmp,cFileTmp,,aInfSrv,DirRpt01()+"\") //RMD - 16/11/17

      EndIf
     
   EndIf

End Sequence

Return lRet
*-----------------------------------------------------------------------------------------*
//Funcao....: AVEMAIL()
//Parametros: cArqTemp: Diretorio e arquivo com os comandos (C)
//            cDirRpt : Diretorio do RPT (C)
//            cArqRpt : Nome do RPT      (C)
//            cTitulo : Titulo do Relatorio (C)
//            cSubject: Titulo do E-Mail (C)
//            cBody   : Corpo do E-Mail  (C)
//            lShedule: Se for Shedulado (L)
//            cTo     : E-Mail destino   (C)
//            lEMail  : Se for p/ enviar e-mail (L)
//            aTmpDbfCristal : Nome dos arquivos dbf do crystal
//Retorno...: .T./.F.
//Objetivos.: Executa o AVCRW32.EXE para visualizar/Criar PDF ou RTF e enviar e-mail
//Autor.....: ALEX WALLAUER (AWR)
//Data/Hora.: 23, Julho de 2003
//Revisao...:
//Obs. .....:
FUNCTION AVEMAIL(cArqTemp,cDirRpt,cArqRpt,cTitulo,cSubject,cBody,lShedule,cTo,lEMail, aTmpDbfCristal)
*-----------------------------------------------------------------------------------------*
LOCAL cAccount, cPassword, lAutentica, cUserAut, cPassAut,cFile
Local cErrorMsg	:= ""
LOCAL cUser,lMens:=.T.,nOp:=0,oDlg,nFound := 0
LOCAL aParam := {cArqTemp,DirRpt01(),cArqRpt,cTitulo,cSubject,cBody,lShedule,cTo,lEMail,cDirRpt}
LOCAL A, i
Local cExtension := ".DBF"
Local cTmpDbfExt := ""
Local aAnexosR	 := {}
Local cCC := ""
Local cServer     := AllTrim(GetNewPar("MV_RELSERV",""))
Local nResult, nStart, lOkDBF

//Início: CCH - 15/10/08 - Variáveis auxiliares para alteração via ponto de entrada:
Private cTitAux
Private cSubjectAux
Private cBodyAux
Private cToAux
Private lEmailAux  
Private cFrom       := EasyGParam("MV_RELFROM",,"")
Private lRelTLS     := GetMV("MV_RELTLS")
Private lRelSLS     := GetMV("MV_RELSSL")
Private cRelPor     := GetMV("MV_PORSMTP")
Private nTimeOut    := EasyGParam("MV_RELTIME",,120) //Tempo de Espera antes de abortar a Conexão //By RGS 18/02/04 - 09:45
Private oMail, oMessage, nErro
Private lSair		:= .F.
PRIVATE cAnexosExtras :=""//AWR - 16/08/2009
PRIVATE aAnexosExtras :={}//AWR - 16/08/2009
PRIVATE cCCAux
PRIVATE lExibeTelas := .T.
Private lGeraPDF    := .F.
DEFAULT cArqTemp := ""
DEFAULT cDirRpt  := ""
DEFAULT cArqRpt  := ""
DEFAULT cTitulo  := ""
DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT lShedule := .F.
DEFAULT cTo      := ""
DEFAULT lEMail   := .T. 
DEFAULT aTmpDbfCristal := {}

if at(":",cServer) > 0
   if empty(cRelPor)
      cRelPor := val( Substr( cServer , at(":",cServer)+1 , len(cServer) ) )
   endif
  cServer := Substr( cServer , 1 , at(":",cServer)-1 )
endif
 
If EasyEntryPoint("AVCRW")
   ExecBlock("AVCRW", .F., .F., {"AVEMAIL_SAIR"})
EndIf

IF lSair
	Return
Endif

BEGIN SEQUENCE

If EasyGParam("MV_AVG0051",,"DISABLE") == "DISABLE"
   lEMail:= .F.
   Break
EndIf

IF lEMail

   IF EMPTY(cServer)
      lEMail:= .F.
      BREAK
   ENDIF

   IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
      ConOut(STR0011) //"Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'"
      lEMail := .F.
      BREAK
   ENDIF   

   IF lShedule .AND. EMPTY(cTo)
      ConOut(STR0012) //"E-mail para envio, nao informado."
      lEMail := .F.
      BREAK
   ENDIF   

   PswOrder(1)
   PswSeek(__CUSERID,.T.)
   aUsuario:= PswRet()
   If !lShedule
      if empty(cFrom)
         cFrom:= Alltrim(aUsuario[1,14])
      endif
   Else
      cFrom := EasyGParam("MV_WFMAIL",, "")
   EndIf
   
   cCC  := cFrom
   cUser:= Subs(cUsuario,7,15)
   IF ! AllTrim(aUsuario[1,14]) $ cCC
      if empty(cCc)
         cCC := AllTrim(aUsuario[1,14])
      else
         cCC += ";" + AllTrim(aUsuario[1,14])
      ENDIF
   ENDIF
   cTo  := cTo + SPACE(200)
   
   IF EMPTY(cFrom)
      IF !lShedule
         Help("", 1, "AVG0005361",,cUser,2,30)//LRL 08/01/04 MsgInfo(STR0013+cUser) //"E-mail do remetente nao definido no cad. do usuario: "
      ELSE
         ConOut("E-mail do remetente não definido no parâmetro: " + "MV_WFMAIL") //"E-mail do remetente nao definido no cad. do usuario: "
      ENDIF
      lEMail := .F.
      BREAK
   ENDIF

ENDIF

End Sequence //RMD - 05/11/14 - Para não abortar a execução do avcrw32

If EasyEntryPoint("AVCRW")  //ASK - 19/04/2007
   //WFS 30/10/08
   cTitAux := cTitulo
   cSubjectAux := cSubject
   cBodyAux := cBody
   cToAux := cTo
   cCCAux := cCC
   lEmailAux := lEmail
   lGeraPDF  := lEmail //Inicializa com o conteudo do lEMail, mas pode ser alterado no ponto de entrada para gerar o PDF, masmo que o lEmail seja alterado para .F.
   ExecBlock("AVCRW",.F.,.F.,{"EMAIL",aParam})   
   //Início: CCH - 15/10/08 - Variáveis auxiliares para alteração via ponto de entrada:
   cTitulo  := cTitAux
   cSubject := cSubjectAux
   cBody    := cBodyAux
   cTo      := cToAux  
   cCC      := cCCAux  
   lEmail   := lEmailAux 

EndIf

/*
Imposta condição com a função IsSrvUnix para converter os arquivos de .XML para .DBF com a ferramenta AvgXML2DBF.exe, quando o 
ambiente do servidor for Unix ou Linux.
*/
//If IsSrvUnix() .or. Upper(Alltrim(EasyGetRDD())) $ "CTREE|ADS" //NCF - 21/02/2019 - Em todos os os casos daa novas versões do ERP, a conversão de XML para DBF sempre é executada para todos os RDD's.

   For A := 1 To Len(aTmpDbfCristal)
      nStart := Seconds()
      While !File(StrTran(Upper(DirCrw()+"\"+cSeqRel+"\"+aTmpDbfCristal[A]+".XML"), ".DBF", "")) .And. (Seconds() - nStart) < 10
         Sleep(1000)
      EndDo
      If !File(StrTran(Upper(DirCrw()+"\"+cSeqRel+"\"+aTmpDbfCristal[A]+".XML"), ".DBF", ""))
         MsgInfo(StrTran(STR0053, "XXX", StrTran(Upper(DirCrw()+"\"+cSeqRel+"\"+aTmpDbfCristal[A]+".XML"), ".DBF", "")), STR0002)//"O arquivo XXX não foi encontrado. A impressão será cancelada."###" Aviso"
         Return
      EndIf
   Next
   
   If !File(GetClientDir() + "AVGXML2DBF.exe")
      MsgInfo(STR0041 , STR0002) //#STR0041 -> "Para que seja feita a impressão do Relatório é necessario a instalação do aplicativo AVGXML2DBF.EXE"
      Return
   EndIf

   nResult := WaitRun("AvgXML2DBF.exe "+DirCrw()+"\"+cSeqRel+"\")
   If nResult <> 0
      MsgInfo(STR0054 + Alltrim(Str(nResult)), STR0002) //"Erro na execução do AVGXML2DBF.EXE: "####"Aviso"
      Return
   EndIf
   //AOM - 15/07/2011 - Verifica se foi gerado os arquivos dbf do relatorio crystal no temp. 
   For A := 1 To Len(aTmpDbfCristal)

      aTmpDbfCristal[A] := Upper(aTmpDbfCristal[A])

      If ".DBF" $ aTmpDbfCristal[A]
        cExtension := '.DBF'
      EndIf

      If ".DTC" $ aTmpDbfCristal[A]
        cExtension := '.DTC'
      EndIf

      nStart := Seconds()
      While !(lOkDBF := File(DirCrw()+"\"+cSeqRel+"\"+aTmpDbfCristal[A]+If(!(cExtension $ aTmpDbfCristal[A]), cExtension, ""))) .And. (Seconds() - nStart) < 15
         Sleep(1000)
      EndDo

      If !lOkDBF
         MsgInfo(StrTran(STR0055, "XXX", DirCrw()+"\"+cSeqRel+"\"+aTmpDbfCristal[A]+If(!(cExtension $ aTmpDbfCristal[A]), cExtension, "")) , STR0002) //"Falha na execução. O arquivo 'XXX' não foi encontrado."##STR0041 -> "Para que seja feita a impressão do Relatório é necessario a instalação do aplicativo AVGXML2DBF.EXE"
         Return
      EndIf

      aTmpDbfCristal[A] := StrTran(aTmpDbfCristal[A], cExtension, "")
      FErase(DirCrw()+"\"+cSeqRel+"\"+aTmpDbfCristal[A]+".xml")

   Next A
//EndIf


// GFP - 14/10/2014 - Ajuste para que o sistema exiba primeiro o preview e depois gere o PDF
   cComandos := MEMOREAD(cArqTemp)
IF lExibeTelas // Caso o usuário decida pular o preview do arquivo
   If lNewCrystal 
      nFound := WinExec(CriaBat(cSeqRel,cArqRpt,1))
   Else

      aDir := Directory(DirCrw()+"\"+cSeqRel+"\*.*","D")
      IF (nPos := ASCAN(aDir,{|x |x[1] == "."})) # 0
         ADEL(aDir,nPos)
         ASIZE(aDir,LEN(aDir)-1)
      ENDIF
      IF (nPos := ASCAN(aDir,{|x |x[1] == ".."})) # 0
         ADEL(aDir,nPos)
         ASIZE(aDir,LEN(aDir)-1)
      ENDIF
      IF Len(aDir) # 0
         IF !lIsDir(DirCrw()+"\"+cSeqRel+"_BKP")
            MakeDir(DirCrw()+"\"+cSeqRel+"_BKP")
         Endif
         For i := 1 To Len(aDir)
            __CopyFile(DirCrw()+"\"+cSeqRel+"\"+aDir[i][1],DirCrw()+"\"+cSeqRel+"_BKP\"+aDir[i][1])
         Next i
         IF Empty(cFile)
            cFile := SubSTR(cArqTemp,Rat("\",cArqTemp)+1) //LRS - 13/01/2015 - Adiciona o Arquivo no cFile quando vem vazio.
         EndIF 
         __CopyFile(cArqTemp,DirCrw()+"\"+cSeqRel+"_BKP\"+cFile)
      ENDIF

      If !File("AVGCRW32.EXE",2)
         AvCpyFile("\Comex\Crystal\AVGCRW32.exe",GetClientDir()+"AVGCRW32.exe")
      EndIf
      
      nFound := WinExec("AVGCRW32.EXE "+cArqTemp)
      If !File(DirCrw()+"\"+cFile) .AND. File(DirCrw()+"\"+cSeqRel+"_BKP\"+cFile) //DEPIS VOLTAR MFR 03/01/2021
         __CopyFile(DirCrw()+"\"+cSeqRel+"_BKP\"+cFile,DirCrw()+"\"+cFile)
         FRename(DirCrw()+"\"+cSeqRel+"_BKP",DirCrw()+"\"+cSeqRel)
      EndIf
   EndIf
EndIf

If EasyEntryPoint("AVCRW")
   ExecBlock("AVCRW",.F.,.F.,{"AVEMAIL_CFROM"})
EndIf

DO WHILE lEMail .AND. !lShedule .AND. lExibeTelas

   nOp  :=0
   nCol1:=8
   nCol2:=33
   nSize:=225  
   nLinha:=15 
   lEMail:=.T.

   DEFINE MSDIALOG oDlg OF oMainWnd FROM 0,0 TO 460,544 PIXEL TITLE STR0014 //"Impressao"
        
  		@ nLinha,nCol1 Say STR0015  Size 12,8              OF oDlg PIXEL //"Titulo:"
      @ nLinha,nCol2 MSGET cTitulo  SIZE nSize,10 WHEN .F. OF oDlg PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say STR0016 Size 20,8              OF oDlg PIXEL //"Usuario:"
      @ nLinha,nCol2 MSGET cUser    SIZE nSize,10 WHEN .F. OF oDlg PIXEL
        nLinha+=20

  		//@ 000005,nCol1-4 To nLinha   ,268 LABEL STR0017  OF oDlg PIXEL //"Relatorio"
  		@ 000005, nCol1-4 To nLinha, 268 LABEL "" OF oDlg PIXEL //"Relatorio"

        nLinha+=05
        nLinAux:=nLinha
        
//    @ nLinAux, nCol1-4 To 153, 268 OF oDlg PIXEL
        nLinha+=02
      @ nLinha,nCol1 CHECKBOX lEMail PROMPT STR0018 OF oDlg SIZE 45,8 PIXEL ON CHANGE (EVAL(bChange)) //"  Enviar E-Mail  "
        nLinha+=12

  		@ nLinha,nCol1 Say   oBjtDe   VAR STR0019  Size 012,08             OF oDlg PIXEL //"De:"
  		@ nLinha,nCol2 MSGet              cFrom    Size nSize,10 WHEN .F.  OF oDlg PIXEL 
        nLinha+=15

  		@ nLinha,nCol1 Say   oBjtPara VAR STR0020  Size 016,08             OF oDlg PIXEL //"Para:"
  		@ nLinha,nCol2 MSGet oBjtTo   VAR cTo      Size nSize,10  F3 "_EM" OF oDlg PIXEL //WHEN lEMail
        nLinha+=15

  		@ nLinha,nCol1 Say   oBjtCC  VAR  STR0021  Size 016,08             OF oDlg PIXEL //"CC:"
  		@ nLinha,nCol2 MSGet oBjtCCC VAR  cCC      Size nSize,10  F3 "_EM" OF oDlg PIXEL //WHEN lEMail
        nLinha+=15

  		@ nLinha,nCol1 Say   oBjtAss VAR STR0022   Size 021,08             OF oDlg PIXEL //"Assunto:"
  		@ nLinha,nCol2 MSGet oBjtSub VAR cSubject  Size nSize,10           OF oDlg PIXEL //WHEN lEMail
        nLinha+=15

  		@ nLinha,nCol1 Say   oBjtCor VAR  STR0023  Size 016,08             OF oDlg PIXEL //"Corpo:"
  		@ nLinha,nCol2 Get  oBjtBody VAR  cBody    Size nSize,20  MEMO     OF oDlg PIXEL HSCROLL //WHEN lEMail 
        nLinha+=25

      @ nLinAux, nCol1-4 To nLinha, 268 OF oDlg PIXEL
      //AWR - 16/08/2009   =======================================*
        nLinha+=05
        nLinAux:=nLinha
        nLinha+=10
  		@ nLinha,nCol1 Get cAnexosExtras Size nSize-10,30  MEMO OF oDlg PIXEL WHEN .F. HSCROLL
      @ nLinha,nCol1+nSize BUTTON oButAne PROMPT "Anexar" SIZE 22,11 ACTION GetAnexo(.F.) Of oDLG PIXEL
        nLinha+=15
      @ nLinha,nCol1+nSize BUTTON oButLim PROMPT "Limpar" SIZE 22,11 ACTION GetAnexo(.T.) Of oDLG PIXEL
        nLinha+=20
      @ nLinAux, nCol1-4 To nLinha, 268 LABEL "Anexos" OF oDlg PIXEL
        nLinha+=10
      //AWR - 16/08/2009   =======================================*

    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-90 TYPE 1 ACTION (If(lEMail .AND. Empty(cTo),Help("",1,"AVG0001054"),(oDlg:End(),nOp:=1))) ENABLE OF oDlg PIXEL
    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-45 TYPE 2 ACTION (lEmail:=.F.,oDlg:End()) ENABLE OF oDlg PIXEL

    aObjs  :={oBjtDe,oBjtPara,oBjtTo,oBjtCC,oBjtCCC,oBjtAss,oBjtSub,oBjtCor,oBjtBody,oButAne,oButLim}
    bChange:={|| ASCAN(aObjs,{ |oObj| IF( lEMail,oObj:ENABLE(),oObj:DISABLE() ), oObj:Refresh() } )}
    EVAL(bChange)
  
   ACTIVATE MSDIALOG oDlg CENTERED

   IF nOp == 0
      RETURN .T.
   ENDIF

   EXIT

ENDDO

//END SEQUENCE //RMD - 05/11/14 - Para não abortar a execução do avcrw32

//cComandos := MEMOREAD(cArqTemp)
If EMPTY(cComandos)
   IF !lShedule
      MsgInfo(STR0024 +cArqTemp) //"Erro na Leitura do Arquivo: "
   ELSE
      ConOut(STR0024 +cArqTemp) //"Erro na Leitura do Arquivo: "
   ENDIF
ENDIF

IF lEMail .Or. lGeraPDF
   cArqRpt:=LEFT(cArqRpt,LEN(cArqRpt)-3)+EasyGParam("MV_AVG0051",,"PDF")// PDF ou RTF
   // *** GFP 03/08/2011 - Adicionado caminho RootPath + Crystal.
      // GFP - 12/07/2012 - Alterado caminho de gravação do arquivo RPT para o diretorio temporario.
   cComandos := cComandos+" -P="+EasyGParam("MV_AVG0051",,"PDF")+" -N="+cDirRpt+cArqRpt//GetSrvProfString("ROOTPATH","")+DirRpt01()+"\"+cArqRpt
   
   If !lIsDir(cDirRpt) //RNLP DTRADE-2844 ao Fechar o Crystal a pasta principal do temp é excluída e fica só a de Bkp
      cComandos:=StrTran(cComandos, cSeqRel+"\",cSeqRel+"_BKP\")
   EndIF   
   
   IF !MemoWrite(cArqTemp,cComandos)
      IF !lShedule
         MsgInfo(STR0025 +cArqTemp) //"Erro na Gravacao do Arquivo: "
      ELSE
         ConOut(STR0025 +cArqTemp) //"Erro na Gravacao do Arquivo: "
      ENDIF
   ENDIF

   nFound := 0
   // ** FSM - 21/10/2011 - Tratamento para o novo crystal
   If lNewCrystal 
      AvChkArqSrv(cArqRpt,If(lNewCrystal, cSeqRel,))// GFP - 14/10/2014
      nFound := WaitRun(CriaBat(cSeqRel,cArqRpt,6)) // GFP - 14/10/2014
   Else
      nFound:=WaitRun("AVGCRW32.EXE "+cArqTemp)
   EndIf

ENDIF

If nFound = 2
   IF !lShedule
      MsgInfo(STR0026 +cComandos) //"Erro na execucao do Comando:"
   ELSE
      ConOut(STR0026 +cComandos) //"Erro na execucao do Comando:"
   ENDIF
   RETURN .F.
EndIf   

If EasyEntryPoint("AVCRW")
   ExecBlock("AVCRW",.F.,.F.,{"AVEMAIL_RPT", cDirRpt, cArqRpt})
EndIf

IF lEMail
   cAttachment:=""
   If !lIsDir(cDirRpt) ////RNLP DTRADE-2844 ao Fechar o Crystal a pasta principal do temp é excluída e fica só a de Bkp
      cDirRpt := StrTran(cDirRpt, cSeqRel+"\",cSeqREl+"_BKP\")
   EndIf
      
   IF AvCpyFile(/*DirRpt01()*/cDirRpt+cArqRpt,cArqRpt,.T.,.T.)  // GFP - 12/07/2012 - Alterado caminho de cópia do arquivo RPT para o diretorio temporario.

   //cAttachment:="\SIGAADV\"+cArqRpt

     /*
     AMS - 03/02/2006. Path do arquivo a ser anexado, através do startpath.
     */
     cAttachment := AllTrim(Upper(GetSrvProfString("STARTPATH","")))
     If Right(cAttachment, 1) <> "\"
        cAttachment += "\"
     EndIf
     cAttachment := cAttachment + cArqRpt

   ELSE
      IF !lShedule
         MsgInfo(STR0027 +DirRpt01()+"\"+cArqRpt) //"Nao foi possivel encontrar/abrir o arquivo:"
      ELSE
         ConOut(STR0027 +DirRpt01()+"\"+cArqRpt) //"Nao foi possivel encontrar/abrir o arquivo:"
      ENDIF
      RETURN .T.
   ENDIF
   //AWR - 16/08/2009 ============================*
   IF !EMPTY(cAnexosExtras)
      cAnexosExtras:=""
      FOR A := 1 TO LEN(aAnexosExtras)
          cArqDest:=SubStr(aAnexosExtras[A], RAT("\",aAnexosExtras[A]) )
          IF (aAnexosExtras[A] == cArqDest) .OR. AvCpyFile(aAnexosExtras[A],cArqDest,.T.)
          	 cAnexosExtras+=cArqDest+","
          ELSE
             IF !lShedule
                MsgInfo("Nao foi possivel copiar de "+aAnexosExtras[A]+" para "+cArqDest)
             ELSE
                ConOut("Nao foi possivel copiar de "+aAnexosExtras[A]+" para "+cArqDest)
             ENDIF
          ENDIF
      NEXT
      cAttachment:=cAttachment+","+cAnexosExtras
   ENDIF
   //AWR - 16/08/2009 ============================*
   cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
   lAutentica:= EasyGParam("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
   cUserAut  := Alltrim(EasyGParam("MV_RELAUSR",,cAccount))//Usuário para Autenticação no Servidor de Email  - By RGS - 18/02/05 - 09:45
   cPassAut  := Alltrim(EasyGParam("MV_RELAPSW",,cPassword))//Senha para Autenticação no Servidor de Email - By RGS - 18/02/05 - 09:45

   cTo := AvLeGrupoEMail(cTo)
   cCC := AvLeGrupoEMail(cCC)
   
   oMail := TMailManager():New()
	if lRelSLS
	  oMail:SetUseSSL( .T. )
	endif
   if lRelTLS
	  oMail:SetUseTLS( .T. )
	endif
	oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
	oMail:SetSmtpTimeOut( nTimeOut )
	
	nErro := oMail:SmtpConnect()
	if nErro <> 0
	  cErrorMsg := oMail:GetErrorString( nErro )
	  easyhelp(STR0046+cErrorMsg,STR0045) //"Falha na Conexao com Servidor de E-Mail: " ## "Erro"
	Else
	  if lAutentica
	      nErro := oMail:SmtpAuth( cUserAut,cPassAut )
	      If nErro <> 0
	        cErrorMsg := oMail:GetErrorString( nErro )
	        easyhelp(STR0047+cErrorMsg,STR0045) //"Falha na Autenticacao do Usuario: " ## "Erro"
	        oMail:SMTPDisconnect()
	        If nErro <> 0
	          cErrorMsg := oMail:GetErrorString( nErro )
	          easyhelp(STR0048+cErrorMsg,STR0045) //"Erro na Desconexão: " ## "Erro" 
	        endif
	      endif
	  endif
	
	  if nErro == 0 
	    oMessage := TMailMessage():New()
	    oMessage:Clear()
	    oMessage:cFrom                  := cFrom
	    oMessage:cTo                    := cTo
	    oMessage:cCc                    := cCC
	    oMessage:cSubject               := cSubject
	    oMessage:cBody                  := '<HTML>' + StrTran( cBody, ENTER, '<br>' ) //THTS - 07/06/2021 - Converte em HTML para preservar as quebras de linha
	    
	    aAnexosR := StrToKarr(cAttachment, ",")
	    
	    For A := 1 TO Len(aAnexosR)	    
	    	//Adiciona um attach
	    	If oMessage:AttachFile( aAnexosR[A] ) < 0	    
	    		cErrorMsg := oMail:GetErrorString( nErro )
	    		easyhelp(STR0049+aAnexosR[A]+STR0050+cErrorMsg,STR0045) //"Falha ao Anexar Arquivo: '" ## "' no E-Mail: " ## "Erro"
	    	EndIf
	    Next	
	
	    nErro := oMessage:Send( oMail )
	    if nErro <> 0
	      cErrorMsg := oMail:GetErrorString( nErro )
	      easyhelp(STR0051+cErrorMsg,STR0045) //"Falha no Envio de E-Mail: " ## "Erro"
	    EndIf
	
	    oMail:SMTPDisconnect()
	    If nErro <> 0
	      cErrorMsg := oMail:GetErrorString( nErro )
	      easyhelp(STR0052+cErrorMsg,STR0045) //"Erro na Desconexão: " ## "Erro" 
	    endif
	
	  endif
	Endif   
   
	IF nErro == 0 
		IF !lShedule
			MsgInfo(STR0031) //"E-mail enviado com sucesso."
		ELSE
			ConOut(STR0031) //"E-mail enviado com sucesso."
		ENDIF
	ENDIF   

	FERASE(cArqRpt)
	FOR A := 1 TO LEN(aAnexosExtras)//AWR - 16/08/2009
		cArqDest:=SubStr(aAnexosExtras[A], RAT("\",aAnexosExtras[A]) )
		IF !(aAnexosExtras[A] == cArqDest)
			FERASE(cArqDest)
		ENDIF
	NEXT//AWR - 16/08/2009

ENDIF    

RETURN .T.

*----------------------------------------*
//AWR - 16/08/2009
STATIC FUNCTION GetAnexo(lLimpa)
*----------------------------------------* 
LOCAL cAnexo:=""
Local cTitle:= "Anexos p/ e-mail"
Local cMask := "Todos os Arquivos (*.*) | *.* |"
//Local nDefaultMask:= 0
Local nOptions    := GETF_LOCALHARD + GETF_NETWORKDRIVE
STATIC cLastPath  :="C:\"

IF lLimpa
   cAnexosExtras:=""
   aAnexosExtras:={}
   RETURN .T.
ENDIF

cAnexo := UPPER(cGetFile(cMask,cTitle,0,cLastPath,.T.,nOptions,.T.))

IF !EMPTY(cAnexo)
   cLastPath := SubStr(cAnexo,1,RAt("\",cAnexo))
   IF ASCAN(aAnexosExtras,cAnexo) = 0
      cAnexosExtras+=cAnexo+CHR(13)+CHR(10)
      AADD(aAnexosExtras,cAnexo)
   ELSE
      MSGSTOP("Arquivo ja anexado.")
   ENDIF
ENDIF

RETURN .T.


/* Nopado por MCF - 11/03/2015 - Funções transferidas para o AVGERAL
Função EECLoad
Objetivo   : Carregar arquivos na abertura do módulo de exportação.
Autor      : Alexsander Martins dos Santos
Data e Hora: 26/03/2004 às 17:23.
Observação : A função EECLoad é chamada automáticamente pelo Protheus na abertura do modulo EEC.
*/
/*
Function EECLoad()

ABREEEC()

Return Nil               
*/

/*
Função EFFLoad
Objetivo   : Carregar arquivos na abertura do módulo de financiamento.
Autor      : Alexsander Martins dos Santos
Data e Hora: 26/03/2004 às 17:23.
Observação : A função EFFLoad é chamada automáticamente pelo Protheus na abertura do modulo EFF.
*/
/*
Function EFFLoad()

ABREEEC()

Return Nil
*/

/*
Função AvgDBF2XML
Objetivo   : Converter um arquivo de base de dados (DBF/DTC) para XML.
Parametros : cArqOrig = Caminho + Nome do arquivo de origem.
             cArqDest = Caminho + Nome do arquivo de destino.
Retorno    : Nil
Autor      : Alexsander Martins dos Santos
Data e Hora: 13/12/2005 às 15:00.
XML Schema : 

<DataRoot>
   <Estrutura>
      <Campo>
         <Nome></Nome>
         <Tipo></Tipo>
         <Tamanho></Tamanho>
         <Decimal></Decimal>
      </Campo>
   </Estrutura>
   <Indice>
      <Chave></Chave>
   </Indice>
   <Dados>
      <Registro>
         <#Nome do campo#></#Nome do campo#>
      </Registro>
   </Dados>
</DataRoot>
*/

Function AvgDBF2XML(cArqOrig, cArqDest, cArqAlias)

Local cXML
Local aStruct
Local nPos 
Local nHandle
Local cDRVOpen
Local cIndex, i // by CAF 18/11/2006 02:35
Local bErrorBlock
Default cArqAlias := ""
Begin Sequence

   If !TeTempBanco() .And. !File(cArqOrig)//RMD - 16/11/17
      If File(StrTran(cArqOrig, ".DBF", ".DTC"))
         cArqOrig := StrTran(cArqOrig, ".DBF", ".DTC")
      Else
         Break
      EndIf
   EndIf
   
   //RMD - 16/11/17 - A função TETempReopen irá reabrir a tabela com o novo Alias a partir da referência do arquivo
   TETempReopen(cArqOrig,cArqAlias, "Origem")
   If Select("Origem") = 0
      Break
   EndIf

   // by CAF 18/11/2006 02:35 If File(StrTran(cArqOrig, ".DBF", ".CDX"))   
   // by CAF 18/11/2006 02:35    Origem->(dbSetIndex(StrTran(cArqOrig, ".DBF", ".CDX")))
   // by CAF 18/11/2006 02:35 Endif
   If !TETempBanco()//RMD - 16/11/17
      //RMD - 16/11/17 - Considera a criação com E_CRIATRAB
      If !Empty(Origem->(IndexKey())) .And. File(StrTran(Upper(cArqOrig), Upper(GetDbExtension()), Upper(TEordBagExt())) )
         Origem->(DbSetIndex(cArqOrig + TEordBagExt() ))
      EndIf
   Else
      //If !Empty(Origem->(IndexKey())) //Quando o temporário estiver no banco o índice sempre terá o mesmo nome da referência do arquivo
      //RMD - 28/06/19 - O tratamento de verificar o "IndexKey" não funciona pois o alias foi fechado. Não temos como garantir que o índice existe, e se rodar o DbSetIndex para um índice inválido ocorre error.log
         bErrorBlock := ErrorBlock({|| .t. })
         Origem->(DbSetIndex(cArqOrig))
         ErrorBlock(bErrorBlock) 
      //EndIf
   EndIf

   // PLB 08/08/07 - Criação do arquivo de destino.
   nHandle := EasyCreateFile(cArqDest)

   cXML := '<?xml version="1.0" encoding="ISO-8859-1"?>' + ENTER
   cXML += "<DataRoot>" + ENTER

   /*
   Definição do nó de Estrutura.
   */
   cXML += "<Estrutura>" + ENTER

   aStruct := Origem->(dbStruct())

   For nPos := 1 To Len(aStruct)
      cXML += "<Campo>" + ENTER
      cXML += "<Nome>"    +aStruct[nPos][1]+             "</Nome>" + ENTER
      cXML += "<Tipo>"    +aStruct[nPos][2]+             "</Tipo>" + ENTER
      cXML += "<Tamanho>" +LTrim(Str(aStruct[nPos][3]))+ "</Tamanho>" + ENTER
      cXML += "<Decimal>" +LTrim(Str(aStruct[nPos][4]))+ "</Decimal>" + ENTER
      cXML += "</Campo>" + ENTER
   Next

   cXML += "</Estrutura>" + ENTER
   /*
   Fim da definição do nó de Estrutura.
   */

   /*
   Definição do nó de Indice.
   */
   cXML += "<Indice>" + ENTER
   IF !Empty(Origem->(IndexKey()))  //JWJ 14/11/2006: Se não tem indice, não manda essas tags
      cXML += "<Chave>" +StrTran(Origem->(IndexKey()), "+", "</Chave>"+ENTER+"<Chave>")+ "</Chave>" + ENTER
   ENDIF
   cXML += "</Indice>" + ENTER
   /*
   Fim da definição do nó de Indice.
   */


   /*
   Definição do nó de Dados.
   */
   cXML += "<Dados>" + ENTER

   Origem->(dbGoTop())

   While Origem->(!Eof())

      cXML += "<Registro>" + ENTER

      For nPos := 1 To Len(aStruct)
         //ER - 05/10/2007 - Para campos do tipo caractere, os espaços serão considerados.
         If Left(aStruct[nPos][1],5) == "AVG_C"
            cXML += "<"+aStruct[nPos][1]+" xml:space="+CHR(34)+"preserve"+CHR(34)+">" +AvgXMLEncoding(Origem->&(aStruct[nPos][1]))+ "</"+aStruct[nPos][1]+">" + ENTER
         Else
            cXML += "<"+aStruct[nPos][1]+">"+AvgXMLEncoding(Origem->&(aStruct[nPos][1]))+ "</"+aStruct[nPos][1]+">" + ENTER                  
         EndIf
         // ** PLB 08/08/07 - Controle para armazenamento em String
         If Len(cXML) > ( MAXIMO_STR - MARGEM_STR )
            fWrite(nHandle, cXML)
            cXML := ""
         EndIf
         // **
      Next

      cXML += "</Registro>" + ENTER

      Origem->(dbSkip())

   End

   cXML += "</Dados>" + ENTER
   /*
   Fim da definição do nó de Dados.
   */

   cXML += "</DataRoot>"

   Origem->(dbCloseArea())
   //RMD - 16/11/17 - Exclui o temporário no banco
   If TETempBanco()
      TETempBuffer(cArqOrig,,, .T.) 
   EndIf

   /*
   Gravação do arquivo de destino.
   */
   // Criação do arquivo no início da rotina
   fWrite(nHandle, cXML)
   fClose(nHandle)

End Sequence

Return(Nil)

/*
Função AvgXML2DBF
Objetivo   : Converter um arquivo XML para um de base de dados (DBF/DTC).
Parametros : cArqOrig = Caminho + Nome do arquivo XML de origem.
             cArqDest = Caminho + Nome do arquivo DBF/DTC de destino. (sem a extensão)
Retorno    : Nil
Autor      : Johann Wilfried Josefy
Data       : 14/11/2006
XMLSchema:
*** Mesmo utilizado na função AvgDBF2XML ***
*/
Function AvgXML2DBF( cArqOrig, cArqDest)
Local aStruct := {}
Local i, j
Local cDRVOpen
Local lOK := .T.
Local cInd := "", cArqTemp
Local nBuffer := 0, nReadTot := 0, nRead := 0
Local hFile1, nTotal := 0, cBuffer := ""
Local aXML := {}, nPasso //AAF - 22/08/2008

Private oXML, oStruct, oInd, oDados
Private cErro := ""

//Retira os acentos
If FindFunction("ConverteXML")
   //ER - Retira os acentos do arquivo XML.
   hFile1 := EasyOpenFile(cArqOrig,2)
    
//Verifica o Tamanho total do arquivo
nSize := FSeek(hFile1,0,2)
   
//Posiciona no Inicio do Arquivo
FSeek(hFile1,0)      

   //Define a quantidade de caracteres processados por passo.
   nPasso := 4096

   //Verifica o Tamanho total do arquivo
   //nSize := FSeek(hFile1,0,2)
   nTam := 0
   Do While !Empty( cBuffer := FREADSTR(hFile1,nPasso) )
      
      //RMD - 12/11/19 - Não remove os caracteres de acentuação do XML, somente acerta o encoding para ISO-8859-1
      //cBuffer := ConverteXML(cBuffer) //A função ConverteXML está no fonte EASYTEC.prw
      cBuffer := StrTran(cBuffer, "UTF-8", "ISO-8859-1")
         
      nTam += nPasso - Len(cBuffer)
   
      aAdd(aXML,cBuffer)
   EndDo

   //Posiciona no inicio
   /* RMD - 12/11/19 - Não grava mais o conteúdo no mesmo arquivo.
   FSeek(hFile1,0)
   */
   //RMD - 12/11/19 - Não grava mais o conteúdo no mesmo arquivo, devido à gravação assíncrona. Passa a excluir o arquivo e gravar um novo.
   FClose(hFile1)
   FErase(cArqOrig)
   hFile1 := FCreate(cArqOrig)

   For i:= 1 To Len(aXML)
      //Grava no arquivo
      Fwrite(hFile1,aXML[i],Len(aXML[i]))
   Next i
   /* RMD - 12/11/19 - Não é mais necessário pois a gravação ocorreu em um novo arquivo
   If nTam > 0
      Fwrite(hFile1,Space(nTam),nTam) //Grava espaços em branco para completar o tamanho do arquivo, caso este seja menor.
   EndIf
   */
   
   aXML := {}
   
   //Fecha arquivo
   FClose(hFile1)
EndIf

oXML := XmlParserFile(cArqOrig, "_", @cErro,"")
lOK := Empty(cErro)
IF .Not. lOK
   Return .F.
Endif

oStruct := oXML:_DATAROOT:_ESTRUTURA
oInd    := oXML:_DATAROOT:_INDICE
oDados  := oXML:_DATAROOT:_DADOS

//Valida a tag <Estrutura>
Do Case
Case Type("oStruct:_CAMPO") == "A"
   oStruct := oStruct:_CAMPO
   nTam := LEN(oStruct)
Case Type("oStruct:_CAMPO") == "O"
   oStruct := oStruct:_CAMPO
   nTam := 1
OtherWise
   Return .F.  //Erro: não ha campos na estrutura
Endcase

//Monta o array para criar a work
For i := 1 to nTam
   IF nTam == 1
      oCampo := oStruct
   Else
      oCampo := oStruct[i]
   Endif

   AADD(aStruct, {oCampo:_NOME:TEXT, oCampo:_TIPO:TEXT, VAL(oCampo:_TAMANHO:TEXT), VAL(oCampo:_DECIMAL:TEXT)} )
Next

// *** Valida a tag <Indice> e monta a expressão do indice ***

Do Case
Case Type("oInd:_CHAVE") == "A"
   oInd := oInd:_CHAVE
   nTam := LEN(oInd)
Case Type("oInd:_CHAVE") == "O"
   oInd := oInd:_CHAVE
   nTam := 1
OtherWise
   nTam := 0 //Não tem indice
Endcase

For i := 1 to nTam
   cInd := cInd + IF(!Empty(cIND),"+","") 
   xInd := IF(nTam==1, oInd:TEXT, oInd[i]:TEXT)
   nInd := aScan(aStruct, {|x| x[1]== xInd })
   
   xType := aStruct[nInd, 2]
   
   Do Case
   Case xType == "C"
      cInd := cInd + xInd
   Case xType == "N"
      cInd := cInd + "STR(" + xInd + "," + STR(aStruct[nInd,3]) + "," + STR(aStruct[nInd,4]) + ")"
   Case xType == "D"
      cInd := cInd + "DTOS(" + xInd + ")"
   Endcase   
Next

// *** Cria a Work e o indice (se houver)***

IF Type("aCampos")=="A"
   aCamposOld := AClone(aCampos)
Else
   aCamposOld := {}
Endif
     
IF Type("aHeader")=="A"
   aHeaderOld := AClone(aHeader)
Else
   aHeaderOld := {}
Endif

aCampos := {}
aHeader := {}

cArqDest := E_CRIATRAB(, aStruct, "XML")

IF !Empty(cInd)
   INDREGUA("XML",cArqDest+TEOrdBagExt(), cIND )
Endif

IF Select("XML")==0
   Return .F.
Endif        

IF !Empty(cIND)
   XML->(DBSetIndex(LEFT(cArqDest,LEN(cArqDest)-4) + TEOrdBagExt() ))
ENDIF

// *** Alimenta a Work com os dados ***

Do Case
Case Type("oDados:_REGISTRO") == "A"
   oDados := oDados:_REGISTRO
   nTam := LEN(oDados)
Case Type("oDados:_REGISTRO") == "O"
   oDados := oDados:_REGISTRO
   nTam := 1
Otherwise
   nTam := 0
End Case

For i := 1 to nTam
   IF nTam == 1
      oReg := oDados
   Else
      oReg := oDados[i]
   Endif
   
   XML->(DBAPPEND())
   
   For j := 1 To LEN(aStruct)
      xVal := AvgXMLDecoding( &("oReg:_" + XML->(FieldName(j)) + ":TEXT" ), aStruct[j,2] )
      XML->(FieldPut(j, xVal))
   Next
   
Next

aCampos := aClone(aCamposOld)
aHeader := aClone(aHeaderOld)
XML->(DBCloseArea())

Return lOK

/*
Função AvgXMLEncoding
Objetivo   : Converte dados dos tipos N(numérico), D(data) e L(lógico) em C(character).
Parametros : xValue = Dado a ser convertido.
Retorno    : cValue = xValue convertido para character.
Autor      : Alexsander Martins dos Santos
Data e Hora: 13/12/2005 às 16:53.
*/

Function AvgXMLEncoding(xValue)

Local cValue

Begin Sequence

   Do Case

      Case ValType(xValue) = "N"
         cValue := StrTran(Str(xValue), ".", ",")

      Case ValType(xValue) = "D"
         cValue := If(!Empty(xValue), StrZero(Year(xValue), 4)+"/"+StrZero(Month(xValue),2)+"/"+StrZero(Day(xValue), 2), Space(8))

      Case ValType(xValue) = "L"
         cValue := If(xValue, "T", "F")

      Otherwise
         xValue := StrTran(xValue, "&", "&amp;")
         xValue := StrTran(xValue, "<", "&lt;" )
         xValue := StrTran(xValue, ">", "&gt;" )

         cValue := xValue

   End Case

End Sequence

Return(cValue)

/*
Função AvgXMLDecoding
Objetivo   : Decodifica os tipos enviados no XML para os tipos do Protheus.
Parametros : xVal  = Dado a ser convertido.
             xType = Tipo do dado no Protheus
Retorno    : xRet  = xValue convertido para character.
Autor      : Johann Wilfried Josefy
Data       : 16/11/2006
*/

Function AvgXMLDecoding(xVal, xType)
Local xRet

Do Case
Case xType == "C" .OR. xType == "M"
   IF ValType(xVal)=="U"
      xVal := ""
   Endif
   
   xVal := StrTran(xVal, "&amp;", "&")
   xVal := StrTran(xVal, "&lt;" , "<")
   xVal := StrTran(xVal, "&gt;" , ">")
   
   xRet := xVal
   
Case xType == "N"
   IF ValType(xVal)=="U"
      xRet := 0
   Else
      xRet := VAL(xVal)
   Endif   
   
Case xType == "D" .OR. ValType(xVal) == "U"
   IF Empty(xVal)
      xRet := CTOD('  /  /  ')
   Else
      //xRet := CTOD(SubStr(xVal,9,2) + "/" + SubStr(xVal,6,2) + "/" + SubStr(xVal,3,2))
      Do Case
         CASE ValType(xVal) == "C" .And. Len(xVal) == 10 .And. At("/",xVal)  == 5  //formato "AAAA/MM/DD" 
            xRet := CTOD(SubStr(xVal,9,2) + "/" + SubStr(xVal,6,2) + "/" + SubStr(xVal,3,2))
         
         CASE ValType(xVal) == "C" .And. Len(xVal) == 10 .And. At("/",xVal)  == 3  //formato "DD/MM/AAAA" 
            xRet := CTOD(SubStr(xVal,1,2) + "/" + SubStr(xVal,4,2) + "/" + SubStr(xVal,9,2))            

         CASE ValType(xVal) == "C" .And. Len(xVal) ==  8 .And. At("/",xVal)  == 3  //formato "DD/MM/AA"
            xRet := CTOD(SubStr(xVal,1,2) + "/" + SubStr(xVal,4,2) + "/" + SubStr(xVal,7,2))

         CASE ValType(xVal) == "C" .And. Len(xVal) ==  8 .And. At("/",xVal) == 0  //formato "AAAAMMDD"     
            xRet := CTOD(SubStr(xVal,7,2) + "/" + SubStr(xVal,5,2) + "/" + SubStr(xVal,3,2))

         CASE ValType(xVal) == "C" .And. Len(xVal) ==  6 .And. At("/",xVal) == 0 //formato "AAMMDD"        
            xRet := CTOD(SubStr(xVal,5,2) + "/" + SubStr(xVal,3,2) + "/" + SubStr(xVal,1,2))       
      End Case
   ENDIF

Case xType == "L"
   IF ValType(xVal) == "U"
      xRet := .F.
   Else
      xRet := (xVal == "T")
   Endif

Endcase

Return xRet


/*
Funcao      : AvExcel()
Parametros  : cArqOrigem: nome do arquivo, sem a extensão, que será exibido pelo excel. É obrigatório quando
              a exibição for realizada via arquivo em formato dbf. 
              cAlias: nome do alias do arquivo em formato dtc que será exibido pelo excel. Quando
              não informado, será usado o alias corrente.
              lXml: indica se usará o tratamento em XML para a exibição em excel.
              cDirOritem: diretório onde o arquivo/ work foi criada. Quando não informado, assume-se \system\
              cDirDestino: diretório destino para a gravação do arquivo xls. Quando não informado, será copiado para
              o diretório temporário da máquina do usuário.
Retorno     : 
Objetivos   : Exibir uma work no excel.
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : Fev/2009
Revisao     : WFS 12/08/09 - inclusão dos parâmetros cDirOrigem e cDirDestino
Obs.        : 
*/

Function AvExcel(cArqOrigem, cAlias, lXml, cDirOrigem, cDirDestino, cNomXLS)
//RMD - 16/11/17 - Substituida pela função TR350Arquivo que já trata os temporários no banco
Return TR350Arquivo(cAlias,,,"",{},.T.)

/*
Funcao      : AvWk2Xml()
Parametros  : cNomeArq: nome do arquivo que será gerado em formato Xml. Quando não informado,
              será criado um nome localmente.
              cAlias: nome do alias da work que será convertida em Xml. Quando não informado,
              será usado o alias corrente.
              cPathDest: diretório destino para a gravação do arquivo xml. Quando não informado, será copiado para
              o diretório temporário da máquina do usuário.              
Retorno     : Nome do arquivo xml criado, com a extensão.
Objetivos   : Criar uma estrutura em XML de uma work qualquer.
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : Fev/2009
Revisao     : 
Obs.        : 
*/

Function AvWk2Xml(cNomeArq, cAlias, cPathDest)
Local cEstrutura,;
      nCont,;
      nDados,;
      oXML,;
      nXMLStatus
Default cNomeArq:= CriaTrab(Nil, .F.)
Default cAlias:= Alias()
Default cPathDest:= GetTempPath()

Begin Sequence    
   ProcRegua((cAlias)->(EasyRecCount()))
   
   cEstrutura:="<?xml version=1.0?>" 

   cEstrutura += "<Registros>"
   cEstrutura += "<Dados>"
   For nCont:= 1 To (cAlias)->(FCount())
      cEstrutura += "<" + (cAlias)->(FieldName(nCont)) + "></" + (cAlias)->(FieldName(nCont)) + ">"
   Next
   cEstrutura += "</Dados>"
   cEstrutura += "</Registros>"

   //Criação de objeto XML, definindo Dados como array
   Create oXml XMLSTRING cEstrutura SETASARRAY _Registros:_Dados

   nXMLStatus:= XMLError()
   If nXMLStatus <> XERROR_SUCCESS
      MsgStop("Erro " + Str(nXMLStatus, 3) + " na criação do XML")
      Break
   EndIf
   
   (cAlias)->(DBGoTop())
   nDados:= 1
   
   While (cAlias)->(!EOF())
      IncProc()
      //não acrescenta node apenas no primeiro loop
      If nDados > 1
         ADDNode oXML:_Registros:_Dados NODE "_Dados" On oXml
         //atribuição de dados
         For nCont:= 1 To (cAlias)->(FCount())
            bXml:= "{||oXml:_Registros:_Dados[nDados]:_" + (cAlias)->(FieldName(nCont)) +;
                   ":TEXT:= (cAlias)->(FieldGet(nCont))}"
            Eval(&bXml)
         Next
      
         (cAlias)->(DBSkip())             
      Else      
         //atribuição de dados
         For nCont:= 1 To (cAlias)->(FCount())
            bXml:= "{||oXml:_Registros:_Dados[nDados]:_" + (cAlias)->(FieldName(nCont)) +;
                   ":TEXT:= (cAlias)->(FieldName(nCont))}"
            Eval(&bXml)
         Next
      EndIf
      nDados++
   End
   
   //Salvando
   Save oXml XMLFILE (cPathDest + cNomeArq + ".xml")
End Sequence
Return (cNomeArq + ".xml")

// by CAF 14/10/2003 - Possibilidade de especificar diretório de gravação dos temp do Crystal

Function DirClient()

Local cDirClient := AllTrim(EasyGParam("MV_AVG0053",,"."))

If GetRemoteType() >= 0
   IF cDirClient == "."
      //cDirClient := GetWinDir()
      cDirClient := IF(Left(cModulo,1) == "E",GetTempPath()/*GetWinDir()*/,"C:\") //ER - 31/08/05 - Alteração de função para funcionar em Linux
   Else
      cDirClient := IF(Right(cDirClient,1)="\",cDirClient,cDirClient+"\")
    
   
      IF !lIsDir(cDirClient)
         MakeDir(cDirClient)
      Endif
   Endif
EndIf

Return cDirClient

Static Function CriaBat(cSeqRel,cRpt,nDest)
Local lRet := .T.
Local cCmd
Local fHandle
Local cBat := ""
local cClient := ""
Default nDest := 1   // GFP - 14/10/2014

Begin Sequence

   IF !lIsDir(DirCrw()+"\"+cSeqRel)
      MakeDir(DirCrw()+"\"+cSeqRel)
   Endif

   IF FILE(DirCrw()+"\"+cSeqRel+"\crystal.bat")
      FErase(DirCrw()+"\"+cSeqRel+"\crystal.bat")
   ENDIF

   fHandle:=EasyCreateFile(DirCrw()+"\"+cSeqRel+"\crystal.bat")

   //cCmd := "cd %temp%\avgcrw32\"+cSeqRel+"\"+ENTER
   cCmd := "pushd " + DirCrw()+"\"+cSeqRel+"\"+ENTER
   cCmd += "echo Easy >> crysini.ini"+ENTER

   If File(GetClientDir()+"\SGCRYS32.exe" )
      cClient := GetClientDir()
   ElseIf File("\Comex\Crystal\SGCRYS32.exe")
      AvCpyFile("\Comex\Crystal\SGCRYS32.exe",GetClientDir()+"SGCRYS32.exe")
      cClient := GetClientDir()
   Else
      cClient := "%SystemRoot%\system32" 
   EndIf
   
   cTitulo:= cRpt

   // #ifdef SPANISH
   if FwRetIdiom() == "es"
      nLang := "1"
   else
      if FwRetIdiom() == "en"
   //   #ifdef ENGLISH
         nLang := "2"
      else
         nLang := "0"
      endif
   endif
   
   /* OPCOES DISPONIVEIS
   1 - Tela
   2 - Impressora Direto
   3 - Impressora com tela de configuração
   4 - Excel
   5 - ???
   6 - PDF
   7 - TXT
   8 - DOC
   */
   nDestino := nDest  // GFP - 14/10/2014
      
   If Directory(cClient+ 'SGCRYS32.exe')[1][3] == CTOD("13/01/2010") .OR.; // GFP - 14/10/2014 - Data da versao antiga
   Directory(cClient+ 'SGCRYS32.exe')[1][2] == 821760 //Numero de bytes da versão antiga
      If nDestino > 1  // GFP - 14/10/2014
         MsgInfo(STR0042,STR0002)  //"O executável 'SGCRYS32.exe' presente em seu ambiente encontra-se desatualizado."  ### "Aviso"
      EndIf
      cCmd += '"'+ cClient+ 'SGCRYS32.exe"' +' "'+ Left(AllTrim(cRpt),Len(AllTrim(cRpt))-4)+".RPT" + '" "' + cTitulo + '" ' + '1' + ' ' + '" " ' + cEmpAnt + ' "'+SubStr(DirCrw()+"\"+cSeqRel+"\"+cTitulo,At(":\",DirCrw()+"\"+SubStr(cSeqRel,1,Len(cSeqRel)-3)+"\"+cTitulo)+1,Len(DirCrw()+"\"+cSeqRel+"\"+Left(cTitulo,Len(cTitulo)-6)))+'" ' + AllTrim(Str(nDestino)) + " " + '1' + ' " " '+alltrim(str(oMainWnd:hWnd,20,0))+' '+'0'+' '+nLang+' " " '+cFilAnt+' " " '+ '"a.txt" '+ '"b.txt"'
   Else /*If Directory(cClient+ 'SGCRYS32.exe')[1][3] >= CTOD("25/04/2014") .OR.; // GFP - 14/10/2014 - Tratamento para a versão mais nova do SGCRYS32.EXE
   Directory(cClient+ 'SGCRYS32.exe')[1][2] == 819712*/
      cCmd += '"'+ cClient+ 'SGCRYS32.exe"' +' "'+ Left(AllTrim(cRpt),Len(AllTrim(cRpt))-4)+".RPT" + '|' + cTitulo + '|' + '1' + '|' + '*|' + cEmpAnt + '|'+SubStr(DirCrw()+"\"+cSeqRel+"\"+cTitulo,At(":\",DirCrw()+"\"+SubStr(cSeqRel,1,Len(cSeqRel)-3)+"\"+cTitulo)+1,Len(DirCrw()+"\"+cSeqRel+"\"+Left(cTitulo,Len(cTitulo)-6)))+'|' + AllTrim(Str(nDestino)) + '|' + '1' + '|*|'+alltrim(str(oMainWnd:hWnd,20,0))+'|'+'0'+'|'+nLang+'|*|'+If(FWCompany()<>"",FWCompany(),"*")+'|'+If(FWUnitBusiness()<>"",FWUnitBusiness(),"*")+'|'+FWFilial()+'|*|*|*|*|'+getenvserver()+'|*|*|0|0|*|*"' //cFilAnt+' " " '+ '"a.txt" '+ '"b.txt"'
   /*Else    // GFP - 14/10/2014 - Tratamento para a versão de 05/03/2014
      If nDestino > 1
         MsgInfo(STR0042,STR0002)  //"O executável 'SGCRYS32.exe' presente em seu ambiente encontra-se desatualizado."  ### "Aviso"
      EndIf
      cCmd += '"'+ cClient+ 'SGCRYS32.exe"' +' "'+ Left(AllTrim(cRpt),Len(AllTrim(cRpt))-4)+".RPT" + '|' + cTitulo + '|' + '1' + '|' + '*|' + cEmpAnt + '|'+SubStr(DirCrw()+"\"+cSeqRel+"\"+cTitulo,At(":\",DirCrw()+"\"+SubStr(cSeqRel,1,Len(cSeqRel)-3)+"\"+cTitulo)+1,Len(DirCrw()+"\"+cSeqRel+"\"+Left(cTitulo,Len(cTitulo)-6)))+'|' + AllTrim(Str(nDestino)) + '|' + '1' + '|*|'+alltrim(str(oMainWnd:hWnd,20,0))+'|'+'0'+'|'+nLang+'|*|'+If(FWCompany()<>"",FWCompany(),"*")+'|'+If(FWUnitBusiness()<>"",FWUnitBusiness(),"*")+'|'+FWFilial()+'|*|*|*|*|'+getenvserver()+'|*|*|0|0|*"' //cFilAnt+' " " '+ '"a.txt" '+ '"b.txt"'
   */
   EndIf
   //"C:\Protheus 11.5\Bin\SmartClient\SGCRYS32.exe" "cRPT|cNome|1|*|cEmpresa|cTitulo|nDestino|nCopias|*|3000|0|nIdioma|*|cEmpresa|cUnidade|cFilial|*|*|*|*|cEnviroment|*|*|0|0|*"
   
   FWRITE(fHandle,cCmd)
   FCLOSE(fHandle)

   cBat := DirCrw()+"\"+cSeqRel+"\crystal.bat"

End Sequence

Return cBat


/* ============================================================ *
Funcao      : EasyRptNewVersion
Parametros  : cRpt - (C) - Diretório + Nome do arquivo + .rpt
Retorno     : lNovo - .T./.F.
Objetivos   : Verificar se o .Rpt informado é da nova versão do 
              Crystal Report 2008.
Autor       : Felipe S. Martinez
Data/Hora   : 20/10/2011
Revisao     : 
Data/Hora   : 
Obs.        : 
* ============================================================= */
Function EasyRptNewVersion(cRpt)
Local nHandle := 0
Local cString := ""
Local nTamArq := 1,;
      nTamIni := 0
Local lVelho  := .F.
Local lNovo   := .F.
Local cBufferLimite := EasyVarSize("C") //limite do buffer de memoria

Default cRpt     := ""

Begin Sequence

  If Empty(cRpt)
     MsgStop(STR0035,STR0002) //STR0035 -> "Para verificar a versão do .rpt é necessario informar seu título e caminho." ##STR0002 -> Aviso
     Break
  EndIf

  //abrindo arquivo binario do .rpt
  nHandle := EasyOpenFile(cRpt , FO_READ + FO_SHARED )

  //erro ao tentar abrir o .rpt
  If nHandle == -1
     MsgStop(STR0034 + AllTrim(Str(FError())) ) //STR0034 -> "Erro na abertura do Rpt: "
     Break  
  Endif
  
  //Le o tamanho do arquivo e retorna seu tamanho em bytes
  nTamArq := FSeek(nHandle, nTamIni, FS_END)
  //Tratamento para nao ocorrer estouro de buffer
  nBuffer := If(nTamArq > cBufferLimite , cBufferLimite ,nTamArq ) 
  FSeek(nHandle, 0, FS_SET)

  nPos := 0
  Do While (nTamArq-nPos) > 0 
  
     //Lê um determinado pedaço do arquivo  (ou inteiro dependendo do tamanho do arquivo)
     //nPos := FSeek(nHandle, nBuffer ,FS_RELATIVE)
     //posiciona no inicio do pedaço a ser lido
     //FSeek(nHandle, nTamIni)
     
     // Lê os bytes do arquivo
     nPos += FRead( nHandle, @cString, nBuffer )
     
     //Verificação de versão do .rpt
     If DATA_BASE $ cString 
        lVelho := .T.
        Exit
     ElseIf QESession $ cString //.And. PromptManager $ cString  
         lNovo := .T.
         Exit
     EndIf
     
     //nTamIni += nPedaco
  
  EndDo
  
  If !lNovo .And. !lVelho
     MsgStop(STR0033,STR0002) //STR0033 -> "Problemas ao identificar versão do RPT." ## STR0002-> Aviso
  EndIf
 
  // Fecha arquivo
  FClose(nHandle)

End Sequence

Return lNovo


/* ============================================================ *
Funcao      : SetFilialPrint
Parametros  : cPathDbf - Dbf a ser aberto e alterado.
Retorno     : lRet - .T./.F.
Objetivos   : Altera a filial do dbf caso estaja em branco com um valor 
              default para impressão com o novo crystal.
Autor       : Felipe S. Martinez
Data/Hora   : 05/11/2011
Revisao     : 
Data/Hora   : 
Obs.        : 
* ============================================================= */
Static Function SetFilialPrint(cPathDbf)
Local nI := 0
Local cCpoFilial := ""
Local lRet := .T.

If SELECT("WKIMPRI") > 0
   WKIMPRI->( dbclosearea() )
EndIf

//RMD - 16/11/17 - Utiliza a função TETempReopen para reabrir o arquivo com o novo Alias
TeTempReopen(cPathDbf,, "WKIMPRI")
WKIMPRI->(DbSetIndex(cPathDbf + TEordBagExt()))
WKIMPRI->(DbSetOrder(0))

Begin Sequence
   
   //Pega o nome do campo Filial do arquivo:
   For nI := 1 to WKIMPRI->( FCOUNT() )

	   If "_FILIAL" $ UPPER( WKIMPRI->(FIELDNAME(nI)) )
	      cCpoFilial := WKIMPRI->(FIELDNAME(nI))
	      Exit
	   EndIf 

   Next

   //atribui o valor default caso o filial do arquivo estiver vazio.
   WKIMPRI->( dbgotop() )
 
   Do While WKIMPRI->(!EOF())

      If Empty( WKIMPRI->&(cCpoFilial) )
         WKIMPRI->&(cCpoFilial) := "XX" 
      EndIf

      WKIMPRI->( dbskip() )
   EndDo
   
End Sequence

If SELECT("WKIMPRI") > 0
   WKIMPRI->( dbclosearea() )
EndIf



Return lRet

Function EasyVarSize(cType)
Local nSizeMax

	Do Case
		Case cType == "C"
			nSizeMax := 1048575

	End Case


Return nSizeMax  

/*
Funcao      : EasyGetRDD
Parametros  : lValidaAvg - Valida ou nao a existencia do avxml2dbf
Retorno     : cDriver
Objetivos   : Verifica se existe instalado o AVGXML2DBF.EXE para geração de Relatórios no Crystal
Autor       : Leonardo Brisola L. Ferreira
Data/Hora   : 16/08/2013
Revisao     : 
Data/Hora   : 
Obs.        : 
*/	
Function EasyGetRDD(lValidaAvg)
Local cDriver := RealRdd()
Local lIsWebApp := GetRemoteType() == 5
Static lGetRddChk := .F.
Default lValidaAvg := .T.

If "SQLITE" $ Upper(cDriver)
  cDriver := "CTREE"
EndIf
If cDriver $ "CTREE" .AND. !File("avgxml2dbf.exe", 2) .And. !lGetRddChk .And. GetRemoteType() <> -1 .And. !lIsWebApp  // GFP - 21/10/2014
	
	lGetRddChk := .T.

   If File("\Comex\Crystal\avgxml2dbf.exe")
      AvCpyFile("\Comex\Crystal\avgxml2dbf.exe",GetClientDir()+"AVGXML2DBF.exe")
   EndIf
   
   If lValidaAvg .And. !File("avgxml2dbf.exe", 2)
      MsgInfo(StrTran(STR0043, "SmartClient", "SmartClient (" + GetClientDir() + " ou " + "\Comex\Crystal\)"),STR0002)  //"Para ambientes CTREE, o executavel avgxml2dbf.exe deve existir no diretorio do SmartClient." ### "Aviso"
   EndIf
EndIf

Return cDriver

/*
	RMD - 17/10/14
	Função EasySetMemo - Para o caso dos campos MEMO que tiveram as quebras de linha removidas pelo objeto GET (problema de Build),
	faz o acerto das quebras.
	Nestes casos, o objeto remove o caracter 13 (Chr(13)) e mantém o 10 (Chr(10)). Esta função restaura o Chr(13).
*/
Function EasySetMemo(cConteudo)

	If ValType(cConteudo) == "C" .And. At(Chr(10), cConteudo) > 0 .And. At(Chr(13), cConteudo) == 0
		cConteudo := StrTran(cConteudo, Chr(10), Chr(13)+Chr(10))
	EndIf

Return cConteudo

/*
Funcao      : SetExtensionDbf(cFile)
Parametros  : cFile
Retorno     : Caracter, retorna o nome do arquivo com a extensão DBF
Objetivos   : Verifica se o arquivo não tem extensão no nome ou tem e é diferente de DBF entao
              inclui ou renomeia para DBF
Autor       : Maurício Frison
Data/Hora   : 26/03/2019 17:02
Revisao     :
Obs.        :
*/
Static Function SetExtensionDbf(cFile)
  local posicaoI := 0
  posicaoI := at(".",cFile)
  if posicaoI > 0
     cFile := substr(cFile,1,posicaoI-1)
  Endif
  cFile := cFile + ".DBF"   
Return cFile
