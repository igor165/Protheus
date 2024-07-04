#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"//AWR - 16/01/2006
#include "tbiconn.ch"      
#include "easytec.ch"        
#include "average.ch"
#define DBALIQ "ALIQ"
#DEFINE NAOTRIBUTADO "NT"
#DEFINE NAOATUALIZADO "*"

#DEFINE ASPAS CHR(34)
#DEFINE ASPAS_SIMPLES CHR(39) 
#DEFINE ENTER CHR(13)+CHR(10) //msv 13/04/2006

*------------------------------------------------------------------------------*
//Funcao   : EasyTec()
//Descricao: Recuperacao taxas de II, IPI, PIS, COFINS do Tecwin, nova versao
//           export.exe (recupera so uma NCM de vez)
//Param    : nao
//Retorna  : nao
//Autor    : CDS
//Data     : 8/03/2005
*------------------------------------------------------------------------------*
FUNCTION EasyTec(aParametros)
*------------------------------------------------------------------------------*
Local oRadio,nOpRad:=1,nRadio,nLin:=50   //CDS 1/7/05
Local cExpIni, n
Local cDirEIC:= GetPvProfString( GetEnvServer(), "RootPath", "", GetADV97() ) 

//CDS 10/02/05
Local cMaquina:=Space(5)               
Local cExNCM:=Space(3)
Local cExNBM:=Space(3)
Local cExNCMf:=Space(3)
Local cExNBMf:=Space(3)

PRIVATE lSchedule:= .F. //AWR - 19/01/2006

IF aParametros # NIL
   TecPreAmb(aParametros,@nOpRad,@cMaquina)// Para o Schedule
   lSchedule := .T.
ENDIF

Private cUsr :=AllTrim(EasyGParam("MV_ET_USER",,""))//Usuario Login EXPORT.EXE
Private cPas :=AllTrim(EasyGParam("MV_ET_PASS",,""))//Password Login Export.Exe
Private cIP  :=AllTrim(EasyGParam("MV_ET_IP"  ,,""))//IP Servidor Infoconsult (192.168.0.22)
Private cPort:=AllTrim(EasyGParam("MV_ET_PORT",,""))//IP Servidor Infoconsult (3306)
Private cUserRede:=cSenhaRede:=SPACE(20)
PRIVATE cNCMIni:=Space(AvSx3("YD_TEC",3))       //CDS 21/9/05
PRIVATE cNCMFim:=Space(AvSx3("YD_TEC",3))		//CDS 21/9/05

//AWR - 19/01/2006
PRIVATE cIdUsu:=cCliMS:=cTipoMS:=cStrAutMS:=cUserProxy:=cSenhaProxy:="" //MSV - 06/03/2006
PRIVATE lCposLog   :=SYD->(FIELDPOS("YD_GRVUSER")) # 0 .AND. SYD->(FIELDPOS("YD_GRVDATA")) # 0 .AND. SYD->(FIELDPOS("YD_GRVHORA")) # 0
PRIVATE lAmparoDes :=EasyGParam("MV_GRVAMPA",,.F.) .AND. SYD->(FIELDPOS("YD_MOT_II")) # 0 .AND. SYD->(FIELDPOS("YD_MOT_IPI")) # 0
PRIVATE lIncluiNCM :=EasyGParam("MV_INCLNCM",,.F.)
PRIVATE lGravaDes  :=EasyGParam("MV_GRVDNCM",,.F.)
//AWR - 19/01/2006


//PRIVATE lTodasIntegra :=EasyGParam("MV_TIPITEC",,.F.)  //MSV - 06/03/2006
PRIVATE lTodasIntegra := .T. // AST - 16/04/09 - Retirado o parametro devido a integração Easy Legis não ser mais utilizada

Private eMens:="", sAvisos:=""
Private cDirExport:="",cDirTecWin:="", cDirDBF:=""
Private lPermite := .F.  // GCC - 12/07/2013

// Codigos de Erro do Export.exe (LOGFILE)
Private eExport:={STR0001,; //"Exportaçao Concluída com sucesso"                //1
                  STR0002,; //"Inicialização do Export"                         //2
                  STR0003,; //"Numero de parametros incorreto"                  //3
                  STR0004,; //"diretorio para exportacao nao encontrado"        //4
                  STR0005,; //"Codigo NCM incorreto ou nao fornecido"           //5
                  STR0006,; //"Erro no acesso ao arquivo de exportação"         //6
                  STR0007,; //"Erro no acesso ao servidor"                      //7
                  STR0008,; //"Codigo NCM nao Encontrado"    					//8
                  STR0009,; //"Logon Incorreto"                                 //9
                  STR0010,; //"Logon expirado"                                  //10
                  STR0011,; //"Logon Inativo"                                   //11
                  STR0012,; //"Logon em uso"                                    //12
                  STR0013,; //"Estação não autorizada"                          //13
                  STR0014,; //"Arquivo inválido"                                //14
                  STR0015,; //"Atualização do produto requerida"                //15
                  STR0016 } //"Arquivo LOG nao encontrado"                      //16

//AST - 03/09/08 - flag para verificar se utiliza o tratamento para a integração com InterfWeb.exe da Aduaneiras
Private lInterfWeb := .F.
//CCH - 22/06/09 - flag que definirá se a opção EasyLegis aparecerá entre os programas de recuperação.
Private lEasyLegis := .F.

If !Empty(lTodasIntegra) .And. ValType(lTodasIntegra) <> "L"
  MsgInfo(STR0017) //STR0017 "Parâmetro MV_TIPTEC configurado incorretamente. Por favor verifique documentação Técnica."
  Return Nil                    
EndIf

cDirDBF := GetTempPath() + "INT_NCM"

If ! lIsDir(cDirDBF)
   n:=MakeDir(cDirDBF)   
Endif

cDirDBF+="\"

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"ANTES_TELA_INICIAL"),)   

//msv - 25/04/2006 
If !lTodasIntegra
   nOpRad := 3     
   nRadio :=1 
EndIf


//msv - 25/04/2006 

IF nOpRad # 3 .And. File("c:\tecwin\saida.txt")// Por causa do Schedule - // AWR 19/01/2006
   EXPReadNCM("c:\tecwin\saida.txt")
ENDIF

bExecuta:={|| EicGravaNCM(cExpIni,cDirEIC,cDirDBF,cDirExport,cDirTecWin,cMaquina,cNCMIni,cNCMFim,nOpRad) }

DO WHILE !lSchedule

   //msv - 25/04/2006 

   //IF EasyGParam("MV_AUTREDE",,.F.)
   //   DEFINE MSDIALOG oDlg FROM  9,10 TO 43,65 TITLE "Integraçao Tecwin" OF oMainWnd
   //Else
   //   DEFINE MSDIALOG oDlg FROM  9,10 TO 35,65 TITLE "Integraçao Tecwin" OF oMainWnd
   //EndIf   

   //DEFINE MSDIALOG oDlg FROM  9,10 TO IF(lTodasIntegra,IF(EasyGParam("MV_AUTREDE",,.F.),42,34),25),65 TITLE STR0018 OF oMainWnd //STR0018 "Integraçao Easy Legis"   
   DEFINE MSDIALOG oDlg FROM  9,10 TO 34,65 TITLE STR0018 OF oMainWnd // AST - Retirado tratamento do tamanho de tela para integração Easy Legis e autenticação Export.exe, ambos não são mais utilizados
   //msv - 25/04/2006 

   //CDS 1/7/05
   IF lTodasIntegra  //MSV - 13/06/2006 
     
      @  8, 06 TO 50,210 LABEL STR0019 OF oDlg PIXEL //STR0019 "Programa Usado para Recuperação"
      If lEasyLegis
         @ 18, 10 RADIO oRadio VAR nOpRad ITEMS STR0113,STR0021,"Easy Legis" 3D SIZE 68,10 PIXEL OF oDlg //STR0113 "Aduaneiras" STR0021 "TEC da Infoconsult" AST - 03/09/08 - Nova integração Aduaneiras (InterfWeb)
         @ 35, 90 BUTTON STR0022 SIZE 70,12 ACTION (TecParametros(nOpRad)) PIXEL OF oDlg //STR0022 "Parametros Easy Legis" 
      Else
         @ 18, 10 RADIO oRadio VAR nOpRad ITEMS STR0113,STR0021 3D SIZE 68,10 PIXEL OF oDlg //STR0113 "Aduaneiras" STR0021 "TEC da Infoconsult" AST - 03/09/08 - Nova integração Aduaneiras (InterfWeb)
      EndIf 
      @  8+nLin, 6 TO 70+nLin,210 LABEL STR0023 OF oDlg  PIXEL //STR0023 "Dados Importação"
      @ 20+nLin,10 SAY STR0024 SIZE 50,10 OF oDlg PIXEL  //STR0024 "Maquina "      //CDS
      @ 20+nLin,80 MSGET cMaquina PICT "@!" SIZE 10,8 F3 "Y5" VALID EasyValMaq(cMaquina,nOpRad) OF oDlg PIXEL //CDS

      @ 34+nLin,10  SAY STR0025 SIZE 50,10 OF oDlg PIXEL //STR0025 "Desde NCM "       //CDS
      @ 34+nLin,80  MSGET cNCMIni PICT AvSx3("YD_TEC",6) SIZE 45,8 F3 "YD1" Valid EasyVNCM(cNCMIni,cNCMFim) OF oDlg PIXEL //CDS 21/9/05
//      @ 34+nLin,130 MSGET cExNCM PICT "@!" SIZE 30,8 When .F. OF oDlg PIXEL //CDS
//      @ 34+nLin,165 MSGET cExNBM PICT "@!" SIZE 30,8 When .F. OF oDlg PIXEL //CDS

      @ 48+nLin,10  SAY STR0026 SIZE 50,10 OF oDlg PIXEL //STR0026 "Ate NCM "       //CDS
      @ 48+nLin,80  MSGET cNCMFim PICT AvSx3("YD_TEC",6) SIZE 45,8 F3 "YD1" Valid EasyVNCM(cNCMIni,cNCMFim) OF oDlg PIXEL //CDS 21/9/05
//      @ 48+nLin,130 MSGET cExNCMf PICT "@!" SIZE 30,8 When .F. OF oDlg PIXEL //CDS
//      @ 48+nLin,165 MSGET cExNBMf PICT "@!" SIZE 30,8 When .F. OF oDlg PIXEL //CDS

      //@ 75+nLin, 6  TO 125+nLin,210 LABEL "Diretorios p/ o TECWIN" OF oDlg PIXEL  --> Chamado 044346
      @ 75+nLin, 6  TO 125+nLin,210 LABEL STR0114 OF oDlg PIXEL //STR0114 Diretorio p/ Aduaneiras AST - 03/09/08 - Nova integração Aduaneiras (InterfWeb)
      @ 90+nLin,10  SAY STR0028 SIZE 70,10 OF oDlg PIXEL //STR0028 "Diretorio de Trabalho"
      @ 105+nLin,10 SAY STR0115 SIZE 70,10 OF oDlg PIXEL //STR0115 Diretorio do programa - AST - 03/09/08 -Nova integração Aduaneiras (InterfWeb)

      @ 90+nLin,80  MSGET cDirDBF     SIZE 125,8 When lPermite 	OF oDlg PIXEL  // GCC - 12/07/2013
      @ 105+nLin,80 MSGET cDirExport  SIZE 125,8 When .F. 		OF oDlg PIXEL  

      // AST - 16/04/09 - Retirado parametro para autenticação na rede, Export.exe da Aduaneiras não é mais utilizado.
      /*IF EasyGParam("MV_AUTREDE",,.F.)
         @ 130+nLin, 6 TO 180+nLin,210 LABEL STR0029 OF oDlg PIXEL //STR0029 "Dados para autenticação de Rede"
         @ 145+nLin,10 SAY STR0030 SIZE 70,10 OF oDlg PIXEL //STR0030 "Usuario "
         @ 160+nLin,10 SAY STR0031 SIZE 70,10 OF oDlg PIXEL //STR0031 "Senha "

         @ 145+nLin,80 MSGET cUserRede     SIZE 60,8  OF oDlg PIXEL WHEN nOpRad = 1
         @ 160+nLin,80 MSGET oSenhaRede VAR cSenhaRede PASSWORD  SIZE 60,8  OF oDlg PIXEL WHEN nOpRad = 1
         nLin := 232
      ELSE
         nLin := 172
      ENDIF
      */
      nLin := 177    //172
      
      IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"TELA_INICIAL"),)    

      DEFINE SBUTTON FROM nLin, 70 TYPE 1 ACTION ( IF(EVAL(bExecuta),oDlg:End(),) ) ENABLE // OK

      DEFINE SBUTTON FROM nLin,120 TYPE 2 ACTION ( oDlg:End() ) ENABLE // CANCEL

      ACTIVATE MSDIALOG oDlg CENTERED

      EXIT
   
   ELSE     
            
      @  3, 06 TO 37,210 LABEL STR0032 OF oDlg PIXEL //STR0032 "Programa Usado para Recuperação"  
      If lEasyLegis
         @ 18, 10 RADIO oRadio VAR nOpRad ITEMS STR0113,STR0021,"Easy Legis" 3D SIZE 68,10 PIXEL OF oDlg //STR0113 "Aduaneiras" STR0021 "TEC da Infoconsult" AST - 03/09/08 - Nova integração Aduaneiras (InterfWeb)
         @ 35, 90 BUTTON STR0022 SIZE 70,12 ACTION (TecParametros(nOpRad)) PIXEL OF oDlg //STR0022 "Parametros Easy Legis" 
      Else
         @ 18, 10 RADIO oRadio VAR nOpRad ITEMS STR0113,STR0021 3D SIZE 68,10 PIXEL OF oDlg //STR0113 "Aduaneiras" STR0021 "TEC da Infoconsult" AST - 03/09/08 - Nova integração Aduaneiras (InterfWeb)
      EndIf 
      @ 45, 6 TO 53+nLin,210 LABEL STR0023 OF oDlg  PIXEL
      @ 5+nlin,10 SAY STR0024 SIZE 50,10 OF oDlg PIXEL        //CDS
      @ 5+nLin,80 MSGET cMaquina PICT "@!" SIZE 10,8 F3 "Y5" VALID EasyValMaq(cMaquina,nOpRad) OF oDlg PIXEL //CDS

      @ 20+nLin,10  SAY STR0025 SIZE 37,10 OF oDlg PIXEL        //CDS
      @ 20+nLin,80  MSGET cNCMIni PICT AvSx3("YD_TEC",6) SIZE 45,8 F3 "SYD" Valid EasyVNCM(cNCMIni,cNCMFim) OF oDlg PIXEL //CDS 21/9/05
      @ 20+nLin,130 MSGET cExNCM PICT "@!" SIZE 30,8 When .F. OF oDlg PIXEL //CDS
      @ 20+nLin,165 MSGET cExNBM PICT "@!" SIZE 30,8 When .F. OF oDlg PIXEL //CDS

      @ 35+nLin,10  SAY STR0026 SIZE 37,10 OF oDlg PIXEL        //CDS
      @ 35+nLin,80  MSGET cNCMFim PICT AvSx3("YD_TEC",6) SIZE 45,8 F3 "SYD" Valid EasyVNCM(cNCMIni,cNCMFim) OF oDlg PIXEL //CDS 21/9/05
      @ 35+nLin,130 MSGET cExNCMf PICT "@!" SIZE 30,8 When .F. OF oDlg PIXEL //CDS
      @ 35+nLin,165 MSGET cExNBMf PICT "@!" SIZE 30,8 When .F. OF oDlg PIXEL //CDS      
          
      IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"TELA_INICIAL"),)    

      DEFINE SBUTTON FROM 110, 70 TYPE 1 ACTION ( IF(EVAL(bExecuta),oDlg:End(),) ) ENABLE // OK

      DEFINE SBUTTON FROM 110,120 TYPE 2 ACTION ( oDlg:End() ) ENABLE // CANCEL

      ACTIVATE MSDIALOG oDlg CENTERED

      EXIT
         
   ENDIF   
ENDDO

IF lSchedule
   IF EasyValMaq(cMaquina,nOpRad)
      EVAL(bExecuta)
   ENDIF
ENDIF

RETURN NIL


