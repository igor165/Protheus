#include "PROTHEUS.CH" 
#include "TBICONN.CH" 
#INCLUDE 'FWMVCDEF.ch'


Static aPlnDmd := {}
Static aPerT146 := {}
/*/-----------------------------------------------------------
{Protheus.doc} T153DMDPRG()
Função para geração da Programação de Carregamento a partir de um Planejamento de Demandas.

Uso: T153DMDPRG()

@author André Luiz Custódio
@since 24/07/18
@version 12.1.17
-----------------------------------------------------------/*/
Function T153DMDPRG(cCodPlnDmd)
  Local lRet := .F.

  if T153GPlnDm(cCodPlnDmd)
      
      PlnPrgExec()

      lRet := T153PRGOK(cCodPlnDmd)
  endif 
  

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} T153PRGOK()
Indicar que a inclusão do Programação de Carregamento ocorreu com sucesso.

Uso: T153PRGOK()

@author André Luiz Custódio
@since 24/07/18
@version 12.1.17
-----------------------------------------------------------/*/

Function T153PRGOK(cCodPlnDmd)
  Local cQuery  := ''
  Local lRet    := .F.
  Local cQryPln := GetNextAlias()

  cQuery:= " SELECT DISTINCT '1' PRGOK"
	cQuery+= " FROM "+RetSqlName('DF8')+ " DF8 "
	cQuery+= " WHERE DF8.DF8_FILIAL = '" + xFilial('DF8') + "'"
	cQuery+= " AND DF8.DF8_PLNDMD = '"+cCodPlnDmd+"' "
	cQuery+= " AND DF8.D_E_L_E_T_ = '' "
  cQuery+= " AND DF8.DF8_STATUS = '1' "

		cQuery := ChangeQuery(cQuery)


	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryPln, .F., .T. )

	if (cQryPln)->PRGOK == '1'
		lRet := .T.
  endif		

	(cQryPln)->(DbCloseArea())    

Return lRet
/*/-----------------------------------------------------------
{Protheus.doc} PlnPrgExec()
Executar a criação da programação de carregamento sem abertura de tela TMSA146

Uso: DmdPrgExec()

