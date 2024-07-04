#INCLUDE "PROTHEUS.CH"
#Include "AVERAGE.CH"

Class AvRetSFRM 
   
   Data aGetsTela
   Data aGetsPos
   Data oDlgTela
   Data cFileWork1
   Data cFileWork2
   Data oMark1
   Data oMark2 
   Data cDlgTit
   Data aAltura
   Data aLargura
   Data oBmp
   Data oGet
   Data oGet2
   Data cDir         
   Data cCount
   Data aSelCposTx
   Data aSelCposWP
   Data cMvDirRet
   Data aArqsTxt

   Method New()          // Instancia Objeto
   Method Init()         // Inicializa variáveis
   Method LerArquivo()   // Efetua Leitura do Arquivo TXT
   Method TxtToWork()    // Monta Work a partir do TXT
   Method Diretorio()    // Monta estrutura dos diretórios
   Method RetSFRMant()   // Metodo de Manutenção
   Method ValidInteg()
   Method Integrar()
   Method GravaSWP()
   
End Class   

//////////////////////////////////////////
//           Instanciador               //
//////////////////////////////////////////
Function AvRetSFRM
   Return AvRetSFRM():New() 

//////////////////////////////////////////
//           Método Construtor          //
//////////////////////////////////////////
Method New() Class AvRetSFRM 

oMainWnd:ReadClientCoords()

   ::aGetsTela := {}
   ::aGetsPos  := {}
   ::oDlgTela  := NIL
   ::oMark1    := NIL
   ::oMark2    := NIL
   ::cDlgTit   := "Retorno SUFRAMA"
   ::aAltura   := {oMainWnd:nTop+125,  oMainWnd:nLeft+5    } //{0,0}
   ::aLargura  := {oMainWnd:nBottom-60,oMainWnd:nRight - 10} //{700,1250}
   ::cCount    := "5"
   ::cDir      := Space(200) 
   ::oGet      := NIL
   ::oGet2     := NIL 
   ::aSelCposTx:= {}
   ::aSelCposWP:= {}
   ::cFileWork1:= ""
   ::cFileWork2:= ""
   ::cMvDirRet := ""
   ::aArqsTxt  := {} 