*-------------------------------------------------------------------------------------------------------------
FUNCTION EicGravaNCM(cExpIni,cDirEIC,cDirDBF,cDirExport,cDirTecWin,cMaquina,cNCMIni,cNCMFim,nOpRad)     //CDS 1/7/05
*-------------------------------------------------------------------------------------------------------------
Local bTiraBarra:={|x| If(Right(x,1)== "\",Left(x,Len(x)-1),x)}, cFileTemp
Local cPath
PRIVATE aStru, bStru
PRIVATE lRet:=.F.
PRIVATE cTime:=Time()//AWR - 19/01/2006

aStru:={ {"CODIGO"       ,"C",AvSx3("YD_TEC",3),0} ,;  //CDS 21/9/05
         {"SEQUENCIAL"   ,"C",03,0} ,;
         {"II"           ,"C",10,0} ,;
         {"IPI"          ,"C",10,0} ,;
         {"PIS"          ,"C",10,0} ,;
         {"COFINS"       ,"C",10,0} ,;
         {"EXNBM"        ,"C",03,0} ,;
         {"RECNO"        ,"N",07,0} ,;
         {"RECUP"        ,"C",01,0} ,;
         {"MAJCOF"       ,"C",10,0} } //RMD - 02/05/16 - Recebe a majoração do COFINS


bStru:={ {"CODNCM"   ,"C",AvSx3("YD_TEC",3),0} ,;       //CDS 21/09/05
         {"SEQNCM"   ,"C",03,0} ,;
         {"II"       ,"C",06,0} ,;
         {"IPI"      ,"C",06,0} ,;
         {"PISPASEP" ,"C",06,0} ,;
         {"COFINS"   ,"C",06,0} ,;
         {"ICMS"     ,"C",02,0} ,;
         {"EXNCM"    ,"C",03,0} ,;
         {"RECNO"    ,"N",07,0} ,;
         {"RECUP"    ,"C",01,0} }


cDirExport:=ALLTRIM(cDirExport)
cDirEIC   :=ALLTRIM(cDirEIC)
cDirDBF   :=ALLTRIM(cDirDBF)
cDirTecWin:=ALLTRIM(cDirTecWin)

//Tira as barras demais do Path (\\, \\\)
cDirExport:=Eval(bTiraBarra,cDirExport)
cDirDBF   :=Eval(bTiraBarra,cDirDBF)
cDirEIC   :=Eval(bTiraBarra,cDirEIC)
cDirTecWin:=Eval(bTiraBarra,cDirTecWin)

IF EMPTY(cMaquina)//AWR 13/01/2006
   TecMSGINFO(STR0033) //STR0033 "Maquina nao preenchida."
   RETURN lRet
Endif        
  
IF nOpRad # 3 
   If !lIsDir(cDirExport+If( Right(cDirExport,1) == "\", "", "\"))
      If !ExistDir(cDirExport+If( Right(cDirExport,1) == "\", "", "\")) .And. GetRemoteType() < 0 .And. ":" $ Left(cDirExport,2)
         TecMSGINFO(STR0134 + STR0135)//"O diretorio dos arquivos de importacao dos dados de n.c.m nao pode ser informado com o patch absoluto (Letra do Disco) em caso de execucao da rotina via Schedule!"
                                    //"Neste caso, e necessario que se informe um diretorio contido no ROOTHPATH do ambiente!")
      EndIf
      TecMSGINFO(STR0034 + cDirExport) //STR0034 "Diretorio nao existe: "
      RETURN lRet
   Endif
   
   If nOpRad == 1 .And. lSchedule //NCF - 11/10/2017
      cDirDBF := cDirExport+If( Right(cDirExport,1) == "\", "", "\")
   EndIf 
   
   // AST -  03/09/08 - Verifica se está utilizando InterfWeb ou Export 
   If (Right(cDirExport,1)== "\") 
      lInterfWeb := File(cDirExport+"InterfWeb.exe")
   Else
      lInterfWeb := File(cDirExport+"\InterfWeb.exe") 
   Endif   
   If lInterfWeb
      //Cria o arquivo easytec.txt, para armazenar as NCM's que serão atualizadas
      CriaArq(cDirExport)
   EndIf
EndIf
If !lIsDir(cDirDBF)
   TecMSGINFO(STR0035) //STR0035 "Diretorio do arquivo de trabalho nao Existe"
   RETURN lRet
Endif   

// Conserta Barras Path
cDirDBF   :=ALLTRIM(cDirDBF)+"\"
cDirEIC   :=ALLTRIM(cDirEIC)+"\"
cDirTecWin:=ALLTRIM(cDirTecWin)+"\"

IF !lSchedule .AND. !MsgYesNo(STR0036,STR0037) //STR0036 "Confirma o processamento ?" STR0037 "Atualizacao de Aliquotas"
    RETURN lRet
ENDIF 

If nOpRad==1
   cFileTemp := E_CriaTrab(,aStru,"Aliq") //THTS - 20/10/2017 - Temporario no Banco de Dados
else
   cFileTemp := E_CriaTrab(,bStru,"Aliq")
   IndRegua("Aliq",cFileTemp+TEOrdBagExt(),"CODNCM+EXNCM")
Endif

IF ! USED()
   TecMSGINFO(STR0038,STR0039) //STR0038 "Nao ha area disponivel para abertura do cadastro de Work" STR0039 "Informação"
   Aliq->(E_EraseArq(cFileTemp)) //THTS - 20/10/2017 - Temporario no Banco de Dados
   RETURN lRet
ENDIF

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"ANTES_LER_NCM"),)

TecProcessa({|lEnd| lRet:=EicLerNCM(cDirExport,cDirDBF,cFileTemp,@cNCMIni,@cNCMFim,nOpRad) },STR0040)   //CDS 1/7/05 STR0040 "Leitura das NCMs do SIGAEIC"

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"DEPOIS_LER_NCM"),)

If lRet
   TETempReOpen(cFileTemp,"Aliq") ////THTS - 20/10/2017 - Temporario no Banco de Dados
   //** PLB 30/08/07 - Índice
   If nOpRad==2
      SET INDEX TO (cFileTemp+TEOrdBagExt())
   EndIf
   //**
   TecProcessa( {|lEnd| lRet:=EicAtuAliq(cFileTemp,nOpRad) }, STR0041 ) //STR0041 "Atualizacao de Aliquotas no SIGAEIC"

   // Mostrar tela com mens. de erro
   Do While !lSchedule
      If !Empty(eMens)
         EICWEBGetDesc(eMens,sAvisos)
         eMens:=""
         sAvisos:=""
         If MsgYesNo(STR0042) //STR0042 "Deseja Recuperar novamente as NCM's nao recuperadas?"
            Processa( {|lEnd| lRet:=EicAtuAliq(cFileTemp,nOpRad) }, STR0041 )
         else
            Exit 
         Endif      
      else
        Exit
     Endif
   EndDo
   if !lSchedule .AND. !Empty(sAvisos)
      EICWEBGetDesc(eMens,sAvisos)
   Endif

   Aliq->(E_EraseArq(cFileTemp)) //THTS - 20/10/2017 - Temporario no Banco de Dados

Endif

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"FIN_RECUP_NCM"),)

RETURN lRet


*-----------------------------------------------------------------------------
Function EicLerNCM(cDirExport,cDirDBF,cFileTemp,cNCMIni,cNCMFim,nOpRad)
*-----------------------------------------------------------------------------
LOCAL cCod:="", cSeq, nRecno
Local cTmpNCM
Local cExNCM := ""
Local cNCM := ""
Local cII,cIPI,cPis,cCofins
cNcmIni:=AllTrim(cNcmIni)
cNcmFim:=AllTrim(cNCMFim)

If cNCMIni>cNCMFim
   cTmpNCM:=cNCMIni
   cNCMIni:=cNCMFim
   cNCMFim:=cTmpNCM
Endif

DBSELECTAREA("SYD")
DbSetOrder(1)

If Empty(cNCMIni)
   DBGOTOP()
else
   DBSeek(xFilial("SYD") + AvKey(cNCMIni,"YD_TEC"), .T.) 			//CDS 21/09/05
Endif

TecProcRegua( SYD->(EasyRecCount("SYD"))+1 )

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"ANTES_LOOP_LEITURA"),)

//AST - 03/09/08 - Caso utilize TOP, realiza a busca das NCM's que serão atualizadas através de Query
#IFDEF TOP
   //Caso a NCM final e inicial esteja vazia, seta como a primeira e a ultima NCM da tabela SYD
   If Empty(cNCMIni)
      SYD->(dbGoTop())
      cNCMini := alltrim(SYD->YD_TEC)
   EndIf            
   If Empty(cNCMFim)
      SYD->(dbGoBottom())
      cNCMFim := alltrim(SYD->YD_TEC)
   EndIf                         
   
   cQuery := "Select * from "+RetSqlName("SYD")+" SYD where YD_FILIAL = '"+xFilial("SYD")+"'"
   cQuery += " AND "+IIF(TcSrvType()<>"AS/400","SYD.D_E_L_E_T_<>'*'","SYD.@DELETED@<>'*'") 
   cQuery += " AND SYD.YD_TEC >= '"+cNCMIni+"' AND SYD.YD_TEC <= '"+cNCMFim+"' order by SYD.YD_TEC ASC"
             
   cQuery := changeQuery(cQuery)        
   
   TcQuery cQuery ALIAS "WK_NCM" NEW
   
   Do While !WK_NCM->(EOF())
      TecIncProc(STR0043 + AllTrim(WK_NCM->YD_TEC)) //STR0043 "Gravando NCM "    

      cCod   := WK_NCM->YD_TEC
      
      //TRP - 18/05/2012 - Alteração na variável cSeq para considerar o Sequencial enviado pela Aduaneiras (Sequencial = EX).
      					//As NCMs que não possuírem EX correspondem a sequência 001 enviada pela Aduaneiras.
      If EasyGParam("MV_EIC0039",,.F.)  // GFP - 13/03/2014
         cSeq   := WK_NCM->YD_EX_NCM
      Else
         cSeq   := IF(EMPTY(WK_NCM->YD_EX_NCM),STRZERO(1,AVSX3("YD_EX_NCM",3)),WK_NCM->YD_EX_NCM)
      EndIf
      //RMD - 03/01/12 - 
      //cSeq   := IF(EMPTY(WK_NCM->YD_EX_NCM),STRZERO(1, 3), StrZero(Val(WK_NCM->YD_EX_NCM) + 1, 3))
      
      nRecno := WK_NCM->R_E_C_N_O_
      cExNCM := IIF(Empty(WK_NCM->YD_EX_NCM),Space(Len(WK_NCM->YD_EX_NCM)),WK_NCM->YD_EX_NCM)
      cII    := WK_NCM->YD_PER_II  //*** SVG  - 25/08/2010 - Mantém as aliquotas caso venha caracter inválido no arquivo de integração.
      cIPI   := WK_NCM->YD_PER_IPI 
      cPIS   := WK_NCM->YD_PER_PIS 
      cCOFINS:= WK_NCM->YD_PER_COF //*** SVG  - 25/08/2010 -
      Aliq->(DBAPPEND())  
  
      If nOpRad==1 //Aduaneiras                         
         Aliq->CODIGO     :=cCod
         Aliq->SEQUENCIAL :=cSeq
         Aliq->RECNO      :=nRecno
         Aliq->II         :=NAOATUALIZADO
         Aliq->IPI        :=NAOATUALIZADO
         Aliq->PIS        :=NAOATUALIZADO
         Aliq->COFINS     :=NAOATUALIZADO
         Aliq->RECUP      :="N"
      
         //AST - 03/09/08 - Verifica se usa o sistema InterfWeb da Aduaneiras
         If lInterfWeb                                                     
            //Verifica se é a primeira NCM que está sendo adicionada
            If alltrim(cCod) == cNcmIni
               cNCM := alltrim(cCod)
            Else
               cNCM += ","+alltrim(cCod)
            Endif

            //Grava as informações serão gravadas no arquivo easytec.txt em lotes 100.
            // 8 tamanho da NCM, 100 quantidade de NCM, 99 vírgulas entre as NCM's
            If len(cNCM) >= (8*100+99)
               TxtEasyTec(cNCM)
               cNCM := ""
            endIf   
         EndIf

      Else  //Infosolution e Easy Legis
         Aliq->CODNCM:=cCod       
         Aliq->II         := AllTrim(Str(cII))    //*** SVG  - 25/08/2010 - Mantém as aliquotas caso venha caracter inválido no arquivo de integração.
         Aliq->IPI        := AllTrim(Str(cIPI))   
         Aliq->PISPASEP   := AllTrim(Str(cPIS))   
         Aliq->COFINS     := AllTrim(Str(cCOFINS))//*** SVG  - 25/08/2010 - 
         Aliq->RECUP :="N"
         Aliq->RECNO := nRecno
         //** PLB - 30/08/07
         If nOpRad == 2  // InfoSolution
            Aliq->EXNCM := cExNCM
         EndIf
         //**
      Endif

      IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_LEITURA_NCM"),)

      DBSKIP()
   EndDo  
   
   WK_NCM->(dbCloseArea())
    
#ELSE

   WHILE ! SYD->(EOF())

      TecIncProc(STR0043 + AllTrim(SYD->YD_TEC)) //STR0043 "Gravando NCM "

      IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_LEITURA_NCM"),)

      If (SYD->YD_TEC==cCod) //ira atualizar apenas a primeira NCM - mjb081299 - Tecwin2000
	     DbSkip(); LOOP
      EndIf

      //** PLB 30/08/07 - Verifica se NCM está fora do intervalo
      If !Empty(cNCMFim)  .And.  SYD->YD_TEC > cNCMFim
         Exit
      EndIf
      //**

      cCod   := SYD->YD_TEC
      cSeq   := IF(EMPTY(SYD->YD_EX_NCM),STRZERO(1,AVSX3("YD_EX_NCM",3)),SYD->YD_EX_NCM)
      nRecno := SYD->(RECNO())
      cExNCM := IIF(Empty(SYD->YD_EX_NCM),Space(Len(SYD->YD_EX_NCM)),SYD->YD_EX_NCM)

      Aliq->(DBAPPEND())  
  
      If nOpRad==1                      //Aduaneiras
         Aliq->CODIGO     :=cCod
         Aliq->SEQUENCIAL :=cSeq
         Aliq->RECNO      :=nRecno
         Aliq->II         :=NAOATUALIZADO
         Aliq->IPI        :=NAOATUALIZADO
         Aliq->PIS        :=NAOATUALIZADO
         Aliq->COFINS     :=NAOATUALIZADO
         Aliq->RECUP      :="N"
      
         //AST - 03/09/08 - Verifica se usa o sistema InterfWeb da Aduaneiras
         //caso a variavel esteja vazia, atualiza com o valor da 1ª NCM selecionada
         If lInterfWeb                                                     
            If alltrim(cCod) == cNcmIni .Or. Empty(cNcmIni)
               cNcmIni := cCod
               cNCM := alltrim(cCod)
            Else
               cNCM += ","+alltrim(cCod)
            Endif
            //Grava as informações serão gravadas no arquivo easytec.txt em lotes 100.
            // 8 tamanho da NCM, 100 quantidade de NCM, 99 vírgulas entre as NCM's
            If len(cNCM) >= (8*100+99)
               TxtEasyTec(cNCM)
               cNCM := ""
            endIf   
         EndIf

      Else  //Infosolution e Easy Legis
         Aliq->CODNCM:=cCod
         Aliq->RECUP :="N"
         Aliq->RECNO := nRecno
         //** PLB - 30/08/07
         If nOpRad == 2  // InfoSolution
            Aliq->EXNCM := cExNCM
         EndIf
         //**
      Endif

      IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_LEITURA_NCM"),)

      DBSKIP()

     // PLB 30/08/07 - Pode ser que não existam NCM's no intervalo informado, código executado no início do Loop
     //If SYD->YD_TEC>cNCMFim.and.!Empty(cNCMFim)
     //   EXIT
     //Endif

   ENDDO

#ENDIF                      
//AST 03/09/08
//Caso o lote não complete 100 NCM's, grava as restante no arquivo easytec.txt
If lInterfWeb
   If len(cNCM) > 1
      TxtEasyTec(cNCM)
   EndIf
Endif

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"FIN_LOOP_LEITURA_NCM"),)

If Aliq->(Eof() .And. Bof())
   TecMSGINFO(STR0044) //STR0044 "Nao existem NCMs a serem atualizadas"
   Aliq->(DBCLOSEAREA())
   Return .F.
EndIf

Aliq->(DBCLOSEAREA())

RETURN .T.

*-----------------------------------------------------------------------------
Function EicAtuAliq(cFileTemp,nOpRad)
*-----------------------------------------------------------------------------
LOCAL n, nRec := 0, lExistSX3:=.F., nOrder, cDir2         //CDS 1/7/05
Local ErrRun:=0, cLog, S
Local nBein:=0
Local nMal:=0
Local cAtuDir, cPath
Local tamanho:=0 //msv 27/03/2006
Local lCreate := .F.
//AST -03/09/08 - variaveis utilizadas no novo tratamento na integração Aduaneiras (InterfWeb)                                 
Local lSemErro := .T. //armazena se o InterfWeb retornou algum erro 
Local nAliquota := 0 // EJA - 25/07/2017

//RMD - 30/09/16 - Alterado para private para verificação via ponto de entrada.
//Local aAliq //vetor que irá armazenar as NCM e suas aliquotas obtidas no arquivo de retorno no InterfWeb 

Local nCont, nFound //nCont, contador; nFound armazena se a execução do InterfWeb retornou algum erro                                        

//RMD - 30/09/16 - Alterado para private para verificação via ponto de entrada.
//Local nII,nIPI,nPISPAS,nCOFINS, nMajCofins /*RMD - 02/05/16 - Verifica majoração de cofins */  	//variaveis que armazenam a posição das aliquotas no vetor aAliq, a posição muda 
								                               									// de acordo com a configuração do InterfWeb
                               
                                                                                             
//Local nParametro := EasyGParam("MV_TIPOADU",,1)
PRIVATE lAtualizou:=.T.
PRIVATE aNCM:={}
                               
Private cFileTxt //Nome do arquivo gerado pelo InterfWeb: Interfato(/ato) , InterfNaladi(/Naladi) ou Interf(/geral)