@author André Luiz Custódio
@since 03/08/2018
@version 12.1.17
-----------------------------------------------------------/*/
Function PlnPrgExec()

  Local oModel146  := Nil
  Local cModel146  := "TMSA146"
  Local lRet       := .F.
  Local cFilDF8    := xFilial("DF8")
  Local cNumDF8    := " "
  Local cRota      := " "
  Local cPlnDmd    := aPlnDmd[1]
  Local cCodCAV    := iif(!Empty(aPlnDmd[3]),aPlnDmd[2]," ")
  Local nOperacao  := MODEL_OPERATION_INSERT
  Local cQryDT5    := GetNextAlias()
  Local cQuery     := ''
  Local aDoctosPrg := {}


  T153GSetPa()

  cQuery:= " SELECT DT5.DT5_FILDOC, DT5.DT5_NUMSOL "
  cQuery+= "   FROM "+RetSqlName('DT5')+ " DT5 "
  cQuery+= "  WHERE DT5.DT5_FILIAL = '" + xFilial('DT5') + "'"
  cQuery+= "    AND DT5.DT5_STATUS <> '9' "
  cQuery+= "    AND DT5.D_E_L_E_T_ = '' "
  cQuery+= "    AND EXISTS ( SELECT DISTINCT 1 "
  cQuery+= "                   FROM "+RetSqlName('DL8')+ " DL8 "
  cQuery+= "                  WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
  cQuery+= "                    AND DL8.D_E_L_E_T_ = '' "
  cQuery+= "                    AND DL8.DL8_COD     = DT5.DT5_CODDMD "
  cQuery+= "                    AND DL8.DL8_SEQ     = DT5.DT5_SEQDMD "
  cQuery+= "                    AND DL8.DL8_PLNDMD  = '"+cPlnDmd+"'"
  cQuery+= "                ) "

  cQuery := ChangeQuery(cQuery)

  dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryDT5, .F., .T. )

  While (cQryDT5)->(!EOF())   
    //---- Carregar a variavel aDoctosPrg com os documentos da programação não é obrigatorio
    /* DOC TRANSPORTE
    
    aAdd(aDoctosPrg,{'M SP 01'  ,;  //Filial do Documento (DT6_FILDOC)
                     '111000073' ,;  //Documento (DT6_DOC)
                     '111'       ,;  //Serie Documento (DT6_SERIE)
                     ''          ,;  //Numero da Nota (DTC_NUMNFC)
                     ''          ,;  //Serie da Nota (DTC_SERNFC)
                     ''          ,;  //Filial de Origem (DTC_FILORI)
                     ''          ,;  //Numero do Lote (DTC_LOTNFC)
                     cCodCAV     ,;  //Codigo do Cavalo, caso for uma programação para Reboque
                     .F.         })  //Controle interno da rotina TMSA146, enviar sempre F
    
    NOTAS FISCAIS DE CLIENTE                     

    aAdd(aDoctosPrg,{''          ,;  //Filial do Documento (DT6_FILDOC)
                     ''          ,;  //Documento (DT6_DOC)
                     ''          ,;  //Serie Documento (DT6_SERIE)
                     '27074    ' ,;  //Numero da Nota (DTC_NUMNFC)
                     '1  '       ,;  //Serie da Nota (DTC_SERNFC)
                     'M SP 01 '  ,;  //Filial de Origem (DTC_FILORI)
                     '001139'    ,;  //Numero do Lote (DTC_LOTNFC)
                     cCodCAV     ,;  //Codigo do Cavalo, caso for uma programação para Reboque
                     .F.         })  //Controle interno da rotina TMSA146, enviar sempre F    
                     
    COLETAS                     
                     */
    
    aAdd(aDoctosPrg,{(cQryDT5)->(DT5_FILDOC)  ,;  //Documento (DT6_DOC)
                     (cQryDT5)->(DT5_NUMSOL)  ,;  //Filial do Documento (DT6_FILDOC)                     
                     'COL'                 ,;  //Serie Documento (DT6_SERIE)
                     ''                    ,;  //Numero da Nota (DTC_NUMNFC)
                     ''                    ,;  //Serie da Nota (DTC_SERNFC)
                     ''                    ,;  //Filial de Origem (DTC_FILORI)
                     ''                    ,;  //Numero do Lote (DTC_LOTNFC)
                     cCodCAV               ,;  //Codigo do Cavalo, caso for uma programação para Reboque*/
                     .F.                    })  //Controle interno da rotina TMSA146, enviar sempre F


    lRet := .T.
    
    (cQryDT5)->(DbSkip())

  EndDo

  (cQryDT5)->(DbCloseArea())

  If nOperacao == 3   //Inclusão
    A146PlnDmd(cPlnDmd)
    TMSA146(.T., aDoctosPrg, nOperacao, cRota)  
  ElseIf nOperacao == 5 //Alteraçao
    dbSelectArea("DF8")
    DF8->(dbSetOrder(1))
    If	DF8->(DbSeek( cSeek := FwxFilial('DF8')+ cFilDF8 + cNumDF8 ))
      TMSA146(.T., {}, 5)
    EndIf	
  EndIf	

  RestPer146()

Return lRet 

/*/-----------------------------------------------------------
{Protheus.doc} T153GSetPa()
Setar os parâmetros do pergunte TMSA146, para criação da programação de carregamento s/ abertura de tela

Uso: T153GSetPa()

@author André Luiz Custódio
@since 03/08/2018
@version 12.1.17
-----------------------------------------------------------/*/