//////////////////////////////////////////
//           Método Init                //
//////////////////////////////////////////
Method Init() Class AvRetSFRM 

  Local aWorkLI := {}, aWorkWP := {}
  Local COLUNA_FINAL,nLinha
  Local aButtons := {}
  Local bOk, bCancel, lCloseOdlg 
  Private cMarca1 := GetMark(), lInverte1 := .F.
  Private cMArca2 := GetMark(), lInverte2 := .F. 
  
  ::cMvDirRet := EasyGParam("MV_AVG0193",,"")                       
                       
   aAdd(aWorkLI,{"WK1_FLAG",  "C",02,0})
   aAdd(aWorkLI,{"WK1_INSCRI","C",09,0})
   aAdd(aWorkLI,{"WK1_NROPLI","C",10,0})
   aAdd(aWorkLI,{"WK1_AUTPLI","C",11,0})
   aAdd(aWorkLI,{"WK1_NCM",   "C",08,0})
   aAdd(aWorkLI,{"WK1_NUMLI", "C",11,0})
   aAdd(aWorkLI,{"WK1_PRODUT","C",04,0})
   aAdd(aWorkLI,{"WK1_TIPO",  "C",03,0})
   aAdd(aWorkLI,{"WK1_MODELO","C",04,0})
   aAdd(aWorkLI,{"WK1_SEQSFR","C",04,0})
   aAdd(aWorkLI,{"WK1_DTENV", "D",08,0})
   aAdd(aWorkLI,{"WK1_ANLPLI","D",08,0})
   aAdd(aWorkLI,{"WK1_DTPLI", "D",08,0})
   aAdd(aWorkLI,{"WK1_RETPLI","C",60,0})   
   
   aAdd(aWorkWP,{"WK2_PGINUM",AVSX3("WP_PGI_NUM",2),AVSX3("WP_PGI_NUM",3),AVSX3("WP_PGI_NUM",4)})
   aAdd(aWorkWP,{"WK2_SUFRAM",AVSX3("WP_SUFRAMA",2),AVSX3("WP_SUFRAMA",3),AVSX3("WP_SUFRAMA",4)})
   aAdd(aWorkWP,{"WK2_REGIST",AVSX3("WP_REGIST",2) ,AVSX3("WP_REGIST",3) ,AVSX3("WP_REGIST" ,4)})
   aAdd(aWorkWP,{"WK2_ENVORI",AVSX3("WP_ENV_ORI",2),AVSX3("WP_ENV_ORI",3),AVSX3("WP_ENV_ORI",4)})   

   If !(Select("WORKLI") <> 0)
      ::cFileWork1:=E_CriaTrab(,aWorkLI,"WorkLI")
   Else
      WORKLI->(avzap())
   EndIf
   
   If !(Select("WORKWP") <> 0)
      ::cFileWork2:=E_CriaTrab(,aWorkWP,"WorkWP")
   Else
      WORKWP->(avzap())
   EndIf
   
   aAdd(::aSelCposTx,{"WK1_FLAG"   ,"","" }                ) 
   aAdd(::aSelCposTx,{"WK1_INSCRI" ,"","Inscr.Suframa" }   ) 
   aAdd(::aSelCposTx,{"WK1_NROPLI" ,"","Nro.PLI-SUFRAMA"}  )  
   aAdd(::aSelCposTx,{"WK1_AUTPLI" ,"","Nro.Aut.PLI" }     ) 
   aAdd(::aSelCposTx,{"WK1_NCM"    ,"","N.c.m" }           ) 
   aAdd(::aSelCposTx,{"WK1_NUMLI"  ,"","Nro. LI"}          )                   
   aAdd(::aSelCposTx,{"WK1_PRODUT" ,"","Produto"}          )
   aAdd(::aSelCposTx,{"WK1_TIPO"   ,"","Tipo"}             )
   aAdd(::aSelCposTx,{"WK1_MODELO" ,"","Modelo"}           )
   aAdd(::aSelCposTx,{"WK1_SEQSFR" ,"","Seq.Suframa"}      )
   aAdd(::aSelCposTx,{"WK1_DTENV"  ,"","Data Envio"}       )
   aAdd(::aSelCposTx,{"WK1_ANLPLI" ,"","Dt.Anal.PLI"}      )
   aAdd(::aSelCposTx,{"WK1_DTPLI"  ,"","Dt. PLI"}          )
   aAdd(::aSelCposTx,{"WK1_RETPLI" ,"","Retorno PLI"}      )  
   
   aAdd(::aSelCposWP,{"WK2_PGINUM","",AVSX3("WP_PGI_NUM",5)})
   aAdd(::aSelCposWP,{"WK2_SUFRAM","",AVSX3("WP_SUFRAMA",5)})
   aAdd(::aSelCposWP,{"WK2_REGIST","",AVSX3("WP_REGIST" ,5)})
   aAdd(::aSelCposWP,{"WK2_ENVORI","",AVSX3("WP_ENV_ORI",5)})
     
   ::cDir := Iif(!Empty(::cMvDirRet),::cMvDirRet,"\pli\")
//   aAdd(aButtons, {"OPEN",     {|| ::cDir := cGetFile( ,,,,.T., GETF_RETDIRECTORY+GETF_LOCALHARD ),::oGet:Refresh(),::oDlgTela }, "Selecione o arquivo TXT" 
   aAdd(aButtons, {"SDUSEEK",  {|| If(!Empty(::cDir),::LerArquivo(::cDir),Alert("Informe o Diretório"))            ,::oDlgTela }, "Ler TXT" })
   aAdd(aButtons, {"SDUAPPEND",{|| If(::ValidInteg(1),::Integrar(),Alert("Não foi possível Integrar os dados!"))   ,::oDlgTela }, "Integrar"})
   
   bOk     := {||Iif( ::ValidInteg(2) .And. (lCloseOdlg := MsgYesNo("Deseja concluir a integração ?","Aviso")),::GravaSWP(::Self:aArqsTxt), lCloseOdlg := .F. ),Iif(lCloseOdlg,::OdlgTela:End(),)}
   bCancel := {||::OdlgTela:End()}
   
   Define MSDIALOG ::oDlgTela From ::aAltura[1],::aAltura[2] To ::aLargura[1],::aLargura[2] Title ::cDlgTit PIXEL    
   
      COLUNA_FINAL := (::oDlgTela:nClientWidth-4)/2
      nLinha       := (::oDlgTela:nClientHeight-4)/2

      ::oMark1:= MsSelect():New("WorkLI","WK1_FLAG",,::aSelCposTx,@lInverte1,@cMarca1,{30,1,nLinha/2,COLUNA_FINAL},,,)
      ::oMark2:= MsSelect():New("WorkWP",   ,,::aSelCposWP,@lInverte2,@cMarca2,{nLinha/2+10,1,nLinha,COLUNA_FINAL},,,)
                    
   ACTIVATE MSDIALOG ::oDlgTela CENTERED ON INIT EnchoiceBar(oRetSuframa:oDlgTela,bOk,bCancel,,aButtons) 
   
Return

     
//////////////////////////////////////////
//           Método LerArquivo          //
//////////////////////////////////////////
Method LerArquivo(cDir) Class AvRetSFRM    

   Local nI       := 0
   Local nJ       := 0
   Local aDir     := {}
   Local aDirect  := {}
   Local cArquivo := ""

   If !Empty(cDir)
      //::Diretorio(cDir,aDir)
	  //For nI := 1 To Len(aDir) 
         aDirect := Directory(Alltrim(cDir)+"*.txt")
         For nJ := 1 To Len(aDirect)      
		    cArquivo := aDirect[nJ,1]
		    aAdd(::aArqsTxt,Alltrim(cDir+cArquivo))	
			//-- Verifica se é arquivo txt
			If SubStr(cArquivo,RAt(".",cArquivo)+1) $ "txt|TXT"
			   FT_FUSE(cDir+cArquivo)
			   FT_FGOTOP()
			   Processa({|| ::TxtToWork(aDirect[nJ,1]) }, "Aguarde ...", "Verificando o Arquivo "+aDirect[nJ,1],.F.)
			   FT_FUSE()
			EndIf
         Next nJ
	  //Next nI
   Else
      Alert("O diretório a ser verificado não foi informado.")
   EndIf

Return 

//////////////////////////////////////////
//           Método TxtToWork           //
//////////////////////////////////////////
Method TxtToWork(cArquivo) Class AvRetSFRM

   Local cLine    := ""
   //Local nI       := 0
   Local nLin     := 0
   
   If Select("WORKWP") <> 0
      WORKWP->(avzap())
   EndIf
   
   If Select("WORKLI") <> 0
      WORKLI->(avzap())
   EndIf 
   
   ProcRegua(FT_FLastRec())
   While !FT_FEOF() .And. !(cLine := AllTrim(StrTran(FT_FReadLn(),CHR(9),"")) $ Replicate("-",100) )
      nLin ++
	  IncProc(1)
	  cLine := AllTrim(StrTran(FT_FReadLn(),CHR(9),""))

      WORKLI->(DbAppend())                                      
      WORKLI->WK1_FLAG   := Space(2)
      WORKLI->WK1_INSCRI := SUBSTR(cLine,01,09) 
      WORKLI->WK1_NROPLI := SUBSTR(cLine,10,10)  
      WORKLI->WK1_AUTPLI := SUBSTR(cLine,20,11)
      WORKLI->WK1_NCM    := SUBSTR(cLine,31,08)
      WORKLI->WK1_NUMLI  := SUBSTR(cLine,40,11) //Não pega a posição 39 porque ignora o primeiro caracter do nro. da LI
      WORKLI->WK1_PRODUT := SUBSTR(cLine,50,04)
      WORKLI->WK1_TIPO   := SUBSTR(cLine,54,03)
      WORKLI->WK1_MODELO := SUBSTR(cLine,57,04)
      WORKLI->WK1_SEQSFR := SUBSTR(cLine,61,04)
      WORKLI->WK1_DTENV  := STOD(SUBSTR(cLine,69,4)+SUBSTR(cLine,67,2)+SUBSTR(cLine,65,2))/*SUBSTR(cLine,65,08)*/
      WORKLI->WK1_ANLPLI := STOD(SUBSTR(cLine,77,4)+SUBSTR(cLine,75,2)+SUBSTR(cLine,73,2))/*SUBSTR(cLine,73,08)*/
      WORKLI->WK1_DTPLI  := STOD(SUBSTR(cLine,85,4)+SUBSTR(cLine,83,2)+SUBSTR(cLine,81,2))/*SUBSTR(cLine,81,08)*/
      WORKLI->WK1_RETPLI := SUBSTR(cLine,89,Len(cLine))
	  FT_FSKIP()	           
   EndDo
   WORKLI->(DbGoTop())
   
Return

//////////////////////////////////////////
//           Método Diretorio           //
//////////////////////////////////////////
Method Diretorio(cDir,aDir) Class AvRetSFRM 

   Local nI := 0
   Local aDirectory := {}

   //-- Adiciona o diretório
   aAdd( aDir, cDir )

   //-- Pesquisa a existência de subdiretórios
   aDirectory := Directory(cDir+"*.","D")

   For nI := 1 To Len(aDirectory)
	  If aDirectory[nI,5] $ "AD" .And. !(aDirectory[nI,1] $ ".|..")
         //-- Chamada recursiva para adicionar os subdiretórios
		::Diretorio(cDir+aDirectory[nI,1]+"\",aDir)
	  EndIf
   Next nI

Return

//////////////////////////////////////////
//           Método ValidInteg          //
//////////////////////////////////////////
Method ValidInteg(nEtapa) Class AvRetSFRM

Private cMsgRet 

If WORKLI->(EOF()) .AND. WORKLI->(BOF())
   Alert("Não existem dados no txt a serem integrados")
   Return .F.
EndIf

If nEtapa == 2
   If WORKWP->(EOF()) .AND. WORKWP->(BOF())
      Alert("Não existem LI`s relacionadas a este arquivo txt")
      Return .F.
   EndIf
EndIf
   
Return .T.
                                              
//////////////////////////////////////////
//           Método Integrar            //
//////////////////////////////////////////
Method Integrar() Class AvRetSFRM
   
   WORKLI->(DbGoTop())
   SWP->(DbGoTop())
        
   If Select("WORKWP") <> 0
      WORKWP->(avzap())
   EndIf
   
   While WorkLI->(!Eof()) .And. WorkLI->(!Bof())
      IF WorkLI->WK1_FLAG $ "  "
         WorkLI->(DbSkip())
         LOOP
      Else
         While SWP->(!EOF()) .And. SWP->(!BOF())
            IF Alltrim(WorkLI->WK1_NROPLI) == Alltrim(SWP->WP_SUFRAMA) .And. Empty(SWP->WP_REGIST)
               WorkWP->(DbAppend())           
               WorkWP->WK2_PGINUM := SWP->WP_PGI_NUM
               WorkWP->WK2_SUFRAM := WorkLI->WK1_NROPLI 
               WorkWP->WK2_REGIST := WorkLI->WK1_NUMLI
               WorkWP->WK2_ENVORI := WorkLI->WK1_DTENV	         
            Else
               SWP->(DBSkip())
               LOOP
            EndIf 
            SWP->(DBSKIP())  
         EndDo
         SWP->(DbGoTop())
      EndIf
      WorkLI->(DbSkip())
   EndDo
   WorkWP->(DbGoTop())
Return 

//////////////////////////////////////////
//           Método GravaSWP            //
//////////////////////////////////////////
Method GravaSWP(aArquivos) Class AvRetSFRM

Local i := 1

SWP->(DbSetOrder(1))
WorkWP->(DbGotop())

BEGIN TRANSACTION 
While !WorkWP->(EOF())
   SWP->(DbSeek(xFilial()+WorkWP->WK2_PGINUM))
   While !SWP->(EOF()) .And. WorkWP->WK2_PGINUM == SWP->WP_PGI_NUM
      If Alltrim(WorkWP->WK2_SUFRAM) == Alltrim(SWP->WP_SUFRAMA) //AAF 03/07/2015 - Retornar apenas para o registro do mesmo LI-Suframa.
         SWP->(RecLock("SWP",.F.))
         SWP->WP_REGIST := Alltrim(WorkWP->WK2_REGIST)
         SWP->(MsUnlock())
		 EXIT
	  EndIf
      SWP->(DbSkip())  
   EndDo 
   WorkWP->(DbSkip())
EndDo
END TRANSACTION

If Len(aArquivos) > 0
   For i := 1 To Len(aArquivos)
      FRename(aArquivos[i],SUBSTR(aArquivos[i],1,Rat(".",aArquivos[i])-1)+"_"+DtoS(dDataBase)+"_"+".old")
   Next i 
EndIf

Return .T.
                                               