//RMD - 30/09/16 - Alterado para private para verificação via ponto de entrada.
Private aAliq //vetor que irá armazenar as NCM e suas aliquotas obtidas no arquivo de retorno no InterfWeb 
Private nII,nIPI,nPISPAS,nCOFINS, nMajCofins /*RMD - 02/05/16 - Verifica majoração de cofins */  	//variaveis que armazenam a posição das aliquotas no vetor aAliq, a posição muda 
	     							                               									// de acordo com a configuração do InterfWeb
cUsr :=AllTrim(EasyGParam("MV_ET_USER",,""))//Usuario Login EXPORT.EXE
cPas :=AllTrim(EasyGParam("MV_ET_PASS",,""))//Password Login Export.Exe
cIP  :=AllTrim(EasyGParam("MV_ET_IP"  ,,""))//IP Servidor Infoconsult (192.168.0.22)
cPort:=AllTrim(EasyGParam("MV_ET_PORT",,""))//IP Servidor Infoconsult (3306)

IF nOpRad # 3//AWR - 13/01/2006
   TecProcRegua( Aliq->(EasyRecCount("Aliq")) )
ENDIF
nTotal:=Aliq->(EasyRecCount("Aliq"))  //AWR - 14/01/2006

IF !Empty ( AllTrim( cAtuDir := GetPvProfString( GetEnvServer(), "RootPath", "", GetADV97() ) ) )
	IF !( Subst( cAtuDir , 1 , 1 ) $ "\/" )
		cAtuDir := "\"+cAtuDir
	EndIF
	IF !( Subst( cAtuDir , -1	) $ "\/" )
		cAtuDir += "\"
	EndIF
EndIf