Function T153GSetPa(lDemanda,cCodReb,dDtPrevIni,dDtPrevFim,dDtEmiIni,dDtEmiFim)

  Default lDemanda:= .T.
  Default cCodReb := ""   
  Default dDtPrevIni:= dDataBase - 1
  Default dDtPrevFim:= dDataBase 
  Default dDtEmiIni:= dDataBase - 1
  Default dDtEmiFim:= dDataBase

  //---- Prepara o pergunte da rotina TMSA146
  Pergunte('TMSA146',.F.)

  SavePer146()

  SetMVValue("TMSA146","MV_PAR01",dDtPrevIni)                 //Data Previsão Entrega De ?    
  SetMVValue("TMSA146","MV_PAR02",dDtPrevFim)                 //Data Previsão Entrega Até ?
  SetMVValue("TMSA146","MV_PAR03",dDtEmiIni)                  //Data Emissão De ?
  SetMVValue("TMSA146","MV_PAR04",dDtEmiFim)                  //Data Emissão Até ?
  SetMVValue("TMSA146","MV_PAR05",'')                         //Prioridade De ?
  SetMVValue("TMSA146","MV_PAR06",'Z')                        //Prioridade Até ?
  SetMVValue("TMSA146","MV_PAR07",Space(Len(DTC->DTC_CLIREM)))            //Cliente De ?
  SetMVValue("TMSA146","MV_PAR08",Space(Len(DTC->DTC_LOJREM)))            //Loja De ?
  SetMVValue("TMSA146","MV_PAR09",Replicate('Z',Len(DTC->DTC_CLIREM)))    //Cliente Até ?
  SetMVValue("TMSA146","MV_PAR10",Replicate('Z',Len(DTC->DTC_LOJREM)))    //Loja Até ?
  SetMVValue("TMSA146","MV_PAR11",1)                                      //Tipo de Cliente ?   1- Remetente, 2-Destinatario, 3-Devedor, 4-Calculo
  SetMVValue("TMSA146","MV_PAR12",Space(Len(DUY->DUY_GRPVEN)))            //Região Origem De ?
  SetMVValue("TMSA146","MV_PAR13",Replicate('Z',Len(DUY->DUY_GRPVEN)))    //Região Origem Ate ?
  SetMVValue("TMSA146","MV_PAR14",Space(Len(DUY->DUY_GRPVEN)))            //Região Destino De ?
  SetMVValue("TMSA146","MV_PAR15",Replicate('Z',Len(DUY->DUY_GRPVEN)))    //Região Destino Até ?
  SetMVValue("TMSA146","MV_PAR16",3)                                      //Exibir Veiculos ?  1- Em Filial, 2-Da Filial Base, 3-Todos
  SetMVValue("TMSA146","MV_PAR17",Space(Len(DA8->DA8_COD)))               //Rota De ?   //INFORMAR A ROTA QUE SERÁ GRAVADA NA PROGRAMACAO
  SetMVValue("TMSA146","MV_PAR18",Replicate('Z',Len(DA8->DA8_COD)))       //Rota Ate ?  //INFORMAR A ROTA QUE SERÁ GRAVADA NA PROGRAMACAO
  SetMVValue("TMSA146","MV_PAR19",3)                                      //Listar Doctos Bloqueados ? 1-Sim,2-Não,3-Ambos
  SetMVValue("TMSA146","MV_PAR20",'')                                     //Filiais de Destino ?
  SetMVValue("TMSA146","MV_PAR21",3)      //Selecionar Documentos Por: ? 1- NF Cliente, 2-Doc.Transporte, 3-Todos
  SetMVValue("TMSA146","MV_PAR22",1)      //Tipo de Agendamento De ?   //0-Prioridade Cliente,1-Prioridade Transportador,2-Cliente,3-Transportador,4-Aguardando Agendamento
  SetMVValue("TMSA146","MV_PAR23",4)      //Tipo de Agendamento Até ?  //0-Prioridade Cliente,1-Prioridade Transportador,2-Cliente,3-Transportador,4-Aguardando Agendamento
  SetMVValue("TMSA146","MV_PAR24",'   ')  //Prioridade Ag. Entrega De ?
  SetMVValue("TMSA146","MV_PAR25",'ZZZ')  //Prioridade Ag. Entrega Até ?
  SetMVValue("TMSA146","MV_PAR26",'1')    //Serviço de Transporte De ?    //1-Coleta,2-Transferencia,3-Entrega
  SetMVValue("TMSA146","MV_PAR27",'3')    //Serviço de Transporte Até ?   //1-Coleta,2-Transferencia,3-Entrega
  SetMVValue("TMSA146","MV_PAR28",'1')    //Tipo de Transporte ?   //1-Rodoviario
  
  If Len(aPlnDmd) > 0
    If !Empty(aPlnDmd[3])
      cCodReb := AllTrim(T153GetPla(aPlnDmd[3]))
      If !Empty(aPlnDmd[4])    
        cCodReb += ";"+Alltrim(T153GetPla(aPlnDmd[4]))
        If !Empty(aPlnDmd[5])
          cCodReb += ";"+AllTrim(T153GetPla(aPlnDmd[5]))
        EndIf
      EndIf
    Else
    
      cCodReb := AllTrim(T153GetPla(aPlnDmd[2])) // Caso não haja reboques, informa o veículo tracionador que deve ser diferente de "Cavalo"
    
    EndIf