n:=RAT("\",cDirExport)
cPath:=AllTrim(Left(cDirExport,n-1)) 

Do Case

   Case nOpRad==1       //Recupera Usando Aduaneiras
     //AST - 03/09/08 - verifica se utiliza a nova integração Aduaneiras
     If !lInterfWeb
        If Empty(cUsr)
  	       eMens+=STR0045 + chr(13) + chr(10) //STR0045  "Atencao: Usuario Login Export.exe nao definido (MV_ET_USER)"
  	       TecMSGINFO(STR0046,STR0047) //STR0046 "Usuario Login Export.exe nao definido (MV_ET_USER)" STR0047 "Atencao"
  	       Return.F.
  	    Endif
  	    If Empty(cPas)
  	       eMens+=STR0048 + chr(13) + chr(10) //STR0048 "Atencao: Password Login Export.exe nao definido (MV_ET_PASS)"
  	       TecMSGINFO(STR0049,STR0047) //STR0049 "Password Login Export.exe nao definido (MV_ET_PASS)"
  	       Return.F.
  	    Endif

  	    nRec:=SX3->(RecNo())
  	    nOrder:=SX3->(IndexOrd())
  	    SX3->(DbSetOrder(2))
  	    lExistSX3:=SX3->(DbSeek("YD_NUM_EX"))
  	    SX3->(DbSetOrder(nOrder))
  	    SX3->(DbGoTo(nRec))
  	    nRec := 0
  	    TecProcRegua( Aliq->(EasyRecCount("Aliq")) )
  	    IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"ATUALIQ_ANTES_WHILE"),)

  	    SYD->(DbSetOrder(1))
  	    Aliq->(DBGotop())

  	    WHILE ! Aliq->(EOF())

  	       TecIncProc(STR0050 + AllTrim(Aliq->Codigo) + "   " + AllTrim(Str(Aliq->(Recno()))) + " / " + AllTrim(Str(Aliq->(EasyRecCount("Aliq")))) ) //STR0050 "Recuperando NCM "

  	       If Aliq->RECUP<>"N"
  	          Aliq->(DBSkip())
  	          Loop
  	       Endif

           //RMD - 01/08/08 - Insere a barra no final do caminho do executável
           If Right(AllTrim(cDirExport), 1) <> "\" // EJA - 21/06/2017 - Left para Right
              cDirExport := AllTrim(cDirExport) + "\"
           EndIf

           // ErrRun:=WaitRun(cDirExport+"EXPORT.EXE "+cUsr+" "+cPas+" "+cDirDBF+cFileTemp+".txt "+AllTrim(Aliq->Codigo)+" \U="+AllTrim(cUserRede)+" \S="+AllTrim(cSenhaRede),0) rjb 18/01/2006
  	       ErrRun:=WaitRun(cDirExport+"EXPORT.EXE "+cUsr+" "+cPas+" "+cDirDBF+cFileTemp+".txt "+AllTrim(Aliq->Codigo)+" /U="+AllTrim(cUserRede)+" /S="+AllTrim(cSenhaRede),0)

           IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_DEP_WAITRUN1"),)

  	       If ErrRun<>0
  	          eMens+=STR0051 + str(ErrRun) + chr(13) + chr(10) //STR0051 "Erro na execucao do Export.EXE: "
  	          lAtualizou:=.F.
  	          Exit
  	       Endif

  	       cLog:=EXPReadLog(cDirDBF + cFileTemp + ".log")

  	       If cLog<>"0"
  	          eMens+=STR0052 + AllTrim(Aliq->Codigo) + " - " + AllTrim(eExport[val(cLog)+1]) + chr(13) + chr(10) //STR0052 "Erro na recuperacao da NCM: "
  	          nMal++
  	       Else

  	          aNCM:=EXPReadNCM(cDirDBF + cFileTemp + ".txt")

              IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_DEP_LEIT_TXT"),)

  	          If Empty(aNCM)
  	             eMens+=STR0052 + AllTrim(Aliq->Codigo) + STR0053 + chr(13) + chr(10) //STR0053 " - Codigo nao Encontrado na Tabela de Recuperacao"
  	          Elseif Len(aNCM) < 7
  	             eMens+=STR0052 + AllTrim(aNCM[1]) + STR0054 + chr(13) + chr(10) //STR0054 " - Alíquotas nao Encontradas na Tabela de Recuperacao"
  	          Endif

  	          IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"ANTES_GRAVAR"),)

  	          If !Empty(aNCM).and.AllTrim(aNCM[1])==AllTrim(Aliq->CODIGO)
  	             RecLock("ALIQ",.F.)
  	             Aliq->II  :=aNCM[4]
  	             Aliq->IPI :=aNCM[5]
  	             Aliq->PIS :=aNCM[6]
  	             Aliq->COFINS:=aNCM[7]
  	             Aliq->RECUP := "S"
                 IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_ATU_TEMP1"),)
  	             ALIQ->(MsUnlock())

  	             If SYD->(DBSeek(xFilial("SYD") + Aliq->CODIGO + AvKey(Aliq->SEQUENCIAL,"YD_EX_NCM")) )
  			        RecLock("SYD",.F.)
  	    	        SYD->YD_PER_II  := Val(aNCM[4])
  			        SYD->YD_PER_IPI := Val(aNCM[5])
  			        IF SYD->(FieldPos("YD_MAJ_PIS")) > 0  .AND. SYD->YD_MAJ_PIS <> 0 //GFP - 11/06/2013 - Considera a majoração antes de atualizar o PIS
                  
                  	  nAliquota := Val(aNCM[6]) - SYD->YD_MAJ_PIS
                  	  If(nAliquota < 0, nAliquota := 0,) // EJA - 25/07/2017 - Se negativo, atribuir para zero
  			          SYD->YD_PER_PIS := nAliquota

  			        ELSE
  			           SYD->YD_PER_PIS := Val(aNCM[6])
  			        ENDIF
                    IF SYD->(FieldPos("YD_MAJ_COF")) > 0  .AND. SYD->YD_MAJ_COF <> 0 //RRV - 30/08/2012 - Considera a majoração antes de atualizar o COFINS

                       nAliquota := Val(aNCM[7]) - SYD->YD_MAJ_COF
                       if(nAliquota < 0, nAliquota := 0,) // EJA - 25/07/2017 - Se negativo, atribuir para zero
                       SYD->YD_PER_COF := nAliquota
                    ELSE
                       SYD->YD_PER_COF := Val(aNCM[7])
                    ENDIF
  			        IF lCposLog //AWR - 06/02/2006
                       SYD->YD_GRVUSER:="Aduaneiras-"+SubStr(cUsuario,7,15)
                       SYD->YD_GRVDATA:=dDataBase
                       SYD->YD_GRVHORA:=TIME()
                    ENDIF
                    IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_ATU_SYD1"),)
  			        SYD->(MsUnlock())
  			        nBein++
  			     Else
  	 		        eMens+=STR0052 + AllTrim(Aliq->Codigo) + STR0055  + chr(13) + chr(10) //STR0055 " - Codigo nao Encontrado na Tabela de NCM"
  	                RecLock("ALIQ",.F.)
  	                Aliq->RECUP :="N"
  	                ALIQ->(MsUnlock())
  	                nMal++
  	             Endif

  	          Else

  	             RecLock("ALIQ",.F.)
  	             Aliq->RECUP :="N"
  	             ALIQ->(MsUnlock())
  	             nMal++
  		         //eMens+="Erro na recuperacao da NCM: " + AllTrim(Aliq->Codigo) + " - Codigo nao coincide com resposta do Tecwin"  + chr(13) + chr(10) --> Chamado 044346
  		         eMens+=STR0052 + AllTrim(Aliq->Codigo) + STR0056 + chr(13) + chr(10) //STR0056 " - Codigo nao coincide com resposta do Export da Aduaneiras"
  	          Endif
            
  	       Endif  //Log<>0

  	       IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"DEPOIS_GRAVAR"),)

  	       n:=FErase(cDirDBF + cFileTemp + ".log")
  	       n:=FErase(cDirDBF + cFileTemp + ".txt")

  	       Aliq->(DBSKIP())
  	    ENDDO
  	 
  	 // AST - 03/09/08- Nova Integração Aduaneiras 
  	 Else 
  	    If Right(cDirExport,1) <> "\"
  	       cDirExport += "\"
  	    EndIf 
  	    
  	    If File(cDirExport+"InterfWeb.exe") 
           //Verifica se existe os arquivos de qualquer tipo de integração, caso positivo exclui
           If !lSchedule                            //NCF - 13/10/2017   
              If File(cDirExport+"INTERFATO.txt")
                 FErase(cDirExport+"INTERFATO.txt")
              EndIf
              If File(cDirExport+"INTERFNALADI.txt")
                 FErase(cDirExport+"INTERFNALADI.txt")
              EndIf
              If File(cDirExport+"INTERF.txt")  
                 FErase(cDirExport+"INTERF.txt")
              EndIf
           EndIf
           // AST - 02/11/08 - Versão 3.2 do InterfWeb estava gerando o log na raiz, criada função runInterf para contornar o problema
           /*
           If EasyGParam("MV_TIPOADU",,1) == 1 //caso o parametro não exista utiliza a configuração para Ato Legal
              cFileTxt := "Interfato.txt"
              WaitRun(cDirExport+"InterfWeb.exe /auto /ato")
           ElseIf EasyGParam("MV_TIPOADU") == 2
              cFileTxt := "InterfNaladi.txt"
              WaitRun(cDirExport+"InterfWeb.exe /auto /naladi")
           ElseIf EasyGParam("MV_TIPOADU") == 3
              cFileTxt := "Interf.txt"
              WaitRun(cDirExport+"InterfWeb.exe /auto /geral")              
           Else
              Alert("Erro na configuração do parametro MV_TIPOADU")
              return .F.
           EndIF
           */
  	       
  	       runInterf(cDirExport)
  	       
  	       //obtem valor do log, se for 0, importação realizada com sucesso
  	       cLog:=EXPReadLog(cDirExport+"InterfWeb.log")
  	       
  	       if val(subStr(cLog,1,2)) <> 0
              //Exibe a mensagem de erro que se encontra no arquivo InterfWeb.log, gerado pelo InterWeb.exe
  	          If File(cDirExport+cFileTxt)   
    	         lSemErro := ApMsgYesNo(STR0132+space(1)+alltrim(subStr(cLog,3,Len(cLog)))+ENTER+STR0116) //STR0116 "Deseja continuar com a importação?"
    	      Else
    	         Alert(STR0132+space(1)+alltrim(subStr(cLog,3,Len(cLog))))
    	         lSemErro := .F. //Caso o log apresente erro e o arquivo não tenha sido gerado, apreenta a mensagem e força a saida do programa
    	      EndIf   
  	       Endif                   
  	       
  	       If lSemErro  	             
  	          //adiciona no vetor todas as informações encontradas no arquivo InterFato.txt
  	          aAliq := txt2Array(cDirExport+cFileTxt)
  	             
  	          if len(aAliq) > 0                                                 
  	             //copia o arquivo InterFato.txt para a pasta system do servidor, renomeando a cópia antiga para interfato.old
  	             cpyTxt2Srv(cDirExport,If(lSchedule,cDirExport,NIL))
  	          
                 IndRegua("Aliq",cFileTemp+TEOrdBagExt(),"CODIGO+SEQUENCIAL")
                 //SET INDEX TO (cFileTemp+TEOrdBagExt()) //THTS - 06/11/2017 - NOPADO - o IndRegua já abre o indice
  	        
  	             //obtem as posições das aliquotas no vetor, através do cabeçalho, que se encontra na 1ª dimensão do vetor
  	             nII     := aScan(aAliq[1],{|x| x == "II"})
  	             nIPI    := aScan(aAliq[1],{|x| x == "IPI"})
  	             nPISPAS := aScan(aAliq[1],{|x| x == "PISPAS"})
  	             nCOFINS := aScan(aAliq[1],{|x| x == "COFINS"})
  	            	          
  	             //RMD - 02/05/16 - Verifica se foi recebido o percentual de majoração do COFINS
  	             nMajCofins := aScan(aAliq[1],{|x| x == "ACRCOFINS"})
  	            	          
  	             TecProcRegua(len(aAliq)) 
  	              
  	             //Atualização da work, começa da 2 posição do vetor, pois a 1ª é o cabeçalho.
  	             For nCont := 2 to len(aAliq)                      
  	                TecIncProc(STR0117+alltrim(str(nCont))+"/"+alltrim(str(len(aAliq)))) // STR0117 "Atualizando alíquotas: "
  	                
  	                If EasyGParam("MV_EIC0039",,.F.)//AAF - 11/11/2013 - Atualiza Aliquota pela Ex contida na descrição do arquivo de integração InterfWeb Aduaneiras
  	                   nPosEx := At("Ex",aAliq[nCont][3])
  	                   nPosTr := At(" -",aAliq[nCont][3])
  	                   
  	                   If nPosEx > 0 .AND. nPosEx < nPosTr
  	                      cEx := AllTrim(SubStr(aAliq[nCont][3],nPosEx+2,nPosTr-2))
  	                   Elseif nPosEx > 0 .AND. nPosTr == 0 // EJA - 22/06/2017 - Se existir Ex, mas não existir traço, então, obtém até o fim da string
                          cEx := AllTrim(SubStr(aAliq[nCont][3],nPosEx+2))
                       Else
  	                      cEx := AvKey("","YD_EX_NCM")
  	                   EndIf
  	                Else
  	                   cEx := aAliq[nCont][2]
  	                EndIf
  	                
  	                //                                 NCM              SEQUENCIA
  	                If Aliq->(DbSeek(comChave("YD_TEC",aAliq[nCont][1])+cEx))   //AAF - 11/11/2013
  	                   //Atualiza apenas na primeira ocorrência, o vetor é ordenado por NCM+Sequencia em ordem crescente e data inicial em ordem decrescente
  	                   If alltrim(Aliq->II) == "*"
  	                      Aliq->(RecLock("Aliq",.F.))
  	                      if(!nII  == 0, Aliq->II  := aAliq[nCont][nII],)
  	                      if(!nIPI == 0, Aliq->IPI := aAliq[nCont][nIPI],)
  	                      if(!nPISPAS == 0, Aliq->PIS    := aAliq[nCont][nPISPAS],)
  	                      if(!nCOFINS == 0, Aliq->COFINS := aAliq[nCont][nCOFINS],)
  	                      
  	                      //RMD - 02/05/16 - Atualiza o percentual de majoração do COFINS, caso tenha sido recebido.
  	                      If nMajCofins > 0 .And. SYD->(FieldPos("YD_MAJ_COF")) > 0
  	                         Aliq->MAJCOF := aAliq[nCont][nMAJCOFINS]
  	                      EndIf
  	                      
  	                      /*
  	                         RMD - 30/09/16 - Possibilita a personalização das informações recebidas via integração InterfaceWeb antes da gravação na tabela de NCM.
  	                      */
  	                      If EasyEntryPoint("EASYTEC")
  	                         Execblock("EASYTEC",.F.,.F.,"INTERF_CARREGA_ALIQUOTA")
  	                      EndIf
  	                      
  	                      Aliq->(MsUnlock())
  	                   EndIf   
  	                EndIf
  	             Next   	      
  	          
  	             ALIQ->(DBGotop())

                 TecProcRegua(len(aAliq)) 
                   
                 While !ALIQ->(Eof())
                    TecIncProc(STR0118+alltrim(str(nBein+nMal))+"/"+alltrim(str(Aliq->(EasyRecCount("Aliq"))))) //STR0118 "Atualizando base de dados: "
                    //Verifica se o arquivo não teve atualização
                    If alltrim(Aliq->II) == "*"
                       nMal++
   	 		           eMens+=STR0052 + AllTrim(Aliq->CODIGO) +space(1)+ StrTran(STR0130,"'###'",cFileTxt)  + chr(13) + chr(10) //STR0130 - "Código não encontrado no arquivo '###'"        
   	 		           Aliq->(DBSkip())
   	 		           LOOP
                    Endif
             

     	            SYD->(dbGoTo(Aliq->RECNO))
                    //Posiciona no registro e verifica se na work o mesmo teve alteração
     	            If SYD->(RECNO()) == Aliq->RECNO .And. alltrim(Aliq->II) != "*"
     	               //Atualiza o registro no banco de dados
     	               RecLock("SYD",.F.)     	          
                       SYD->YD_PER_II  := Val(Aliq->II)
                       SYD->YD_PER_IPI := Val(Aliq->IPI)
                       // AST - 03/12/08 - Após alinhamento com a Aduaneiras, os campos existentes no lay-out do txt, não dependem do tipo integração e sim dos campos solicitados pelo cliente no contrato.
                       //If nParametro == 1   //TRP-28/11/08 - Verifica se integração é do tipo Ato Legal para atualizar alíquotas de Pis e Cofins.
                       
                       //RMD - 02/05/16 - Caso o percentual de majoração do COFINS tenha sido recebido, atualiza o campo
                       If nMajCofins > 0 .And. SYD->(FieldPos("YD_MAJ_COF")) > 0
                          SYD->YD_MAJ_COF := Val(Aliq->MAJCOF)
                       EndIf
                       
                       If nPISPAS > 0
                          IF SYD->(FieldPos("YD_MAJ_PIS")) > 0  .AND. SYD->YD_MAJ_PIS <> 0 //GFP - 11/06/2013 - Considera a majoração antes de atualizar o PIS
                             nAliquota := Val(Aliq->PIS) - SYD->YD_MAJ_PIS
                             If(nAliquota < 0, nAliquota := 0,) // EJA - 25/07/2017 - Se negativo, atribuir para zero
                             SYD->YD_PER_PIS := nAliquota
                          ELSE
                             SYD->YD_PER_PIS := Val(Aliq->PIS)
                          ENDIF
                       EndIf
                      IF nCOFINS > 0
                          IF SYD->(FieldPos("YD_MAJ_COF")) > 0  .AND. SYD->YD_MAJ_COF <> 0 //RRV - 30/08/2012 - Considera a majoração antes de atualizar o COFINS
                             nAliquota := Val(Aliq->COFINS) - SYD->YD_MAJ_COF
                             If(nAliquota < 0, nAliquota := 0,) // EJA - 25/07/2017 - Se negativo, atribuir para zero
                             SYD->YD_PER_COF := nAliquota
                          ELSE
                             SYD->YD_PER_COF := Val(Aliq->COFINS)
                          ENDIF
                       Endif
    
                       IF lCposLog
                          SYD->YD_GRVUSER:="InterfWeb-"+cUsuario
                          SYD->YD_GRVDATA:=dDataBase
                          SYD->YD_GRVHORA:=TIME()
                       ENDIF
    
  			           SYD->(MsUnlock())
  	                   RecLock("ALIQ",.F.)
  	                   //Atualiza a work como registro atualizado
  	                   Aliq->RECUP :="S"
  	                   ALIQ->(MsUnlock())
  			           nBein++
  			        Else
  			           eMens+= STR0052 + space(1) + AllTrim(Aliq->Codigo) + space(1) + STR0130 + chr(13) + chr(10) //STR0130 - Código não encontrado no arquivo interfato.txt
  	                   RecLock("ALIQ",.F.)
  	                   Aliq->RECUP :="N"
  	                   ALIQ->(MsUnlock())
  	                   nMal++
                    Endif
     	       
                    Aliq->(DBSkip())
                 EndDo  	    
  	          Else
  	             TecMSGINFO(StrTran(STR0119,"'###'",cFileTxt)) //STR0119 "Erro no arquivo '###'" 
  	          EndIf
  	       EndIf   
  	    EndIf  	 
  	 EndIf   

    // -- Recupera Usando INFOTEC	 --
   Case nOpRad==2
     /* AAF - Retirada as validações de configuração do servidor TEC da infoconsult.
  	 If Empty(cIP)
  	    eMens+=STR0057 + chr(13) + chr(10) //STR0057 "Atencao: IP do Servidor TEC da Infoconsult nao Definido (MV_ET_IP)"
     	    TecMSGINFO(STR0057,STR0047)
          Return.F.
    	 Endif
  	 If Empty(cPort)
  	    eMens+=STR0058 + chr(13) + chr(10) //STR0058 "Atencao: PORTA do Servidor TEC da Infoconsult nao Definido (MV_ET_PORT)"
     	    TecMSGINFO(STR0058,STR0047)
  	    Return.F.
  	 Endif
     */
       //Copiar o Aliq a diretorio de instalacao do programa com o nome ALIQ.DBF
       //Aliq->(DBCloseArea())

       If Right( cDirExport , 1 ) <> "\"  // (i:=RAT("\",cDirExport))<>0 -- mpg 05/03/2018 não encontrava as pasta
          cDirExport := cDirExport + "\"
          /*
          cDir2:=SubStr(cDirExport,1,i)

          If AvCpyFile(cFileTemp+".dbf",cDir2 + cFileTemp + ".dbf")==.F.
             eMens+=STR0059 + cDir2+cFileTemp + ".dbf" + chr(13) + chr(10) //STR0059 "Erro ao Tentar copiar no diretorio de instalação do TEC: "
          Endif

    	  ErrRun:=WaitRun(cDirExport + "CONVERSOR.EXE " + cPath + " " + cFileTemp + ".dbf" + " " + cIP + " " + cPort,0)
          */
          
          //** PLB 30/08/07 

          // Executa o aplicativo da InfoCounsult
          //** AAF 09/11/07 - Na versão atual do Software da InfoConsult, não existe mais o CONVERSOR.EXE
          //   Agora a InfoConsult tem um programa que atualiza o arquivo TEC.TXT com uma certa periodicidade.
          If File(cDirExport+"CONVERSOR.EXE") 
             //Renomeia arquivo txt para old antes da gravação do novo txt
             If File(cDirExport+"tec.txt")
                If File(cDirExport+"tec.old")
                   FErase(cDirExport+"tec.old")
                EndIf
                FRename(cDirExport+"tec.txt" , cDirExport+"tec.old")
             EndIf
             
             WinExec(cDirExport+"CONVERSOR.EXE",0)
             
             // Verifica se o CONVERSOR já terminou a geração do txt
             TecProcessa({|lEnd| lCreate := CONWriteNCM(cDirExport+"tec.txt",@lEnd) }, STR0110 )  // "Aguarde, executando CONVERTEC..."
          
          IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_DEP_WAITRUN2"),)
             
             //If ErrRun<>0
             If !lCreate
                //eMens+=STR0060 + str(ErrRun) + chr(13) + chr(10) //STR0060 "Erro na execução do CONVERSOR.EXE  :"
                eMens+=STR0060 + chr(13) + chr(10) //STR0062 "Erro na execução do CONVERSOR.EXE  :"
                //fErase(cDir2 + cFileTemp+".dbf")
                lAtualizou:=.F.
                Return lAtualizou
     	     Endif
          Else
             If !File(cDirExport+"tec.txt")
                eMens+= STR0112 + chr(13) + chr(10) //"Arquivo TEC.TXT não encontrado. Por favor, verifique as configurações de diretório e do software da InfoConsult"
                lAtualizou:=.F.
                Return .F.
             EndIf
          EndIf
          //** */
          
          // PLB 30/08/07 - Lê as informações do TXT carregadas em um array e grava no arquivo DBF
          TecProcessa({|lEnd| CONReadNCM(cDirExport+"tec.txt") }, STR0107)  // "Leitura das Alíquotas no CONVERTEC"
          
          ALIQ->(DBGotop())

          While !ALIQ->(Eof())

             TecIncProc(STR0050 + AllTrim(Aliq->CodNcm) + "   " + AllTrim(Str(Aliq->(Recno()))) + " / " + AllTrim(Str(Aliq->(EasyRecCount("Aliq")))) )

             If Aliq->RECUP == "N" //AAF 03/09/08
                nMal++
   	 		    eMens+=STR0052 + AllTrim(Aliq->codncm) + STR0053  + chr(13) + chr(10) //" - Codigo nao Encontrado na Tabela de Recuperacao"
   	 		    Aliq->(DBSkip())
   	 		    LOOP
             Endif

     	     IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"ANTES_GRAVAR_INFO"),)

             //If SYD->(DBSeek(xFilial("SYD") + AvKey(Aliq->CodNcm,"YD_TEC")) ) 		//cds 21/9/05
             If SYD->( DBSeek(xFilial("SYD")+AvKey(Aliq->CODNCM,"YD_TEC")+AvKey(Aliq->EXNCM,"YD_EX_NCM")) )  // PLB 30/08/07
     	          RecLock("SYD",.F.)
     	          //Se a configuraçao decimal for ponto, transformar "," em "."
     	          /*
     	          If Val("12,34")<>12.34
     	             Aliq->II 		:=StrTran(Aliq->II,",",".")
     	             Aliq->IPI		:=StrTran(Aliq->IPI,",",".")
     	             Aliq->PISPASEP :=StrTran(Aliq->PISPASEP,",",".")
     	             Aliq->COFINS   :=StrTran(Aliq->COFINS,",",".")
     	          Endif
     	          */

                   SYD->YD_PER_II  := Val(Aliq->II)
                   SYD->YD_PER_IPI := Val(Aliq->IPI)
                   // GFP - 14/08/2013 - Decremento já foi efetuado na integração de dados.
                   // MCF - 24/11/2015 - Retirado comentário do trecho para majoração do PIS.
                   // MCF - 23/02/2016 - Verifica se aliquota informada no arquivo é maior que zero para evitar valor negativo.
                   IF SYD->(FieldPos("YD_MAJ_PIS")) > 0  .AND. SYD->YD_MAJ_PIS <> 0 .And. Val(Aliq->PISPASEP) > 0//GFP - 11/06/2013 - Considera a majoração antes de atualizar o PIS
                      
                      nAliquota := Val(Aliq->PISPASEP) - SYD->YD_MAJ_PIS
                      If(nAliquota < 0, nAliquota := 0, ) // EJA - 25/07/2017 - Se negativo, atribuir para zero
                      SYD->YD_PER_PIS := nAliquota
                   ELSE
                      SYD->YD_PER_PIS := Val(Aliq->PISPASEP)                   
                   ENDIF
                   
                   // GFP - 14/08/2013 - Decremento já foi efetuado na integração de dados.
                   // MCF - 24/11/2015 - Retirado comentário do trecho para majoração do COFINS.
                   // MCF - 23/02/2016 - Verifica se aliquota informada no arquivo é maior que zero para evitar valor negativo.
                   IF SYD->(FieldPos("YD_MAJ_COF")) > 0  .AND. SYD->YD_MAJ_COF <> 0 .And. Val(Aliq->COFINS) > 0 //RRV - 30/08/2012 - Considera a majoração antes de atualizar o COFINS
                      
                      nAliquota := Val(Aliq->COFINS) - SYD->YD_MAJ_COF
                      If(nAliquota < 0, nAliquota := 0, ) // EJA - 25/07/2017 - Se negativo, atribuir para zero
                      SYD->YD_PER_COF := nAliquota
                   ELSE
                      SYD->YD_PER_COF := Val(Aliq->COFINS)
                   ENDIF
                // PLB 30/08/07 - Não grava pois é utilizado como chave para busca de alíquotas
                //SYD->YD_EX_NCM  := If(AllTrim(Aliq->EXNCM)!="000",AllTrim(Aliq->EXNCM),"")
  			  IF lCposLog //AWR - 06/02/2006
                   SYD->YD_GRVUSER:="Infoconsult-"+SubStr(cUsuario,7,15)
                   SYD->YD_GRVDATA:=dDataBase
                   SYD->YD_GRVHORA:=TIME()
                ENDIF
                IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_ATU_SYD2"),)
  			  SYD->(MsUnlock())
  	          RecLock("ALIQ",.F.)
  	          Aliq->RECUP :="S"
  	          ALIQ->(MsUnlock())
  			  nBein++
  			Else
  	 		  eMens+=STR0052 + AllTrim(Aliq->CodNCM) + STR0055  + chr(13) + chr(10)
  	          RecLock("ALIQ",.F.)
  	          Aliq->RECUP :="N"
  	          ALIQ->(MsUnlock())
  	          nMal++
             Endif
     	       IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"DEPOIS_GRAVAR_INFO"),)
             Aliq->(DBSkip())
          End

       Endif
       
   Case nOpRad==3
     cHTTP:=RTrim(EasyGParam("MV_ET_HTTP",,""))           //Endereco do Easy Legis: http://www.legiscenter.com.br/_websrv_/_websrv_01.cfm
     
     If Empty(cHTTP)
        eMens+=STR0063 + chr(13) + chr(10) //STR0063 "Atencao: Endereco do Easy Legis nao definido (MV_ET_HTTP)"
 	    TecMSGINFO(STR0064,STR0047) //STR0064 "Endereco do Easy Legis nao definido (MV_ET_HTTP)"
 	    Return.F.
     Endif
     
     //JAP - 28/07/06 - Validação da Extensão do Endereço do Easy Legis.
     cExtHTTP := UPPER(Substr(cHTTP, -4, 4))
     If cExtHTTP <> ".CFM"
        eMens+=STR0065 + chr(13) + chr(10) //STR0065 "Atencao:Endereço do Easy Legis incorreto, verifique o parâmetro MV_ET_HTTP."
        TecMSGINFO(STR0066,STR0047) //STR0066 "Endereço do Easy Legis incorreto, verifique o parâmetro MV_ET_HTTP."
        Return .F.
     EndIf
     

     PRIVATE nTimeOut:= 300 // 120 segundos é o default
     PRIVATE nCount  := 0, nTamVM:=AVSX3("YD_VM_TEXT",3)
     PRIVATE cRetornoXML:="", cNCM:="", cErro:="", cWarning:=""
     PRIVATE aSequencia :={}, nBloco:=EasyGParam("MV_QTBLOCO",,300), nContBloco:=0 //msv 27/03/2006
     PRIVATE cArquivoXML:=AllTrim(GetSrvProfString("StartPath",""))+E_Create(,.F.)+".XML"//"RetornoMS.XML"//
     PRIVATE cAlias:="Q_SYD",cCod:="", cWhere:="", cFilSYD:=xFilial("SYD")
     IF SYD->(FIELDPOS("YD_MOT_II")) # 0 .AND. SYD->(FIELDPOS("YD_MOT_IPI")) # 0
        PRIVATE nTamIPI:=AVSX3("YD_MOIPIVM" ,3)
        PRIVATE nTamII :=AVSX3("YD_MOII_VM" ,3)
     ENDIF
     
     IF SYD->(FIELDPOS("YD_MOT_II")) # 0 .AND. SYD->(FIELDPOS("YD_MOT_IPI")) # 0
        nTamIPI:=AVSX3("YD_MOIPIVM" ,3)
        nTamII :=AVSX3("YD_MOII_VM" ,3)
     ENDIF
     
     IF !lGravaDes
        nBloco:= nBloco-50
     ENDIF
     IF !lAmparoDes
        nBloco:=nBloco-100
     ENDIF

     IF SX2->(DBSEEK("SYD"))
       cArqSYD := RetSQLName("SYD")
     ENDIF

     cQuery:=" SELECT COUNT(DISTINCT YD_TEC) TOTAL FROM "+cArqSYD
     cWhere:=" WHERE YD_FILIAL  = '"+cFilSYD+"'" // msv 30/03/2006
     cWhere+=" AND "+cArqSYD+".D_E_L_E_T_ <> '*' "+ENTER
     IF !Empty(cNCMIni)
        cWhere+=" AND YD_TEC >= '"+cNCMIni+"'"
     ENDIF
     IF !Empty(cNCMFim)
        cWhere+=" AND YD_TEC <= '"+cNCMFim+"'"
     ENDIF

     IF !GerTCQuery(cQuery+cWhere,"Q_SYD")
        RETURN .F.
     ENDIF

     nTotal:=Q_SYD->TOTAL
     
     //cQuery:=" SELECT R_E_C_N_O_ REGISTRO FROM "+cArqSYD
     cQuery:=" SELECT DISTINCT YD_TEC FROM "+cArqSYD //msv 30/03/2006

     IF !GerTCQuery(cQuery+cWhere+" ORDER BY YD_TEC ","Q_SYD")
        RETURN .F.
     ENDIF

     TecProcRegua( nTotal )
     cTotalA  :=" / "+ALLTRIM( STR(nTotal,6) )
     nContador:=0
     (cAlias)->(DBGOTOP())

     IF !lSchedule
        oDlgProc:=GetWndDefault()
     ENDIF

     cPostParms := "tp_usuario="+cTipoMS+"&"//01-Average 02-Cliente"
     cPostParms += "ident_usuario="+cIdUsu+"&"//13967
     cPostParms += "cod_cliente="+cCliMS+"&"//codigo do cliente"
     cPostParms += "string_aut="+cStrAutMS+"&"//string autenticadora"

     //MSV 27/03/2006
     //cPostParms := "login_usuario="+cUsuMS+"&"//avetec"
     //cPostParms += "senha_usuario="+cSenhaMS+"&"//legis"
     //cPostParms += "tp_usuario="+cTipoMS+"&"//01"
     //MSV 27/03/2006
     IF !lGravaDes .OR. !lAmparoDes
        //excluir_campos: Nele você informará a lista de campos que você não quer que retorne no XML.
        //(1) Descrição do NCM
        //(2) Alíquota de IPI
        //(3) Amparo de IPI
        //(4) Alíquota de II
        //(5) Amparo de II"
        //(6) Descrição do NCM total
        //Exemplo:
        //excluir_campos = 1, não trará a Descrição do NCM
        //excluir_campos = 2,3, não trará Alíquota e Amparo de IPI
        //excluir_campos = 1,3,5, não trará Descrição do NCM e Amparos de IPI e II.
        cPostParms += "excluir_campos=1,"+IF(!lAmparoDes,"3,5,","")+IF(!lGravaDes,"6,","")
        cPostParms := LEFT(cPostParms,LEN(cPostParms)-1)+"&"
     ELSE
        cPostParms += "excluir_campos=1&"
     ENDIF

     IF !EMPTY(cUserProxy) .AND. !EMPTY(cSenhaProxy)
        HttpSetPass(cUserProxy,cSenhaProxy)
     ENDIF

     Do While .T. //(cAlias)->(Eof()) //msv    

        cCodNcm:=ALLTRIM(Q_SYD->YD_TEC) 
        
        nContador++
        TecIncProc(STR0050 + cCodNcm + " - " + AllTrim(Str(nContador,10)) + cTotalA )

        IF (cCodNcm==cCod) .and. !Empty(cCod)  //ira atualizar apenas a primeira NCM    //msv
           (cAlias)->(DbSkip())
           LOOP
        EndIf

        cCod:=cCodNcm

        If  !Empty(cCodNcm)  //msv
		   cNCM+=cCodNcm + ","
		   nCount += 1
		EndIf   
       
        IF nCount >= nBloco .OR. (cAlias)->(Eof()) //msv 

           nRecno:=SYD->(RECNO())

           IF !lSchedule
              oDlgProc:SetText(STR0067) //STR0067 "Criando XML, aguarde..."
           ENDIF

           cNCM := Left(cNCM,Len(cNCM)-1)  
           //msv - 13/04/2006
           If EMPTY(cNCM)  
             exit
           EndIF
           //msv - 13/04/2006
           cParametros:=cPostParms+"cod_ncm="+cNCM

           cRetornoXML := HttpPost(cHTTP ,""  ,cParametros ,nTimeOut)

           If cRetornoXML = NIL
              TecMSGINFO(STR0068+cHTTP,STR0069) //STR0068 "Erro ao executar: " STR0069 "Retorno NIL"
              eMens+=STR0068+cHTTP+STR0069
              Return .F.
           ENDIF

           cRetornoXML:=SubStr(cRetornoXML,At("<?", cRetornoXML),Len(cRetornoXML))

           If EMPTY(cRetornoXML)
              TecMSGINFO(STR0068+cHTTP,STR0070) //STR0070 "Retorno Branco"
              eMens+=STR0068+cHTTP+STR0070
              Return .F.
           ENDIF

           IF !lSchedule
              oDlgProc:SetText(STR0071) //STR0071 "Convertendo XML, aguarde..."
           ENDIF

           cRetornoXML:=ConverteXML(cRetornoXML)

           nCod:=EasyCreateFile(cArquivoXML)

           IF nCod # -1
              FWrite(nCod,cRetornoXML)
              FClose(nCod)
           ELSE
              TecMSGINFO(STR0072+cArquivoXML+STR0073) //STR0072 "Nao pode criar o arquivo: "
              eMens +=STR0072+cArquivoXML+STR0073 //STR0073 ", outro usuario integrando."
              Return .F.
           ENDIF

           cErro:=""
           oScript := XmlParserFile(cArquivoXML, "_", @cErro,"")

           If !Empty(cErro)
              TecMSGINFO(STR0074+Alltrim(cErro)+CHR(13)+CHR(10)+; //STR0074 "Problemas na conversao do XML: "
                      STR0075+cArquivoXML+STR0076) //STR0075 "Favor enviar arquivo: "
              eMens +=STR0074+Alltrim(cErro)+CHR(13)+CHR(10)
              eMens +=STR0075+cArquivoXML+STR0076 //STR0076 ", para analise na Average Tecnologia."
              Return .F.
           EndIf

           oSeq:=oScript:_PRINCIPAL

           IF Type("oSeq:_ERROR:TEXT") == "C"
	              TecMSGINFO(STR0077+Alltrim(oSeq:_ERROR:TEXT)) //STR0077 "Problemas com os parametros: "
              eMens+=STR0077+Alltrim(oSeq:_ERROR:TEXT)+CHR(13)+CHR(10)
              Return .F.
           EndIf

           IF Type("oSeq:_ERROR[1]:TEXT") == "C"
              TecMSGINFO(STR0077+Alltrim(oSeq:_ERROR[1]:TEXT))
              eMens+=STR0077+Alltrim(oSeq:_ERROR[1]:TEXT)+CHR(13)+CHR(10)
              Return .F.
           EndIf	             
           
	       //JWJ 04/01/2007
	       IF Type("oScript:_PRINCIPAL:_DETALHES") == "U" 
	          IF Type("oScript:_PRINCIPAL:_AVISO") == "O" 
	             TecMSGINFO(STR0078 + oScript:_PRINCIPAL:_AVISO:TEXT) //STR0078 "Aviso recebido do servidor: "
                 eMens+=STR0078 + oScript:_PRINCIPAL:_AVISO:TEXT+CHR(13)+CHR(10)
	          ELSE
	             TecMSGINFO(STR0079) //STR0079 "Erro no serviço. Por favor verifique se o serviço esta online"
                 eMens+=STR0079+CHR(13)+CHR(10)
              Endif
              Return .F.
	       Endif
           
	       aSequencia:=oScript:_PRINCIPAL:_DETALHES:_SEQUENCIA 

           IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"ANTES_GRAVAR_MASTER"),)
           nContBloco++ 
           
           If ValType(aSequencia) ="A"              
              tamanho:=  Len(aSequencia)
           else                       
              tamanho:=1
           endif   

           cTotal  :=" / "+ALLTRIM( tamanho ) + " - Bloco: "+ STR(nContBloco,3)+" /"+STR(nTotal/nBloco,3)
           //cTotal  :=" / "+ALLTRIM( STR(Len(aSequencia),6) ) + " - Bloco: "+ STR(nContBloco,3)+" /"+STR(nTotal/nBloco,3) //msv 27/03/2006

           ConOut(STR0080+SUBSTR(cTotal,4)) //STR0080 "Processando XML: "
           nGravados:=1

           For S := 1 To tamanho //Len(aSequencia)//msv 27/03/2006

              IF !lSchedule
              oDlgProc:SetText(STR0080+ALLTRIM(STR(nGravados,6))+cTotal)
              ENDIF
              nGravados++

              If ValType(aSequencia) ="A"
                 oSeq   :=aSequencia[S]
              else
                oSeq   :=aSequencia
              endif
              cCodNcm:=oSeq:_COD_NCM:TEXT

              IF Type("oSeq:_ERROR:TEXT") = "C"
	 		     eMens+=STR0052 + AllTrim(cCodNCM) + " - "+oSeq:_ERROR:TEXT  + chr(13) + chr(10)
	             nMal++
                 LOOP
	          ENDIF

              cEXNCM := STRZERO(VAL(oSeq:_SEQ_EX:TEXT),3)
              cEXNCM := If(AllTrim(cEXNCM) # "000",cEXNCM,"")

              lInclui := !SYD->(DBSeek(cFilSYD + AvKey(cCodNcm,"YD_TEC") + cEXNCM ) )

              If lIncluiNCM .OR. !lInclui

                 SYD->(RecLock("SYD",lInclui))

                 //Se a configuraçao decimal for ponto, transformar "," em "."
   	             cII :=StrTran(oSeq:_ALIQUOTA_II:TEXT ,",",".")
   	             cIPI:=StrTran(oSeq:_ALIQUOTA_IPI:TEXT,",",".")
                 IF lInclui
     		        SYD->YD_FILIAL:= cFilSYD
     		        SYD->YD_TEC   := cCodNcm
                 ENDIF
	             SYD->YD_PER_II  := Val(cII)
			     SYD->YD_PER_IPI := Val(cIPI)
			     SYD->YD_EX_NCM  := cEXNCM
                 IF lCposLog //AWR - 06/02/2006
                    SYD->YD_GRVUSER:="Easy Legis-"+SubStr(cUsuario,7,15)
                    SYD->YD_GRVDATA:=dDataBase
                    SYD->YD_GRVHORA:=TIME()
                 ENDIF
			     IF lGravaDes
			        IF !EMPTY(oSeq:_dsc_ncm_compl:TEXT)
                        cDescr:=oSeq:_dsc_ncm_compl:TEXT                    
                 /* ELSEIF !EMPTY(oSeq:_dsc_ncm:TEXT)
                       cDescr:=oSeq:_dsc_ncm:TEXT
    	               IF (nPos:=At("-",cDescr)) # 0
                          cDescr:=SubStr(cDescr,nPos+1,Len(cDescr))
   			              IF (nPos:=At("-",cDescr)) # 0
                             cDescr:=SubStr(cDescr,nPos+1,Len(cDescr))
                          ENDIF
                       ENDIF*/
                    ENDIF
                    SYD->YD_DESC_P := cDescr
			     ENDIF
                 IF lAmparoDes
                    IF !EMPTY(oSeq:_amparo_aliq_ii:TEXT)
                       //SYD->YD_MOT_II := oSeq:_amparo_aliq_ii:TEXT
                       MSMM(If(EMPTY(SYD->YD_MOT_II) ,,SYD->YD_MOT_II ),nTamII ,,oSeq:_amparo_aliq_ii:TEXT ,1,,,"SYD","YD_MOT_II")
                    ENDIF
                    IF !EMPTY(oSeq:_amparo_aliq_ipi:TEXT)
                       //SYD->YD_MOT_IPI := oSeq:_amparo_aliq_ipi:TEXT
                       MSMM(If(EMPTY(SYD->YD_MOT_IPI),,SYD->YD_MOT_IPI),nTamIPI,,oSeq:_amparo_aliq_ipi:TEXT,1,,,"SYD","YD_MOT_IPI")
                    ENDIF
			     ENDIF

                 IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_ATU_MASTESAF"),)

		  	     SYD->(MsUnlock())
			     nBein++

		      Else

	 		     eMens+="NCM/EX: " + AllTrim(cCodNCM) +"/"+cEXNCM+STR0081  + chr(13) + chr(10) //STR0081 " : nao Encontrada na Tabela de NCM do Easy"
	             nMal++

              Endif

   	          IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"DEPOIS_GRAVAR_MASTER"),)

           Next S 
           
           cNCM  :=""
           nCount:=0

           SYD->(DBGOTO(nRecno))
        ENDIF  

        IF (cAlias)->(Eof())
           EXIT
        ENDIF

        (cAlias)->(DBSkip())

     ENDDO

     IF FILE(cArquivoXML)
        FERASE(cArquivoXML)
     ENDIF     
      
  EndCase