EndIf

If !Empty(cCodReb)    
  SetMVValue("TMSA146","MV_PAR29",cCodReb)  //Placas do Veiculo ?  SEPARAR POR ; CASO HOUVER MAIS DE UM VEICULO
EndIf
  
  
  SetMVValue("TMSA146","MV_PAR30",'')     //Tipo de Veiculo ?
  SetMVValue("TMSA146","MV_PAR31",4)      //Tipo de Frota ? 1-Propria,2-Terceiro,3-Agregado,4-Todos
  SetMVValue("TMSA146","MV_PAR32",2)      //Valida Restrição ? 1-Sim,2-Não

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} SavePer146()
Salvar o estado do pergunte TMSA146 antes do processamento sem tela

Uso: TMSA153H()

@author André Luiz Custódio
@since 29/08/18
@version 12.1.17
-----------------------------------------------------------/*/

Function SavePer146()
  Local nx:= 0

  asize (aPerT146,0)

  for nx := 1 to 32 
    aAdd(aPerT146,&('MV_PAR'+StrZero(nx,2)))
  next nx

Return nil

/*/-----------------------------------------------------------
{Protheus.doc} RestPer146()
Restaurar o estado do pergunte TMSA146 antes do processamento sem tela

Uso: TMSA153H()

@author André Luiz Custódio
@since 29/08/18
@version 12.1.17
-----------------------------------------------------------/*/
Function RestPer146()
  Local nx:= 0

  Pergunte('TMSA146',.F.)

  for nx := 1 to 32 
    SetMVValue("TMSA146","MV_PAR"+StrZero(nx,2),aPerT146[nx])  
  next nx 

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} T153GPlnDm()
Seta o Planejamento de Demandas que será vinculado a Progranação de CVarregamento.

Uso: T153GPlnDm()

@author André Luiz Custódio
@since 24/07/18
@version 12.1.17
-----------------------------------------------------------/*/

Function T153GPlnDm(cPlanDmd)
	Local lRet    := .F.
	Local cQryPln := GetNextAlias()
	Local cQuery  := ''

	aSize(aPlnDmd,0)

	cQuery:= " SELECT DL9.DL9_COD, DL9.DL9_CODVEI, DL9.DL9_CODRB1, DL9.DL9_CODRB2, DL9.DL9_CODRB3"
	cQuery+= "  FROM "+RetSqlName('DL9')+ " DL9 "
	cQuery+= " WHERE DL9.DL9_FILIAL = '" + xFilial('DL9') + "'"
	cQuery+= "   AND DL9.DL9_COD = '"+AllTrim(cPlanDmd)+"' "
	cQuery+= "   AND DL9.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryPln, .F., .T. )

	aAdd(aPlnDmd, (cQryPln)->(DL9_COD))
	aAdd(aPlnDmd, (cQryPln)->(DL9_CODVEI))
	aAdd(aPlnDmd, (cQryPln)->(DL9_CODRB1))
	aAdd(aPlnDmd, (cQryPln)->(DL9_CODRB2))
	aAdd(aPlnDmd, (cQryPln)->(DL9_CODRB3))
	
  (cQryPln)->(DbCloseArea())

  lRet := !Empty(aPlnDmd[1])

Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} T153GetPla()
Retorna a placa de acordo com um determinado código de  veículo