IF Aliq->(EasyRecCount("Aliq")) = 0//AWR - 14/01/2006
   nProcessadas:=nTotal
ELSE
   nProcessadas:=Aliq->(EasyRecCount("Aliq"))
ENDIF

sAvisos+=STR0082 + AllTrim(Str(nProcessadas)) + chr(13) + chr(10) //STR0082 "Quantidade de NCM Processadas: "
sAvisos+=STR0083 + AllTrim(Str(nBein)) + chr(13) + chr(10) //STR0083 "Quantidade de NCM Recuperadas com Sucesso: "
sAvisos+=STR0084 + AllTrim(Str(nMal)) + chr(13) + chr(10) //STR0084 "Quantidade de NCM Nao Recuperadas: "
sAvisos+=STR0085+cTime+CHR(13)+CHR(10) //STR0085 "Hora Inicial: "
sAvisos+=STR0086+Time()+CHR(13)+CHR(10) //STR0086 "Hora Final: "

if lSchedule

   If !Empty(eMens)
      eMens:=STR0087 +chr(13)+Chr(10)+chr(13)+Chr(10) + eMens + chr(13) + chr(10) //STR0087 "Relatorio de Erros:"
   Endif
   If !Empty(sAvisos)
      ConOut(sAvisos)  
      eMens+=STR0088 + chr(13) + chr(10) + chr(13) + chr(10) + sAvisos //STR0088 "Avisos:"
   Endif
   nCod:=EasyCreateFile("STATUS_NCMS.TXT")
   IF nCod <> -1
      FWrite(nCod,eMens)
      FClose(nCod)
   ENDIF

ENDIF

RETURN lAtualizou

*-------------------------------------------------------------------------------------*
// Descricao: Obter Configuracao do Path e Nome do Export.exe
// Param    : cMaquina = Maquina pra obter configuracao
//          : nOpRad   = Programa a usar para recuperaçao (1=Aduaneiras 2=Infoconsult)
// Retorna  : True = Ok,  False = Nao Definido
*-------------------------------------------------------------------------------------*
STATIC FUNCTION EasyValMaq(cMaquina,nOpRad)
PRIVATE lRet:=.T.

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"VALIDACAO_MAQUINA"),)

Do Case

  Case nOpRad==1
       //Recuperar Path do directorio TECWIN para Maquina
       SX5->(DBSetOrder(1))
       If SX5->(DBSeek(xFilial()+"CE"+AllTrim(cMaquina) + "TECW"))
          cDirExport:=AllTrim(SX5->X5_DESCRI)
          If Empty(cDirExport)
             lRet:=.F.
             TecMSGINFO(STR0089+AllTrim(cMaquina)+"TECW)",STR0047) //STR0089 "Não esta definido o diretorio de instalação do EXPORT.EXE (SX5->X5_DESCRI, CE"
          Endif
         else
          lRet:=.F.
          TecMSGINFO(STR0090+AllTrim(cMaquina)+"TECW)",STR0047) //STR0090 "Nao esta definida a Variavel de definição do diretorio de instalação do EXPORT.EXE (SX5->CE"
       Endif
  	 If Empty(cUsr)
  	    TecMSGINFO(STR0091,STR0047) //STR0091 "Usuario Login Export.exe nao definido (MV_ET_USER)"
  	    Return.F.
  	 Endif
  	 If Empty(cPas)
  	    TecMSGINFO(STR0092,STR0047) //STR0092 "Password Login Export.exe nao definido (MV_ET_PASS)"
  	    Return.F.
  	 Endif

  Case nOpRad==2
       //Recuperar Path do directorio TEC da Infoconsult para Maquina
       SX5->(DBSetOrder(1))
       If SX5->(DBSeek(xFilial()+"CE"+AllTrim(cMaquina) + "INFO"))
          cDirExport:=AllTrim(SX5->X5_DESCRI)
          If Empty(cDirExport)
             lRet:=.F.
             TecMSGINFO(STR0093+AllTrim(cMaquina)+"INFO)",STR0047) //STR0093 "Não esta definido o diretorio de instalação do CONVERSOR.EXE (SX5->X5_DESCRI, CE"
          Endif
       else
          lRet:=.F.
          TecMSGINFO(STR0094+AllTrim(cMaquina)+"INFO)",STR0047) //STR0094 "Nao esta definida a Variavel de definição do diretorio de instalação do CONVERSOR.EXE (SX5->CE"
       Endif
     /* AAF - Retirada as validações de configuração do servidor TEC da infoconsult.
  	 If Empty(cIP)
  	    eMens+=STR0057 + chr(13) + chr(10)
     	    TecMSGINFO(STR0057,STR0047)
          Return.F.
    	 Endif
  	 If Empty(cPort)
  	    eMens+=STR0058 + chr(13) + chr(10)
     	    TecMSGINFO(STR0058,STR0047)
  	    Return.F.
  	 Endif
  	 */
  Case nOpRad==3

       SX5->(DBSetOrder(1))
       If SX5->(DBSeek(xFilial()+"CE"+AllTrim(cMaquina) + "MSIU")) .OR. EMPTY(AllTrim(SX5->X5_DESCRI)) //MSV 06/03/2006
          cIdUsu:=AllTrim(SX5->X5_DESCRI)
          If Empty(cIdUsu)
             lRet:=.F.
             TecMSGINFO(STR0095+AllTrim(cMaquina)+"MSIU)",STR0047) //MSV 06/03/2006 STR0095 "Nao esta definido o Identificador do usuário do Easy Legis dessa maquina (SX5->X5_DESCRI, CE"
          Endif
       Endif

       If SX5->(DBSeek(xFilial()+"CE"+AllTrim(cMaquina) + "MSCL")) .OR. EMPTY(AllTrim(SX5->X5_DESCRI)) //MSV 06/03/2006
          cCliMS:=AllTrim(SX5->X5_DESCRI)
          If Empty(cCliMS)
             lRet:=.F.
             TecMSGINFO(STR0096+AllTrim(cMaquina)+"MSCL)",STR0047) //MSV 06/03/2006 STR0096 "Nao esta definido o código do cliente do Easy Legis dessa maquina (SX5->X5_DESCRI, CE" 
          Endif
       Endif

       If SX5->(DBSeek(xFilial()+"CE"+AllTrim(cMaquina) + "MSAU")) .OR. EMPTY(AllTrim(SX5->X5_DESCRI))
          cStrAutMS:=AllTrim(SX5->X5_DESCRI)
          If Empty(cStrAutMS)
             lRet:=.F.
             TecMSGINFO(STR0097+AllTrim(cMaquina)+"MSAU)",STR0047) //STR0097 "Nao esta definido a senha do usuario do Easy Legis dessa maquina (SX5->X5_DESCRI, CE"
          Endif
       Endif
        
       If SX5->(DBSeek(xFilial()+"CE"+AllTrim(cMaquina) + "MSTP")) .OR. EMPTY(AllTrim(SX5->X5_DESCRI))
          cTipoMS:=AllTrim(SX5->X5_DESCRI)
          If Empty(cTipoMS)
            lRet:=.F.
            TecMSGINFO(STR0098+AllTrim(cMaquina)+"MSTP)",STR0047) //STR0098 "Nao esta definido o tipo do usuario do Easy Legis dessa maquina (SX5->X5_DESCRI, CE"
          Endif
       Endif

       If SX5->(DBSeek(xFilial()+"CE"+AllTrim(cMaquina) + "MSUP"))
          cUserProxy:=AllTrim(SX5->X5_DESCRI)
       Endif

       If SX5->(DBSeek(xFilial()+"CE"+AllTrim(cMaquina) + "MSSP"))
          cSenhaProxy:=AllTrim(SX5->X5_DESCRI)
       Endif  	 
  	 
  EndCase

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"DEP_VALIDACAO_MAQUINA"),)

Return lRet

*------------------------------------------------------------*
// Descricao:  Ler Arquivo LOG devolvido pelo Export.exe
// Param  : nomfile = Path e Nome do arquivo log
// Retorna: Codigo do erro Log
*------------------------------------------------------------*
STATIC FUNCTION EXPReadLog(nomfile)
PRIVATE cLinha:="15"			//Log nao encontrado

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LER_ARQUIVO_LOG"),)    

FT_FUSE(NomFile)
FT_FGOTOP()  
If !FT_FEOF()
   cLinha:=AllTrim(FT_FREADLN())
Endif   
FT_FUSE()                 

If cLinha=""
   cLinha:="15"
Endif

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"FIM_LER_ARQUIVO_LOG"),)    

Return cLinha

*---------------------------------------------------------------------* 
// Descricao: Ler Linha Devolvida pelo Export.exe com seq 001        
// Param: NomFile = Path e Nome do arquivo saida
// Retorna: array com conteudo da linha
//          [1] = Codigo NCM
//          [2] = Sequencia do NCM
//          [3] = Descricao NCM
//          [4] = Aliq. II
//          [5] = Aliq. IPI
//          [6] = Aliq. PIS/Pasep
//          [7] = Aliq. Cofins
//          [8] = Tipo de Recolhimento do ICMS
*---------------------------------------------------------------------* 
STATIC FUNCTION EXPReadNCM(nomfile)
Local cLinha,cLinhaAtu
Local x
PRIVATE aNCM1:={}

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"ANTES_LEIT_NCM"),)    

FT_FUSE(NomFile)
FT_FGOTOP()  

cLinha:= ""
//TRP-13/06/07
Do While !FT_FEOF() 
   cLinhaAtu := AllTrim(FT_FREADLN())
   cLinha+=cLinhaAtu
   FT_FSkip()
Enddo 
If !Empty(cLinha)
   aNCM1:=aSplit(cLinha,";#")

   //Transformar a Ponto Decimal e tirar #  - CDS 21/9/05
   IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_LE_NCM_ANT"),)    
   For x:=1 to len(aNCM1)
      aNCM1[x]:=StrTran(aNCM1[x],"#","")
      If x>=4
         //Verificar se a config. decimal for "." ou ","
         If Val("12,34")<>12.34
            aNCM1[x]:=StrTran(aNCM1[x],",",".")			
         Endif   
         If !IsDigit(aNCM1[x])			//CDS 21/9/05
            aNCM1[x]:="0"
         Endif
      Endif  
   Next

   IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"LOOP_LE_TXT"),)    

   //FT_FSkip()
Endif  
  
FT_FUSE("c:\dummy.doc") 		//Asegurar Fechamento. O FT_FUSE() simplesmente nao fecha o arquivo ate tentar abrir outro.
FT_FUSE()

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"FIN_LEIT_NCM"),)    
Return aNCM1


*-----------------------------------------------*
STATIC FUNCTION EICWEBGetDesc(mDescGet,cAviso)          
// Descri.: Mostrar tela com mensagem de erro ou Aviso
// Param.: mDescGet = String com Descrições.
// Retorna: nao
// Autor: CDS - 22/11/04
*-----------------------------------------------*
Local oDLG                  
Private lRet:=.T.

 IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"INI_TELA_ERRO"),)    

 If !Empty(mDescGet)
    mDescGet:=STR0087 +chr(13)+Chr(10)+chr(13)+Chr(10) + mDescGet + chr(13) + chr(10)
    lRet:=.F.
 Endif

 If !Empty(cAviso)
    mDescGet+=STR0088 + chr(13) + chr(10) + chr(13) + chr(10) + cAviso
 Endif

 DEFINE FONT oFont NAME "Courier New" SIZE 0,15
 DEFINE MSDIALOG oDlg TITLE STR0047 From 15,00 To 34,52 OF oMainWnd
 
 oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 24/11/2015
 oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   
 IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"DENTRO_TELA_ERRO"),)    
 oDLG:SetFont(oFont)
 @8,2 GET mDescGet MEMO HSCROLL SIZE 203,100 OF oPanel PIXEL READONLY
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()}) CENTER

 IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"FIM_TELA_ERRO"),)    

RETURN lRet

*--------------------------------------------------------------------------*
Static Function EasyVNCM(cNCMIni,cNCMFim)
*--------------------------------------------------------------------------*
PRIVATE pcNCMIni:=cNCMINI, pCNCMFim:=cNCMFim

If !Empty(cNCMIni).and.!Empty(cNCMFim)
   If AllTrim(cNCMIni)>AllTrim(cNCMFim)
      TecMSGINFO(STR0099,STR0047) //STR0099 "N.C.M. Desde e maior que N.C.M Ate"
      Return .F.
   Endif
Endif

IF(EasyEntryPoint("EASYTEC"),Execblock("EASYTEC",.F.,.F.,"VALIDA_NCM_INIFIM"),)    

Return.T.

STATIC FUNCTION aSplit(pCad,cSplit)                              
// Descricao: Cria un vetor desde um string com separadores
// Parametr : pCad = String a converter a vetor
//            cSplit = Carater que se usara pra procurar no 
//                     string que serve como separador. (Default = Space)            
// Retorna  : um vetor com n elementos
// Autor    : Johann - 05/05/2005
// Revisão  : Saimon Vinicius Gava - SVG - 11/11/2010
*------------------------------------------------------------------*
Local aRet1:={}, cAux:= ""
//Local bEval

If Empty(pCad).or.pCad==NIL
   Return aRet1
Endif          
If Empty(cSplit)
   cSplit:=" "
Endif

pCad:=StrTran(pCad,"!","") // DFS - Criado para retirar as exclamações
pCad:=StrTran(pCad,ASPAS,"")
// SVG - 11/11/2010 - Nopado
/* 
pCad:=StrTran(pCad,ASPAS_SIMPLES,"")                                   
pCad:=StrTran(pCad,cSplit,ASPAS + "),AADD(ARET1," + ASPAS)
pCad:="AADD(ARET1," + ASPAS + pCad + ASPAS + ")"*/
 
/*bEval := &("{||" + pCad + "}")
EVAL(bEval)           
*/ 
// SVG


// SVG - 11/11/2010 -
While At(cSplit , pCad) <> 0
   cAux:= substr( pcad ,1,  at( cSplit , pcad )-1 ) 
   pCad:= SubStr( pCad , Len(cAux)+2, Len(pCad))
   AADD(ARET1,cAux) 
   if At(cSplit , pCad) == 0
      AADD(ARET1,pCad)
   EndIf
EndDo 
// SVG
 
Return aRet1
*--------------------------------------------------------------------------------------------*
Function ConverteXML(cRetornoXML)//AWR - 13/01/2006 - Tira os caracteres "estranos"
*--------------------------------------------------------------------------------------------*
cRetornoXML:=StrTran(cRetornoXML,"ISO-8859-1","UTF-8")
cRetornoXML:=StrTran(cRetornoXML,"á","a")
cRetornoXML:=StrTran(cRetornoXML,"Á","A")
cRetornoXML:=StrTran(cRetornoXML,"à","a")
cRetornoXML:=StrTran(cRetornoXML,"À","A")
cRetornoXML:=StrTran(cRetornoXML,"ã","a")
cRetornoXML:=StrTran(cRetornoXML,"Ã","A")
cRetornoXML:=StrTran(cRetornoXML,"â","a")
cRetornoXML:=StrTran(cRetornoXML,"Â","A")
cRetornoXML:=StrTran(cRetornoXML,"ä","a")
cRetornoXML:=StrTran(cRetornoXML,"Ä","A")
cRetornoXML:=StrTran(cRetornoXML,"é","e")
cRetornoXML:=StrTran(cRetornoXML,"É","E")
cRetornoXML:=StrTran(cRetornoXML,"ë","e")
cRetornoXML:=StrTran(cRetornoXML,"Ë","E")
cRetornoXML:=StrTran(cRetornoXML,"ê","e")
cRetornoXML:=StrTran(cRetornoXML,"Ê","E")
cRetornoXML:=StrTran(cRetornoXML,"í","i")
cRetornoXML:=StrTran(cRetornoXML,"Í","I")
cRetornoXML:=StrTran(cRetornoXML,"ï","i")
cRetornoXML:=StrTran(cRetornoXML,"Ï","I")
cRetornoXML:=StrTran(cRetornoXML,"î","i")
cRetornoXML:=StrTran(cRetornoXML,"Î","I")
cRetornoXML:=StrTran(cRetornoXML,"ý","y")
cRetornoXML:=StrTran(cRetornoXML,"Ý","y")
cRetornoXML:=StrTran(cRetornoXML,"ÿ","y")
cRetornoXML:=StrTran(cRetornoXML,"ó","o")
cRetornoXML:=StrTran(cRetornoXML,"Ó","O")
cRetornoXML:=StrTran(cRetornoXML,"õ","o")
cRetornoXML:=StrTran(cRetornoXML,"Õ","O")
cRetornoXML:=StrTran(cRetornoXML,"ö","o")
cRetornoXML:=StrTran(cRetornoXML,"Ö","O")
cRetornoXML:=StrTran(cRetornoXML,"ô","o")
cRetornoXML:=StrTran(cRetornoXML,"Ô","O")
cRetornoXML:=StrTran(cRetornoXML,"ò","o")
cRetornoXML:=StrTran(cRetornoXML,"Ò","O")
cRetornoXML:=StrTran(cRetornoXML,"ú","u")
cRetornoXML:=StrTran(cRetornoXML,"Ú","U")
cRetornoXML:=StrTran(cRetornoXML,"ù","u")
cRetornoXML:=StrTran(cRetornoXML,"Ù","U")
cRetornoXML:=StrTran(cRetornoXML,"ü","u")
cRetornoXML:=StrTran(cRetornoXML,"Ü","U")
cRetornoXML:=StrTran(cRetornoXML,"ç","c")
cRetornoXML:=StrTran(cRetornoXML,"Ç","C")
cRetornoXML:=StrTran(cRetornoXML,"º","o")
cRetornoXML:=StrTran(cRetornoXML,"°","o")
cRetornoXML:=StrTran(cRetornoXML,"ª","a")
cRetornoXML:=StrTran(cRetornoXML,"ñ","n")
cRetornoXML:=StrTran(cRetornoXML,"Ñ","N")
cRetornoXML:=StrTran(cRetornoXML,"²","2")
cRetornoXML:=StrTran(cRetornoXML,"³","3")
cRetornoXML:=StrTran(cRetornoXML,"’","'")
cRetornoXML:=StrTran(cRetornoXML,"§","S")
cRetornoXML:=StrTran(cRetornoXML,"±","+")
cRetornoXML:=StrTran(cRetornoXML,"­","-")
cRetornoXML:=StrTran(cRetornoXML,"´","'")
cRetornoXML:=StrTran(cRetornoXML,"o","o")
cRetornoXML:=StrTran(cRetornoXML,"µ","u")
cRetornoXML:=StrTran(cRetornoXML,"¼","1/4")
cRetornoXML:=StrTran(cRetornoXML,"½","1/2")
cRetornoXML:=StrTran(cRetornoXML,"¾","3/4")
cRetornoXML:=StrTran(cRetornoXML,"&","e") 
cRetornoXML:=StrTran(cRetornoXML,"þ","b")
cRetornoXML:=StrTran(cRetornoXML,"¿",".")
cRetornoXML:=StrTran(cRetornoXML,"ø","o")
cRetornoXML:=StrTran(cRetornoXML,"Ø","O")
cRetornoXML:=StrTran(cRetornoXML,"*",".")
Return cRetornoXML
*------------------------------------------------------------*
STATIC FUNCTION GerTCQuery(cQuery,cAlias)//AWR - 16/01/2006
*------------------------------------------------------------*
cQuery:=ChangeQuery(cQuery)    

nCod:=EasyCreateFile("cQuery.TXT")
IF nCod # -1
   FWRITE(nCod,cQuery)
   Fclose(nCod)
ENDIF

IF SELECT(cAlias) # 0
   (cAlias)->(DBCLOSEAREA())
ENDIF

TcQuery cQuery ALIAS (cAlias) NEW

IF !USED()
   TecMSGINFO(STR0100+ALLTRIM(cQuery)+STR0101) //STR0100 "Nao foi possivel executar a QUERY : " STR0101 ", Verificar Arquivo: cQuery.TXT"
   RETURN .F.
ENDIF

RETURN .T.
*-----------------------------*
//[ONSTART]
//Jobs=SchedJob
//[SchedJob]
//Main=U_TECAgenda()
//Environment=
USER Function TECAgenda()//Chamada do INI ou do Remote
*-----------------------------*
OpenSM0()    

WFSTART( { SM0->M0_CODIGO,SM0->M0_CODFIL } ) //empresa e filial utilizada no programa de agendamento  

SM0->(DBCLOSEAREA())

RETURN .T.

*-----------------------------------------------------------------------------*
Function TecPreAmb(aEmpcFil,nOpRad,cMaquina)//Chamada do SXM // AWR - 13/01/2006
*-----------------------------------------------------------------------------*
DEFAULT aEmpcFil := {"01","01",3,"A1"}
cMODULO := "EIC"
nOpRad  := aEmpcFil[3]
cMaquina:= aEmpcFil[4]

PREPARE ENVIRONMENT EMPRESA aEmpcFil[1] FILIAL aEmpcFil[2] MODULO cMODULO TABLES "SX5","SYD","SYP"

E_INIT(.T.) //para criação de variáveis

If EMPTY(cUSUARIO)
   cUSUARIO := SPACE(06)+"JOB            "
EndIf         

RETURN .T.

*-----------------------------------------------------------------------------*
Function TecMSGINFO(cMen,cTit)// AWR - 13/01/2006
*-----------------------------------------------------------------------------*
IF lSchedule
   ConOut(cMen)
ELSE
   MSGINFO(cMen,cTit)
ENDIF
RETURN .T.

*-----------------------------------------------------------------------------*
Function TecProcessa(bExe,cTit,cText,lEnd)// AWR - 13/01/2006
*-----------------------------------------------------------------------------*
Default cText := ""
Default lEnd := .F.

IF lSchedule
   ConOut(cTit)
   EVAL(bExe)
ELSE
   Processa(bExe,cTit,cText,lEnd)
ENDIF
RETURN .T.

*-----------------------------------------------------------------------------*
Function TecProcRegua(nTot)// AWR - 13/01/2006
*-----------------------------------------------------------------------------*
IF lSchedule
   ConOut(STR0102+ALLTRIM(STR(nTot,10))) //STR0102 "Numero de registros a serem processandos: "
ELSE
   ProcRegua(nTot)
ENDIF
RETURN .T.

*-----------------------------------------------------------------------------*
Function TecIncProc(cTit)// AWR - 13/01/2006
*-----------------------------------------------------------------------------*
IF !lSchedule
   IncProc(cTit)
ENDIF
RETURN .T.

*-----------------------------------------------------------------------------*
Function TecParametros(nOpRad)// AWR - 13/01/2006
*-----------------------------------------------------------------------------*
LOCAL oDlgP, lTemCampos:=SYD->(FIELDPOS("YD_MOT_II")) # 0 .AND. SYD->(FIELDPOS("YD_MOT_IPI")) # 0
LOCAL cTit1:=STR0103 //STR0103 "Atualizar descricoes das NCM´s do Easy Legis"

//** AAF 24/01/07 - Corrigida mensagem do parâmetro de inclusão de EX's do Easy Legis no Easy, devido a ambiguidade na mensagem.
//LOCAL cTit2:="Incluir NCM´s / EX´s do Easy Legis nao cadastradas no Easy"
LOCAL cTit2:=STR0104 //STR0104 "Incluir EX´s do Easy Legis nao cadastradas no Easy"

LOCAL cTit3:=STR0105 //STR0105 "Atualizar ampararos das aliquotas de II e IPI do Easy Legis"
LOCAL lGrava:=.F.