Uso: T153GetPla()

@author André Luiz Custódio
@since 24/07/18
@version 12.1.17
-----------------------------------------------------------/*/

Function T153GetPla(cCodDA3)
	Local cQryDA3 := GetNextAlias()
	Local cQuery  := ''
  Local cPlaca  := ''

  cQuery:= " SELECT DA3.DA3_PLACA "
  cQuery+= "   FROM "+RetSqlName('DA3')+ " DA3 "
  cQuery+= "  WHERE DA3.DA3_FILIAL = '" + xFilial('DA3') + "'"
  cQuery+= "    AND DA3.DA3_COD    = '"+AllTrim(cCodDA3)+"' "
  cQuery+= "    AND DA3.D_E_L_E_T_ = '' "  

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryDA3, .F., .T. )

  cPlaca := (cQryDA3)->(DA3_PLACA)

	(cQryDA3)->(DbCloseArea())

Return cPlaca



/*Function RECLOCKDF8()   

Local cNumPrg    := GETSXENUM("DF8","DF8_NUMPRG")
Local nSomaPeso  := 0
Local nSeqDocDmd := 1
Local cTmpColDmd

ConfirmSX8()

RecLock("DF8",.T.)

DF8->DF8_FILIAL := xFilial("DF8")
DF8->DF8_FILORI := DL9->DL9_FILEXE
DF8->DF8_NUMPRG := cNumPrg
DF8->DF8_SERTMS := StrZero(3,Len(DF8->DF8_SERTMS))
DF8->DF8_DATGER := dDataBase
DF8->DF8_HORGER := StrTran(Left(Time(),5),":","")
DF8->DF8_STATUS := StrZero(1,Len(DF8->DF8_STATUS))
DF8->DF8_QTDVOL := 1
DF8->DF8_PESO   := nSomaPeso
DF8->DF8_SEQPRG := StrZero(1,Len(DF8->DF8_SEQPRG))
DF8->DF8_CODPLN := DL9->DL9_COD

DF8->(MsUnlock())

RecLock("DDZ",.T.)

DDZ->DDZ_FILIAL := xFilial("DDZ")
DDZ->DDZ_FILORI := DL9->DL9_FILEXE
DDZ->DDZ_NUMPRG := cNumPrg
DDZ->DDZ_SEQPRG := StrZero(1,Len(DDZ->DDZ_SEQPRG))
DDZ->DDZ_CODVEI := DL9->DL9_CODVEI
DDZ->DDZ_CODRB1 := DL9->DL9_CODRB1
DDZ->DDZ_CODRB2 := DL9->DL9_CODRB2
DDZ->DDZ_CODRB3 := DL9->DL9_CODRB3

DDZ->(MsUnlock())

RecLock("DD9",.T.)

DD9->DD9_FILIAL := xFilial("DD9")
DD9->DD9_FILORI := DL9->DL9_FILEXE
DD9->DD9_NUMPRG := cNumPrg
DD9->DD9_ITEM   := StrZero(nSeqDocDmd,Len(DD9->DD9_ITEM))
DD9->DD9_CLIREM := '000001'//(cTmpColDmd)->DL8_CLIDEV  
DD9->DD9_LOJREM := '01' //(cTmpColDmd)->DL8_LOJDEV 
DD9->DD9_FILDOC := '04'//(cTmpColDmd)->DT5_FILDOC
DD9->DD9_DOC    := '000000167'//(cTmpColDmd)->DT6_DOC
DD9->DD9_SERIE  := 'COL'//(cTmpColDmd)->DT6_SERIE
DD9->DD9_SEQPRG := StrZero(1,Len(DD9->DD9_SEQPRG))
DD9->DD9_SERTMS := '1'//(cTmpColDmd)->DT6_SERTMS

DD9->(MsUnlock())



Return .T. */