IF nOpRad # 3 
   MSGSTOP(STR0106) //STR0106 "Programa Easy Legis nao selecionado."
   Return .F.
ENDIF
lAmparoDes :=EasyGParam("MV_GRVAMPA",,.F.) .AND. lTemCampos
lIncluiNCM :=EasyGParam("MV_INCLNCM",,.F.)//Decide se vai incluir a NCM,s nao encontradas na tabela do Easy
lGravaDes  :=EasyGParam("MV_GRVDNCM",,.F.)
DEFINE MSDIALOG oDlgP FROM  0,0 TO 10,50 TITLE STR0022 OF oMainWnd

   @ 04,06 TO 45,187 OF oDlgP PIXEL  
   @ 10,10 CHECKBOX lGravaDes  PROMPT cTit1 SIZE 165,10 OF oDlgP PIXEL
   @ 20,10 CHECKBOX lIncluiNCM PROMPT cTit2 SIZE 165,10 OF oDlgP PIXEL
   @ 30,10 CHECKBOX lAmparoDes PROMPT cTit3 SIZE 165,10 OF oDlgP PIXEL WHEN lTemCampos

   DEFINE SBUTTON FROM 55,055 TYPE 1 ACTION ( lGrava:=.T.,oDlgP:End() ) ENABLE // OK
   DEFINE SBUTTON FROM 55,105 TYPE 2 ACTION ( lGrava:=.F.,oDlgP:End() ) ENABLE // CANCEL

ACTIVATE MSDIALOG oDlgP CENTERED

IF lGrava
   SetMV("MV_GRVDNCM",lGravaDes)
   SetMV("MV_INCLNCM",lIncluiNCM)
   SetMV("MV_GRVAMPA",lAmparoDes)
ENDIF

RETURN .T.


*---------------------------------------------------------------------* 
// Funcao   : CONReadNCM()
// Data     : 30/08/2007
// Autor    : Pedro Baroni
// Descricao: Ler Linhas Devolvidas pelo Conversor.exe e gravar no arquivo DBF
// Param: cFileName = Path e Nome do arquivo saida
// Retorna: Nulo
//       "Formato do Array de NCM"
//          [01] = Codigo NCM
//          [02] = Sequencia do NCM
//          [03] = EX-NCM
//          [04] = Descricao NCM
//          [05] = Aliq. II
//          [06] = Aliq. IPI
//          [07] = Aliq. PIS/Pasep
//          [08] = Aliq. Cofins
//          [09] = Tipo de Recolhimento do ICMS
//          [10] = Unidade de Medida
//          [11] = N.V.E.
//          [12] = Tratamento Adm.
//Revisão: Thiago Rinaldi Pinto em 26/03/08
*---------------------------------------------------------------------* 
Static Function CONReadNCM(cFileName)

 Local cLinha     := ""   ,;
       cLote      := ""   ,;
       aSeparator := {";", CHR(9), "|","!"},;
       cTotal     := ""   ,;
       nQuebra    := 0    ,;
       nInd       := 1    ,;
       nJnd       := 1    ,; // SVG - 07/07/2010 - Utilizado no For para exclusão de separadores repetidos
       nHandle    := 0    ,;
       nCountNCM  := 0    ,;
       nSeparator := 0    ,;
       aNCM := aPosicoes   := {}   
       
  Local lAchou:= .F.
  Local nFim:= 0
  Local lTemEX := .T.  //TRP - 26/04/2010 - Flag para verificar se o arquivo .txt possui EXNCM 
  Local nPos    
  Local z, nPosDesc // ACB - 10/02/2011 - Variaveis para tratamento de acerto do array aNCM
  Private cCabecalho := "" // SVG - 21/05/2010 -
   
   // Abre arquivo para Leitura das Alíquotas
   nHandle := EasyOpenFile(cFileName,FO_READ)
   If nHandle == -1
      TecMsgInfo(STR0108+cFileName+".")  // "Não foi possível a leitura do arquivo " ###
      Return NIL
   EndIf

   //** Calcula a quantidade de Separadores de acordo com o cabeçalho
   cLote += FREADSTR(nHandle,4096)   // Lê um lote de caracteres
   nQuebra := AT(ENTER,cLote)        // Calcula posição de quebra de Linha
   
   If !("EXNCM" $ cLote)
      lTemEX:= .F.
   Endif
   
   FOR nInd:=1 TO LEN(aSeparator)
	   cSeparator := aSeparator[nInd]
   
	   nSeparator := CountChar( SubStr(cLote,1,nQuebra-1), cSeparator )
		
	   IF nSeparator > 0
          FOR nJnd:=1 TO LEN(aSeparator) // SVG - 07/07/2010 - Retira os separadores a mais quando houver.
             If aSeparator[nJnd] <> cSeparator
                clote:=STRTran(clote,aSeparator[nJnd],"")
             EndIf
          Next               
          nQuebra := AT(ENTER,cLote)
		  Exit
	   ENDIF
   NEXT
   IF nSeparator == 0
      TecMsgInfo(STR0108+cFileName+". Separador não identificado.")  // "Não foi possível a leitura do arquivo " ###
      Return NIL
   EndIf
   cCabecalho:= substr(clote,1,nquebra) //SVG - 21/05/2010 -
   aPosicoes := ASplit(cCabecalho,cSeparator) // SVG - 07/07/2010 - 
   
   cLote := SubStr(cLote,nQuebra+2)  // Elimina linha de cabeçalho
   
   Aliq->( DBSetOrder(1) )
   Aliq->( DBGoTop() )

   TecProcRegua( Aliq->( EasyRecCount("Aliq") ) )
   cTotal := AllTrim(Str(Aliq->( EasyRecCount("Aliq") )))
   nCountNCM := 0
   
   
   Do While .T.

      If AT(ENTER,cLote) == 0
         cLote += FREADSTR(nHandle,4096)
      EndIf
         
      If Empty(cLote)
         Exit
      Endif
         
      // Verifica a posição da quebra de linha
      nQuebra := AT(ENTER,cLote)
         
      If nQuebra == 0
         nFim := AT(CHR(0),cLote)
         If nFim > 0
            lAchou:= .T.
         Else
            Loop
         Endif
      EndIf
            
      // Separa uma linha para verificação
      If nQuebra > 0 
         cLinha := SubStr(cLote,1,nQuebra-1)
      Else
         cLinha := cLote
      Endif
         
      If Empty(cLinha)  // GFP - 25/11/2013
         Exit
      EndIf  

      // Distribui as informações da NCM em um array
      aNCM := ASplit(cLinha,cSeparator)    
      
      //Verifica se tem separador na descrição da NCM -- MPG - 05/03/2018
      If ASCAN(aPosicoes, "DESCNCM") > 0
        While Len(aNCM) > Len(aPosicoes)
          cLinha := StrTran( cLinha, cSeparator , "" , ASCAN(aPosicoes, "DESCNCM") , 1 )
          aNCM := ASplit(cLinha,cSeparator)
        EndDo
      EndIf

      // SVG - 07/07/2010 - 
      If ASCAN(aPosicoes, "EXNCM") > 0      
         cEXNCM  := aNCM[ASCAN(aPosicoes, "EXNCM")]  //SVG 29/09/08 
      Else
         cEXNCM  := ""
      EndIf
      // SVG - 07/07/2010 - 
      If ASCAN(aPosicoes, "CODNCM") > 0      
         cCodNCM := aNCM[ASCAN(aPosicoes, "CODNCM")]
      Else
         cCodNCM := ""
      EndIf

      TecIncProc(STR0109+cCodNCM+" - "+AllTrim(Str(++nCountNCM))+" /  "+cTotal)  // "Lendo NCM " ###
         
      // Caso nao seja a Linha referente a NCM
      Aliq->(DbSetOrder(1))
      If !Aliq->(DBSeek(IncSpace(cCodNCM,10,.F.)+If(!Empty(cExNCM),AvKey(AllTrim(cExNCM),"YD_EX_NCM"),"")))  // GFP - 25/03/2014
         If nQuebra > 0
            cLote := SubStr(cLote,nQuebra+2)
            Loop
         Else
            Exit
         Endif
      EndIf  
      
      //ACB - 10/02/2011 - Tratamento que valida o aNCM verificando se a estrutura esta correta, senão é preenchida a estrutura para correção do array
      If Len(aNCM) < Len(aPosicoes)   
         For z := 1 To Len(aPosicoes) - Len(aNCM)
	         aAdd(aNCM,"")
         Next z
      ElseIf Len(aNCM) > Len(aPosicoes)   
         nPosDesc := ASCAN(aPosicoes, "DESCNCM")
         
         For z := 1 To Len(aNCM) - Len(aPosicoes)
            aNCM[nPosDesc] += cSeparator+aNCM[Len(aPosicoes)+z]
         Next z
         
         ASize(aNCM,Len(aPosicoes))
      EndIf
      /*  ACB - 10/02/2011 - NOPADO para que passe a valer o tratamento feito acima.
      // Tratamento para quando o caracter de separação estiver na descrição na Descrição da NCM
      Do While Len(aNCM) > nSeparator+1
         aNCM[4] += cSeparator+aNCM[5]
         For nInd := 5  to  Len(aNCM)-1
            aNCM[nInd] := aNCM[nInd+1]
         Next nInd
         ASize(aNCM,Len(aNCM)-1)
      EndDo*/

      // Verifica EX-NCM
      If !Empty(Aliq->EXNCM)  .And. if(ASCAN(aPosicoes, "EXNCM")<> 0,AllTrim(aNCM[ASCAN(aPosicoes, "EXNCM")]) != AllTrim(Aliq->EXNCM),.F.)  
         If nQuebra > 0
            cLote := SubStr(cLote,nQuebra+2)
            Loop
         Endif
      EndIf
      /* SVG - 23/09/2010 - Comentado devido a verificação lo abaixo, existem casos que as aliquotas podem vir antes da posição 5, 
                            inserida verificação individual para cada aliquota
      //Transforma o Ponto Decimal
      For nInd := 1  to  Len(aNCM)
         If nInd >= 5  .And.  nInd <= 9
         //Verificar se a config. decimal for "." ou ","
            If Val("12,34")<>12.34
               aNCM[nInd] := StrTran(aNCM[nInd],",",".")			
            EndIf
            /*If !IsDigit(aNCM[nInd]) .And. Empty(aNCM[nInd])
               aNCM[nInd] := "0"
            EndIf
         EndIf
      Next nInd
      SVG - 23/09/2010 - */ 
      // SVG - 23/09/2010 -  Inserida verificação individual para cada aliquota
      //Transforma o Ponto Decimal
      If Val("12,34")<>12.34
         //ACB - 08/02/2011 - tratamento para não estoure o array
         If (nPos := ASCAN(aPosicoes,"II")) <> 0//ASCAN(aPosicoes,"II") <> 0
            aNCM[ASCAN(aPosicoes,"II")] := StrTran(aNCM[nPos],",",".")//StrTran(aNCM[ASCAN(aPosicoes,"II")],",",".")
         EndIf
         If (nPos := ASCAN(aPosicoes,"IPI")) <> 0 //ASCAN(aPosicoes,"IPI") <> 0
            aNCM[ASCAN(aPosicoes,"IPI")] := StrTran(aNCM[nPos],",",".")//StrTran(aNCM[ASCAN(aPosicoes,"IPI")],",",".")
         EndIf
         If (nPos := ASCAN(aPosicoes,"PIS")) <> 0//ASCAN(aPosicoes,"PIS") <> 0
            aNCM[ASCAN(aPosicoes,"PIS")] := StrTran(aNCM[nPos],",",".")//StrTran(aNCM[ASCAN(aPosicoes,"PIS")],",",".")
         EndIf
         If (nPos := ASCAN(aPosicoes,"COFINS")) <> 0//ASCAN(aPosicoes,"COFINS") <> 0
            aNCM[ASCAN(aPosicoes,"COFINS")] := StrTran(aNCM[nPos],",",".")//StrTran(aNCM[ASCAN(aPosicoes,"COFINS")],",",".")
         EndIf
      EndIf

      // Grava as alíquotas no DBF  
      //CCH - 09/12/08 - Tratamento inserido para atualizar a base apenas quando a sequência for 001. 
      //Motivo - De acordo com o layout da Infoconsult, as alíquotas são enviadas apenas na sequência 001 da NCM. As demais sequências...
      //não recebem valores. Com isso, sem esta validação, caso a NCM possua mais de uma sequência, as alíquotas serão zeradas incorretamente.
      If /*aNCM[2] == "001" .and.*/ Aliq->RECUP == "N" 
         RecLock("Aliq",.F.)
         
         //DFS - 05/01/2011 - Inclusão de tratamento para verificar se existe informação referente ao II na integração de NCM
         If (nPos := ASCAN(aPosicoes,"II")) <> 0         
            If IsDigit(aNCM[nPos]) // SVG - 10/08/2010 -/*ASCAN(aPosicoes,"II")*/
               Aliq->II := aNCM[nPos] //ASCAN(aPosicoes, "II")
            EndIf
         Endif
         
         //DFS - 05/01/2011 - Inclusão de tratamento para verificar se existe informação referente ao II na integração de NCM
         If (nPos := ASCAN(aPosicoes,"IPI")) <> 0                   
            If IsDigit(aNCM[nPos]) // SVG - 10/08/2010 - ASCAN(aPosicoes, "IPI")
               Aliq->IPI := aNCM[nPos] //ASCAN(aPosicoes, "IPI")
            EndIf      
         Endif
                 
         //DFS - 05/01/2011 - Inclusão de tratamento para verificar se existe informação referente ao PIS na integração de NCM
         If (nPos := ASCAN(aPosicoes,"PIS")) <> 0
            If IsDigit(aNCM[nPos]) // SVG - 10/08/2010 - /*ASCAN(aPosicoes, "PIS")*/
               Aliq->PISPASEP := aNCM[nPos]/*ASCAN(aPosicoes, "PIS")*/
            EndIf 
         EndIf 
         
         //DFS - 05/01/2011 - Inclusão de tratamento para verificar se existe informação referente ao COFINS na integração de NCM  
         If (nPos := ASCAN(aPosicoes,"COFINS")) <> 0
            If IsDigit(aNCM[nPos]) // SVG - 10/08/2010 -ASCAN(aPosicoes, "COFINS")
               Aliq->COFINS   := aNCM[nPos] //ASCAN(aPosicoes, "COFINS")
            EndIf
         EndIf
         
         Aliq->RECUP    := "I" //AAF 03/09/08
         Aliq->( MsUnLock() )
      EndIf

      If nQuebra > 0 
         cLote := SubStr(cLote,nQuebra+2)
      Else
         Exit
      Endif
            
   EndDo

  
   Aliq->( DBSetOrder(0) )
  
   // Fecha o arquivo txt
   FCLOSE(nHandle)


Return NIL


// Funcao     : CountChar()
// Data       : 30/08/2007
// Autor      : Pedro Baroni
// Descricao  : Contar quantas vezes um caracter existe em uma string
// Parametros : cString - Cadeia de caracteres onde será feita a contagem
//            : cChar   - Caracter a ser procurado na string
// Retorno    : nCount - Quantidade de ocorrências do caracter na string
*------------------------------------------------------------------------*
Static Function CountChar(cString,cChar)
*------------------------------------------------------------------------*

 Local nAt    := 1  ,;
       nCount := 0
 
 Default cString := ""

   If Len(cChar) > 0

      Do While Len(cString) > 0  .And.  ( nAt := At(cChar,cString) ) > 0
         nCount++
         cString := SubStr(cString,nAt+1)
         nAt := At(";",cString)
      EndDo
   EndIf


Return nCount


*------------------------------------------------------------------------------------* 
// Funcao   : CONWriteNCM()
// Data     : 30/08/2007
// Autor    : Pedro Baroni
// Objetivo : Verificar se o Conversor.exe já terminou a geração do arquivo tec.txt
// Param    : cFileName = Path e Nome do arquivo saida
//            lEnd      = Informa se o usuário cancelou o processamento
// Retorna  : lCreate = Informa se o arquivo tec.txt foi gerado dentro do tempo
*------------------------------------------------------------------------------------* 
Static Function CONWriteNCM(cFileName,lEnd)
*------------------------------------------------------------------------------------* 

 Local cMensagem := ""   ,;
       lCreate   := .T.  ,;
       nHandle   := 0    ,;
       nSeconds  := 0    ,;
       nTimeOut  := 0


   cMensagem := STR0111  // "Tempo máximo para execução"

   nSeconds := 60*20  // Define o tempo máximo que o sistema aguardará a execução do conversor.exe
   nTimeOut := Seconds()+nSeconds

   TecProcRegua(nSeconds)

   Begin Sequence

      nHandle := F_ERROR
 
      // Tenta abrir o arquivo em modo exclusivo
      Do While !File(cFileName)  .Or.  ( nHandle := EasyOpenFile( cFileName, FO_EXCLUSIVE ) ) == F_ERROR

         // Se o cliente cancelar ou o exceder o tempo
         If lEnd  .Or.  nTimeOut <= Seconds()
            lCreate := .F.
            Break
         EndIf

         nHour   := Int( nSeconds / 3600 )
         nMinute := Int( ( nSeconds - (nHour*3600) ) / 60 )
         nSecond := Int( nSeconds - (nHour*3600) - (nMinute*60) )
         TecIncProc(cMensagem+" ("+StrZero(nHour,2)+":"+StrZero(nMinute,2)+":"+StrZero(nSecond,2)+")")

         AvDelay(1)
         nSeconds--

      EndDo
   
      If nHandle != F_ERROR
         FClose( nHandle )
      EndIf
      
   End Sequence


Return lCreate
/*------------------------------------------------------------------------------------* 
 Funcao   : CriaArq
 Data     : 03/09/08
 Autor    : Anderson Soares Toledo
 Objetivo : Criar o arquivo necessário para o InterfWeb, que contem as NCM's que
            serão atualizadas
 Param    : cPath = Caminho para a pasta onde o InterWeb está instalado
 Retorna  :
*------------------------------------------------------------------------------------*/ 
Static Function CriaArq(cPath)
   Local nHandle
   
   //Verifica se o arquivo termina com '\'
   If (Right(cPath,1) != "\") 
      cPath += "\"
   EndIf
                              
   //Verifica se exista o arquivo EasyTec.txt, caso positivo exclui
   if File(cPath+"EasyTec.txt")
      If FERASE(cPath+"EasyTec.txt") == -1
         TecMSGINFO(STR0121, FERROR()) //STR0124 "Erro ao excluir o arquivo EasyTec.txt"
      EndIf
   endif
                                                        
   //Cria o arquivo EasyTec.txt em branco
   nHandle := EasyCreateFile(cPath+"EasyTec.txt", FC_NORMAL)
   
   FClose(nHandle)
   
Return                                                  

/*------------------------------------------------------------------------------------* 
 Funcao   : TxtEasyTec
 Data     : 03/09/08
 Autor    : Anderson Soares Toledo
 Objetivo : Adicionar as NCM's selecionadas no arquivo EasyTec.txt
 Param    : cNCM : código NCM a ser adicionada no arquivo
 Retorna  :
*------------------------------------------------------------------------------------*/ 
Static Function TxtEasyTec(cNCM)
   local nF_BLOCK := 8000//4000 NCF - 10/10/2017
   local cBuffer := SPACE(nF_BLOCK)
   local nBytesRead
   local nInfile, nOutfile
   //cDirExport variavel private com o endereço da pasta onde o InterfWeb está instalado 
   local cPath := cDirExport 
                            
   If Right(cPath,1) != "\"
      cPath += "\"
   EndIf
   
   If File(cPath+"EasyTec.txt")      
      //Verifica se existe o arquivo temporário de outra transeferencia, se existir, exclui
      If File(cPath+"EasyTectmp.txt")
         FErase(cPath+"EasyTectmp.txt")
      EndIf

      If FRename(cPath+"EasyTec.txt", cPath+"EasyTectmp.txt") == -1
         TecMSGINFO(STR0122)//STR0122 "Erro ao renomear o arquivo"
      ENDIF

      nInfile := EasyOpenFile(cPath+"EasyTectmp.txt")
      
      nOutfile := EasyCreateFile(cPath+"EasyTec.txt", FC_NORMAL)
      lDone := .F.
        
      //Transfere os dados para o novo arquivo criado
      Do While !lDone

         //transfere todos os dados para o novo arquivo
         nBytesRead := FREAD(nInfile, @cBuffer, nF_BLOCK)
         If FWRITE(nOutfile, cBuffer, nBytesRead) < nBytesRead
            TecMSGINFO(STR0123, FERROR()) //STR0123 "Erro ao escrever o arquivo: "
            lDone := .T.
         ELSE
            lDone := (nBytesRead == 0)
         ENDIF
      
      EndDo                    
      
      //Adiciona os novos dados
      FWrite(nOutfile,cNCM,len(cNCM))
      
      FCLOSE(nInfile)
      FCLOSE(nOutfile)
      
      //Exclui o arquivo temporário
      If FERASE(cPath+"EasyTecTmp.txt") == -1
         TecMSGINFO(STR0124, FERROR()) //STR0124 "Erro ao excluir o arquivo temporário"
      EndIf
   Else
      TecMSGINFO(STR0125) //STR0125 "Erro ao localizar o arquivo EasyTec.txt"
   Endif
return                  


/*------------------------------------------------------------------------------------* 
 Funcao   : txt2Array()
 Data     : 03/09/08
 Autor    : Anderson Soares Toledo
 Objetivo : Adicionar as NCM's selecionadas no arquivo EasyTec.txt
 Param    : cPath -> Caminho para o arquivo interfato.txt 
 Retorna  : vetor com os dados contidos no arquivo interfato.txt
*------------------------------------------------------------------------------------*/ 
Static Function txt2Array(cPath)   
   Local hFile, nSize, nLidos := 0, aLinhas := {}, aFile := {}
   Local nCont, nNCM, nSeq, nDtInicial, cErroTxt := cErroCmp := ""
   Private cLine := ""
   
   Begin Sequence
    hFILE := EasyOpenFile(cPath,FO_READ+FO_EXCLUSIVE)
    if hFile != -1
        //verifica o tamanho do arquivo
        nSIZE := FSEEK(hFILE,0,2)
        FSEEK(hFILE,0,0)
    
        DO WHILE nLIDOS < nSIZE
          nLidos += LerLinha(hFile,@cLine,nSize)     
          aAdd(aLinhas,cLine)
        ENDDO 
                                  
        TecProcRegua(len(aLinhas))
    
        For nCont := 1 to len(aLinhas)
          TecIncProc(STR0126) //STR0126 "Organizando dados obtidos do InterfWeb." 
          IF AT(";",aLinhas[nCont]) == 0
             cErroCmp := (STR0137)
          ElseIF AT("#",aLinhas[nCont]) == 0
             cErroTxt := (STR0138)
          EndIF
          IF !Empty(cErroCmp+cErroTxt)
              MSGINFO(StrTran(STR0119,"'###'",cErroCmp + ENTER + cErroTxt))
              Break
          Else
              aAdd(aFile,SplitAduaneiras(aLinhas[nCont]))
          EndIF
        Next     
        
        FClose(hFILE)                          
    
        //verifica a posição dos dados no cabeçalho
        nNCM := aScan(aFile[1],{|x| x == 'CODNCM'})
        nSeq := aScan(aFile[1],{|x| x == 'SEQ'})
        nDtInicial := aScan(aFile[1],{|x| x == 'DTINICIAL'})
        If nNCM == 0 // Caso não encontre NCM
            aFile := {} // Array será definido como vazio para que interrompa o processamento
        ElseIf nSeq == 0 // Caso não encontre Seq, o vetor será ordenado apenas pela NCM em ordem crescente
            aSort(aFile,2,,{|x,y| x[nNCM] < y[nNCM] })
        Else
            //Caso seja integração geral (interf.txt), não exite o campo DTINICIAL
            If nDtInicial <> 0
               //ordena o vetor por NCM e Sequencia em ordem crescente e Data por ordem decrescente
               aSort(aFile,2,,{|x,y| if( x[nNCM]+x[nSeq]  == y[nNCM]+y[nSeq], DtoS(CtoD(x[nDtInicial])) > DtoS(CtoD(y[nDtInicial])), x[nNCM]+x[nSeq] < y [nNCM]+y[nSEQ]) })
            Else
               //ordena o vetor por NCM e Sequencia em ordem crescente
               aSort(aFile,2,,{|x,y| x[nNCM]+x[nSeq] < y [nNCM]+y[nSEQ] })
            EndIf
        EndIf
    Else 
        TecMSGINFO(StrTran(STR0127 +'(Cod.Erro: '+str(ferror(),4)+")","'###'",cFileTxt)) //"Erro ao abrir o arquivo '###'" 
    Endif

   End Sequence
return aFile                  
                
/*------------------------------------------------------------------------------------* 
Funcao      : LerLinha
Parametros  : hFile, @cVar, nSize
Retorno     : Proxima Linha a ser lida
Objetivos   : Leitura do arquivo para transferir seu conteudo para um vetor
Autor       : Cristiano A. Ferreira
Data/Hora   : 21/12/1999 11:10
Revisao     :
Obs.        : No fonte EECSI400 com o nome SI100ReadLn
*------------------------------------------------------------------------------------*/ 
Static Function LerLinha(hFile,cVar,nSize)
   local cBuffer  := ""
   local cAux    := ""

   local nBytes  := 1024
   local nEndLine:= 0
   local nPos    := 0
   
   While (nEndLine := At(CRLF,cAux)) == 0 .And. (nPos:=fSeek(hFile,0,1))<nSize
      IF nBytes > (nSize-nPos)
         nBytes := (nSize-nPos)
      Endif
      cBuffer := Space(nBytes)
      fRead(hFile,@cBuffer,nBytes)
      cAux += cBuffer
   Enddo
   
   IF nPos < nSize
      nVolta := (Len(cAux)+1) - nEndLine
      nVolta -= 2
      fSeek(hFile,-nVolta,1)
      cVar := Substr(cAux,1,nEndLine-1)
   ELSE
      cVar := cAux
   ENDIF
   
Return Len(cVar)+2                                                            

/*------------------------------------------------------------------------------------*
Funcao      : SplitAduaneiras
//Parametros  : Texto a ser divido, array onde as partes serão armazenadas, caracter usado para divisão do texto
Retorno     : Vetor com os campos
Objetivos   : Dividir o texto em campo de acordo com os caracteres de divisão
Autor       : Anderson Soares Toledo
Data/Hora   : 01/08/2008 - 11h00
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function SplitAduaneiras(cLinha)             
   Local aArray := {}                         
   Local cCaracter := SubStr(cLinha,1,1)
   Local c1stLnChar:= Left(cLinha,1)
   Local cSplit := SubStr(cLinha,At(cCaracter,SubStr(cLinha,2,len(cLinha)))+2,If(c1stLnChar <> "#",1,2)/*1*/)   //NCF - 11/12/2015 - O separador do arquivo passou a ser "#,#" portanto deve ser considerado a string ",#" como separação entre campos
   Local nCont, nPosIni := 1, nEmptyCol

   
   //Caso o ultimo caracter da linha seja um de divisão, é criado um campo vazio no vetor
   //por esse motivo ele é retirado da linha
   If SubStr(cLinha,len(cLinha),1) == cSplit
      cLinha := SubStr(cLinha,1,len(cLinha) - 1) 
   EndIf
   
   /* *** RMD - 02/05/16
   		Verifica se existem colunas vazias sem os campos delimitadores de conteúdo.
   		Caso exista, inclui os caracteres que delimitam o conteúdo, caso contrário a função de split não fará a quebra corretamente.
   		Ou seja, considerando um cenário com 3 colunas sendo uma em brannco, teríamos:
   		Linha: #Coluna1#;;#Coluna3#
   		Array: {"#Coluna1#;", ";#Coluna3#"} -> Duas posições
   		Enquanto o correto seria:
   		Linha: #Coluna1#;##;#Coluna3#
   		Array: {"#Coluna1#;", "##", "#Coluna3#"} -> Três posições
   */
   //Verifica se existe uma coluna vazia, ou seja, uma repetição do separador (ex.: ;;)
   While (nEmptyCol := At(Repl(Left(cSplit, 1), 2), SubStr(cLinha, nPosIni))) > 0
      /*	Caso exista, verifica se é realmente uma coluna ou se está dentro de uma string.
      		Para isso, verifica se o último caracter de delimitação de string é o início ou o final de uma coluna.
      		Exemplo - 	Início de uma coluna: ;#
      					Final de uma coluna: #
      */
      If RAt("#", SubStr(cLinha, 1, nPosIni + nEmptyCol)) > RAt(";#", SubStr(cLinha, 1, nPosIni + nEmptyCol)) + 1
         /*	Se for o final de uma coluna, então considera a repetição como uma nova coluna e inclui o caracter de delimitação de conteúdo. 
         	Exemplo: Troca ";;" por ";##;"
         	Ou seja, não faz a substituição caso o separador tenha sido repetido dentro de uma string. Ex.: "Descrição ;;da NCM..."
         */
         cLinha := SubStr(cLinha, 1, nPosIni + nEmptyCol - 2) + Left(cSplit, 1) + Repl(cCaracter, 2) + Left(cSplit, 1) + SubStr(cLinha, nPosIni + nEmptyCol + 1)
      EndIf
      //Atualiza a posição inicial para a próxima busca verificar somente o restante da String
      nPosIni += nEmptyCol + 1
   EndDo
   cSplit := Left(cSplit, 1)
   //Verifica também se a última coluna da linha está em branco e caso necessário inclui o separador
   If Right(cLinha, 1) == cSplit
      cLinha += Repl(cCaracter, 2)
   EndIf
   //***

   aArray := aSplit(cLinha, cSplit)

   For nCont := 1 to len(aArray)
      //retira o caracter de divisão de campo
      aArray[nCont] := StrTransf(aArray[nCont],cCaracter,"")
      //transforma a vírgula em ponto para converter a String em Numérico com a função Val
      aArray[nCont] := StrTransf(aArray[nCont],",",".")      
   Next

return aArray               

/*------------------------------------------------------------------------------------
Funcao      : ComChave
Parametros  : cCampoSX3, campo da tabela SX3 que será utilizado para obter o tamanho correto
              cChave, campo que irá ter o tamanho ajustado
Retorno     : cChave com o tamanho correto
Objetivos   : Ajustar um campo para o tamanho correto com espaços em branco.
Autor       : Anderson Soares Toledo
Data/Hora   : 01/08/2008 - 11h00
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function ComChave(cCampoSX3,cChave)
   local nSpace, nCompleta
   
   if ValType(cChave) == "C"
      //Obtem o tamanho do campo na tabela SX3
      nSpace := AvSx3(cCampoSX3,3)
      
      //Verifica se o campo está com tamanho inferior ao correto
      nCompleta := nSpace - len(cChave)
   
      if nCompleta > 0
         //Ajusta o tamanho da variavel com o do campo utilizando espaços em branco.
         cChave += space(nCompleta)
      EndiF                 
   EndIf   
return cChave
   

/*------------------------------------------------------------------------------------
Funcao      : cpyTxt2Srv
Parametros  : cPath, caminho onde se encontra o arquivo Interfato.txt
Retorno     : 
Objetivos   : Copiar o arquivo obtido no InterfWeb para a pasta System do servidor
Autor       : Anderson Soares Toledo
Data/Hora   : 03/08/2008 - 11h00
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function cpyTxt2Srv(cPath,cDest)
   //obtem o caminho para a pasta system no servidor  
   local cTemp := subStr(cFileTxt,1,at(".",cFileTxt))+"old" //cria uma variavel contendo o nomeDoArquivo.old
   Default cDest := GetSrvProfString("ROOTPATH","")+"\system\"     
             
   If File(cPath+cFileTxt)
      If File(cDest+cTemp) 
         If FRename(cDest+cFileTxt, cDest+cTemp) == 0
            __CopyFile(cPath+cFileTxt,cDest+cFileTxt)
            FErase(cPath+cFileTxt)
         Else
            TecMSGINFO(STR0131) //STR0131 "Erro ao renomear o arquivo temporário."
         ENDIF       
      Else
         __CopyFile(cPath+cFileTxt,cDest+cFileTxt)
         FErase(cPath+cFileTxt)
      EndIf      
   Else
      TecMSGINFO(STR0130) //STR0130 "Arquivo Interfato.txt não localizado"
   EndIf   
return
                       


/*------------------------------------------------------------------------------------
Funcao      : runInterf
Parametros  : cPath, caminho onde se encontra o programa InterWeb.exe
Retorno     : 
Objetivos   : Devido a nova versão do InterfWeb estar gerando log na raiz, esta função
              faz o mesmo gerar o log na pasta de instalação do programa
Autor       : Anderson Soares Toledo
Data/Hora   : 02/11/2008 - 14h00
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function runInterf(cPath)
   Local cBat
   Local nHandler
   Local nTypeExeUs := GetRemoteType()
   Local cPathBat 
   
   cPathBat := If( nTypeExeUs == -1 , cPath , GetClientDir() )    //NCF - 10/10/2017 

   cBat := "@ECHO OFF" + chr(13)+chr(10)
   cBat += "Echo Executando programa InterfWeb.exe "+ chr(13)+chr(10)
   cBat += "cd " + cPath + chr(13)+chr(10)

   If EasyGParam("MV_TIPOADU",,1) == 1 //caso o parametro não exista utiliza a configuração para Ato Legal
      cFileTxt := "Interfato.txt"
      cBat += "InterfWeb.exe /auto /ato"
   ElseIf EasyGParam("MV_TIPOADU") == 2
      cFileTxt := "InterfNaladi.txt"
      cBat += "InterfWeb.exe /auto /naladi"
   ElseIf EasyGParam("MV_TIPOADU") == 3
      cFileTxt := "Interf.txt"
      cBat += "InterfWeb.exe /auto /geral"              
   Else
      Alert("Erro na configuração do parametro MV_TIPOADU")
      return .F.
   EndIF
  
   nHandler := EasyCreateFile(cPathBat+"Interf.bat")
   FWrite(nHandler, cBat)
   FClose(nHandler) 
   
   If !lSchedule                     //NCF - 11/10/2017 - Não executa aplicação mas precisa ter o nome do arquivo .txt
      WaitRun(cPathBat+'Interf.bat')
   Else
      TecMSGINFO(STR0136,"AVISO")//"O Sistema nao pode executar a aplicacao externa 'interfweb' por rotinas agendadas!"
   EndIf         
   
   FErase(cPathBat+"Interf.bat")
   
return 
