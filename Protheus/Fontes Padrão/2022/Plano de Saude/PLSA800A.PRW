#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "PLSA800A.CH"
#DEFINE ARQUIVO_LOG "job_atunio_PLS800A.log"

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA800AЁ Autor Ё Michele Tatagiba     Ё Data Ё 02.04.2002 Ё╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Funcoes do cadastro de Planos - Continuacao do PLSA800     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus 7.10                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function GravaProd(nReg,nOpc,_nH)
    Local aAlias
    Local nI,nInd
    Local cSHeader
    Local cSCols
    Local cSVet
    Local cSql
    Local nCont
    Local aCmpSIP := {} //{<NOME_CAMPO>,<VALOR_CAMPO>,<APENAS_INCLUSAO>}
    LOCAL lCentralObr := GetNewPar("MV_PLSEXCO",.F.)//Indica se o sistema utilizara a atualizacao automatica da central de obrigacoes sempre que um cadastro relevante for alterado no Protheus
    Local lUsaSIP := "1" $ GetNewPar("MV_PLSTIPO","")
    Local lUsaSIB := "2" $ GetNewPar("MV_PLSTIPO","")
    Local lSIPSincrono := "1" $ GetNewPar("MV_PLOBRSI","1,2")
    Local lSIBSincrono := "2" $ GetNewPar("MV_PLOBRSI","1,2")
    Local lVer	:= nOpc
    Local  lAtuFam  := GetNewPar("MV_PATUSUB",.F.) //Define se o sistema ira exibir a perguntar se deseja replicar para o sub-contrato as alteracoes das faixas ou descontos.
    Local aCodProA	:= {}

    If lNewVer
        nOpcx := K_Incluir
        PlsSetForce(.t.)
        nOpc  := K_Incluir
    Endif

    If nOpcx <> K_Visualizar

        //Integracao HAT
        if GetNewPar("MV_PLSHAT","0") == "1"
            oBrwBB2HAT := oBrwCob
            if oBrwBB2HAT:lFilter
                oBrwBB2HAT:endFilter(.f.)
            endIf

            oBrwBRVHAT := oBrwGru
            if oBrwBRVHAT:lFilter
                oBrwBRVHAT:endFilter(.f.)
            endIf
            PLHAT800(nOpcx,M->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO),oBrwBB2HAT,oBrwBRVHAT)
        endIf
        //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        //Ё Inicio da Transacao...                                              Ё
        //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        Begin Transaction
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Atualiza cadastro do plano...                                       Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If nOpcx == K_Alterar .Or. nOpcx == K_Excluir
                BI3->(DbGoTo(nReg))
            Endif
            M->BI3_ALLRED := If(lChkRed,"1","0")
            M->BI3_ALLUSR := If(lChkUsr,"1","0")
            M->BI3_LIMTXA := nLimTXA

            If lCentralObr .AND. (lUsaSIP .OR.  lUsaSIB) .AND. M->BI3_INFANS <> '0'
                //Valida se os campos vinculados ao cadastro do SIP foram alterados

                If nOpcx == K_Incluir .OR. M->BI3_CODSEG != BI3->BI3_CODSEG

                    //Recupero o segmento SIP
                    DbSelectArea("BI6")
                    BI6->(DbSetOrder(1))
                    If BI6->(MsSeek(xFilial("BI6")+M->BI3_CODSEG))
                        aAdd(aCmpSIP,{"B3J_SEGMEN",BI6->BI6_SEGSIP,.F.})
                    EndIf

                EndIf
                //AlteraГЦo de Forma de ContrataГЦo
                If nOpcx == K_Incluir .OR. M->BI3_TIPCON != BI3->BI3_TIPCON

                    BII->(DbSetOrder(1))
                    If BII->(MsSeek(xFilial("BII")+M->BI3_TIPCON))
                        aAdd(aCmpSIP,{"B3J_FORCON",BII->BII_TIPPLA,.F.})
                    EndIf

                EndIf

                //Chamo a rotina genИrica que atualiza o NЗcleo de InformaГУes da Central de ObrigaГУes
                If Len(aCmpSIP) > 0 .OR. nOpcx == K_Excluir

                    aAreaBI3 := BI3->(GetArea())

                    //Guardo as variАveis para atualizaГЦo do sintetico sip
                    cCodProSip := M->(BI3_CODIGO+BI3_VERSAO)
                    cCodOpeSip := POSICIONE("BA0",1,xFilial("BA0")+M->BI3_CODINT,"BA0_SUSEP")//"324361"//

                    aAdd(aCmpSIP,{'B3J_FILIAL',xFilial('B3J'),.T.} )
                    aAdd(aCmpSIP,{'B3J_STATUS','1',.F. } )
                    aAdd(aCmpSIP,{'B3J_CODOPE',cCodOpeSip,.T. } )
                    aAdd(aCmpSIP,{'B3J_CODIGO',cCodProSip,.T. } )
                    aAdd(aCmpSIP,{'B3J_DESCRI',ALLTRIM(M->BI3_DESCRI),.T. } )

                    If lSIPSincrono .OR. lSIBSincrono
                        PLSAtuNIO("B3J",aCmpSIP,nOpcx)
                    Else
                        StartJob("PLJOBNIO",GetEnvServer(),.F.,cEmpAnt,cFilAnt,"B3J",aCmpSIP,nOpcx)
                    EndIf
                    BI3->(RestArea(aAreaBI3))

                EndIf
            EndIf

            PLUPTENC("BI3",nOpc)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Redes de Atendimento...                                             Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BB6_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BB6_VERSAO",M->BI3_VERSAO})
            oBrwRed:nOpc := nOpc
            oBrwRed:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Contabilidade ...                                                   Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BHT_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BHT_VERSAO",M->BI3_VERSAO})
            oBrwCtb:nOpc := nOpc
            oBrwCtb:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Coberturas...                                                       Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BB2_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BB2_VERSAO",M->BI3_VERSAO})
            oBrwCob:nOpc := nOpc
            oBrwCob:Grava(aChave)

            //Atualiza as coberturas dos beneficiАrios desse plano no NIO, somente se alterou segmentacao e/ou forma de contratacao
            If lCentralObr .AND. (lUsaSIP .OR.  lUsaSIB) .AND. oBrwCob:lAltered .AND. M->BI3_INFANS <> '0' .And. Len(aCmpSIP) > 0

                cTrbPla = "TrbPla"
                //Carrega beneficiАrios do plano
                If CarregaBenef(cTrbPla)

                    Do While !(cTrbPla)->(Eof())
                        //Chamo a rotina genИrica que atualiza o NЗcleo de InformaГУes da Central de ObrigaГУes
                        CarAtuNIO(cTrbPla,"4" ,nOpc, lUsaSIP)

                        (cTrbPla)->(DbSkip())
                    EndDo
                EndIf
                (cTrbPla)->(DbCloseArea())
            EndIf
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Coberturas x Usuarios Permitidos                                    Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BHD_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BHD_VERSAO",M->BI3_VERSAO})
            oBrwPCo:nOpc := nOpc
            oBrwPCo:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Usuarios Permitidos...                                              Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BT1_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BT1_VERSAO",M->BI3_VERSAO})
            oBrwUsr:nOpc := nOpc
            oBrwUsr:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Regras para novos depedentes...                                     Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BEK_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BEK_VERSAO",M->BI3_VERSAO})
            oBrwBEK:nOpc := nOpc
            oBrwBEK:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Regras para Carencia por tipo de internacao                         Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BYK_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BYK_VERSAO",M->BI3_VERSAO})
            oBrwBYK:nOpc := nOpc
            oBrwBYK:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Grupo de Carencia...                                                Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BAY_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BAY_VERSAO",M->BI3_VERSAO})
            oBrwBAY:nOpc := nOpc
            oBrwBAY:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Classe de Carencia..                                                Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BAN_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BAN_VERSAO",M->BI3_VERSAO})
            oBrwBAN:nOpc := nOpc
            oBrwBAN:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Grupo de Carencia X Classe de Carencia                              Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BAE_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BAE_VERSAO",M->BI3_VERSAO})
            oBrwBAE:nOpc := nOpc
            oBrwBAE:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Tipo de Prestador                                                   Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BCU_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BCU_VERSAO",M->BI3_VERSAO})
            oGetBCU:nOpc := nOpc
            oGetBCU:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Tipo de Prestador - Co-Participacao                                 Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BCW_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BCW_VERSAO",M->BI3_VERSAO})
            oGetBCW:nOpc := nOpc
            oGetBCW:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Municipios de Atendimento                                           Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BCZ_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BCZ_VERSAO",M->BI3_VERSAO})
            oGetBCZ:nOpc := nOpc
            oGetBCZ:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Municipios de Atendimento  - CO-PARTICIPACAO                        Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BGD_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BGD_VERSAO",M->BI3_VERSAO})
            oGetBGD:nOpc := nOpc
            oGetBGD:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Documentos obrigatorios...   ..                                     Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BQP_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BQP_VERSAO",M->BI3_VERSAO})
            oBrwBQP:nOpc := nOpc
            oBrwBQP:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Produtos Vinculados...                                              Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BT3_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BT3_VERSAO",M->BI3_VERSAO})
            oBrwPro:nOpc := nOpc
            oBrwPro:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Produtos Vinculados...                                              Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BT4_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BT4_VERSAO",M->BI3_VERSAO})
            oBrwFPa:nOpc := nOpc
            oBrwFPa:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Produtos Vinculados x Faixa Etaria                                  Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BJY_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BJY_VERSAO",M->BI3_VERSAO})
            oBrwPFai:nOpc := nOpc
            If !lNewVersao .or. oBrwPFai:lAltered
                oBrwPFai:Grava(aChave)
            EndIf
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Produtos X Situacoes Adversas                                       Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BGZ_CODINT",M->BI3_CODINT})
            aadd(aChave,{"BGZ_CODIGO",M->BI3_CODIGO})
            aadd(aChave,{"BGZ_VERSAO",M->BI3_VERSAO})
            oBrwSit:nOpc := nOpc
            oBrwSit:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Produtos X Cobraca de Identificacao de Usuario                      Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BJB_CODINT",M->BI3_CODINT})
            aadd(aChave,{"BJB_CODIGO",M->BI3_CODIGO})
            aadd(aChave,{"BJB_VERSAO",M->BI3_VERSAO})
            oBrwBJB:nOpc := nOpc
            oBrwBJB:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Versoes...                                                          Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            M->BIL_CODIGO := M->BI3_CODINT+M->BI3_CODIGO
            PLUPTENC("BIL",nOpc)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Forma Pagto...                                                      Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BJ3_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BJ3_VERSAO",M->BI3_VERSAO})
            oBrwFor:nOpc := nOpc
            oBrwFor:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verba x F. Desc													  Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            if PLSALIASEX("BKJ")
                aChave := {}
                aadd(aChave,{"BKJ_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
                aadd(aChave,{"BKJ_VERSAO",M->BI3_VERSAO})
                oBrwBKJ:nOpc := nOpc
                oBrwBKJ:Grava(aChave)
            endif
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Produto x Regiao													  Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BY9_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BY9_VERSAO",M->BI3_VERSAO})
            oBrwBY9:nOpc := nOpc
            oBrwBY9:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Controle interno de troca de versao de plano...                     Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If lNewVer
                dDataIni := M->BIL_DATINI
                cVersao  := M->BIL_VERSAO

                BIL->(DbSetOrder(1))
                BIL->(MsSeek(xFilial("BIL")+M->BI3_CODINT+M->BI3_CODIGO+cVersao))
                BIL->(DbSkip(-1))

                BIL->(RecLock("BIL",.F.))
                BIL->BIL_DATFIN := (dDataIni-1)
                BIL->(MsUnLock())
            Endif
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Gravacao das Formas de Cobranca do Produto...                       Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            For nInd := 1 To Len(aVetsFor)
                cAlias   := aVetsFor[nInd,2]
                cTipo    := aVetsFor[nInd,3]
                aVetTrab := aVetsFor[nInd,4]
                uTrbRec  := aVetsFor[nInd,5] // quando for enchoice e numero e
                // getdados e array
                If     cTipo == "0" // Enchoice
                    For nCont  := 1 To Len(aVetTrab)
                        cDado  := aVetTrab[nCont,1]
                        &cDado := aVetTrab[nCont,2]
                    Next
                    PLUPTENC(cAlias,If(uTrbRec==1,K_Incluir,nOpc))
                ElseIf cTipo == "1" // GetDados
                    STORE HEADER cAlias TO aHeader For .T.
                    aChave := {}
                    aadd(aChave,{cAlias+"_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
                    aadd(aChave,{cAlias+"_VERSAO",M->BI3_VERSAO})
                    PLUPTCOLS(cAlias,aVetTrab,aHeader,uTrbRec,nOpc,aChave)
                Endif
            Next
            BB3->(DbSetOrder(1))
            If BB3->(MsSeek(xFilial("BB3") + M->BI3_CODINT + M->BI3_CODIGO  + M->BI3_VERSAO ))
                aCodProA := PLSA800APR(BB3->BB3_CODFOR,M->BI3_CODINT + M->BI3_CODIGO,M->BI3_VERSAO)
            EndIf
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Gravacao das Formas de Cobтranca da Taxa de Adesao...                Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            For nInd := 1 To Len(aVetsTxF)
                cAlias   := aVetsTxF[nInd,2]
                cTipo    := aVetsTxF[nInd,3]
                aVetTrab := aVetsTxF[nInd,4]
                uTrbRec  := aVetsTxF[nInd,5] // quando for enchoice e numero e
                // getdados e array
                If     cTipo == "0" // Enchoice
                    For nCont  := 1 To Len(aVetTrab)
                        cDado  := aVetTrab[nCont,1]
                        &cDado := aVetTrab[nCont,2]
                    Next
                    PLUPTENC(cAlias,If(uTrbRec==0,K_Incluir,nOpc))
                ElseIf cTipo == "1" // GetDados
                    STORE HEADER cAlias TO aHeader For .T.
                    aChave := {}
                    aadd(aChave,{cAlias+"_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
                    aadd(aChave,{cAlias+"_VERSAO",M->BI3_VERSAO})
                    PLUPTCOLS(cAlias,aVetTrab,aHeader,uTrbRec,nOpc,aChave)
                Endif
            Next
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Gravacao das Formas de Cobranca dos Produtos Relacionados...        Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            For nInd := 1 To Len(aVetsOpc)
                cAlias   := aVetsOpc[nInd,2]
                cTipo    := aVetsOpc[nInd,3]
                aVetTrab := aVetsOpc[nInd,4]
                uTrbRec  := aVetsOpc[nInd,5] // quando for enchoice e numero e
                // getdados e array
                If     cTipo == "0" // Enchoice
                    For nCont  := 1 To Len(aVetTrab)
                        cDado  := aVetTrab[nCont,1]
                        &cDado := aVetTrab[nCont,2]
                    Next
                    PLUPTENC(cAlias,If(uTrbRec==0,K_Incluir,nOpc))
                ElseIf cTipo == "1" // GetDados
                    STORE HEADER cAlias TO aHeader For .T.
                    aChave := {}
                    aadd(aChave,{cAlias+"_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
                    aadd(aChave,{cAlias+"_VERSAO",M->BI3_VERSAO})
                    PLUPTCOLS(cAlias,aVetTrab,aHeader,uTrbRec,nOpc,aChave)
                Endif
            Next
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Grupo Coberturas...                                                 Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BRV_CODPLA",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BRV_VERSAO",M->BI3_VERSAO})
            oBrwGru:nOpc := nOpc
            oBrwGru:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Grupo Coberturas x Co-participacao                                  Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BHI_CODINT",M->BI3_CODINT})
            aadd(aChave,{"BHI_CODPLA",M->BI3_CODIGO})
            aadd(aChave,{"BHI_VERSAO",M->BI3_VERSAO})
            oBrwGCo:nOpc := nOpc
            oBrwGCo:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Grupo Coberturas x Co-participacao                                  Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BHJ_CODINT",M->BI3_CODINT})
            aadd(aChave,{"BHJ_CODPLA",M->BI3_CODIGO})
            aadd(aChave,{"BHJ_VERSAO",M->BI3_VERSAO})
            oBrwCoPar:nOpc := nOpc
            oBrwCoPar:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Tratamento Taxas de Adesao...                                       Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BJ9_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BJ9_VERSAO",M->BI3_VERSAO})
            oBrwAde:nOpc := nOpc
            oBrwAde:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Grava propriedades pagamento...                                     Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BMD_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BMD_VERSAO",M->BI3_VERSAO})
            oBrwPPg:nOpc := nOpc
            oBrwPPg:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Grava propriedades pagamento x procedimento...                      Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"BME_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
            aadd(aChave,{"BME_VERSAO",M->BI3_VERSAO})
            oBrwPPP:nOpc := nOpc
            oBrwPPP:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Grava PROD. X FATORES MULTIP. REEMB....                             Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"B31_CODINT",M->BI3_CODINT})
            aadd(aChave,{"B31_CODIGO",M->BI3_CODIGO})
            aadd(aChave,{"B31_VERSAO",M->BI3_VERSAO})

            oBrwB31:Grava(aChave)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Grava VIG. PROD. X FAT. MULT. REEMB ...                             Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aChave := {}
            aadd(aChave,{"B32_CODINT",M->BI3_CODINT})
            aadd(aChave,{"B32_CODIGO",M->BI3_CODIGO})
            aadd(aChave,{"B32_VERSAO",M->BI3_VERSAO})

            oBrwB32:Grava(aChave)

            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Desc Evento por Produto                 					          Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If PLSALIASEX("B60")
                aChave := {}
                aadd(aChave,{"B60_CODINT",M->BI3_CODINT})
                aadd(aChave,{"B60_CODPLA",M->BI3_CODIGO})
                aadd(aChave,{"B60_VERSAO",M->BI3_VERSAO})
                oBrwB60:nOpc := nOpc
                oBrwB60:Grava(aChave)
            Endif
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Desc Evento por Produto                 					          Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If PLSALIASEX("B61") .and. B61->(FieldPos('B61_CODIGO')) > 0 .and.;
                    B61->(FieldPos('B61_VERSAO')) > 0 .and. B61->(FieldPos('B61_CODPLA')) > 0 .and.;
                    B61->(FieldPos('B61_CODINT')) > 0
                aChave := {}
                aadd(aChave,{"B61_CODINT",M->BI3_CODINT})
                aadd(aChave,{"B61_CODPLA",M->BI3_CODIGO})
                aadd(aChave,{"B61_VERSAO",M->BI3_VERSAO})
                aadd(aChave,{"B61_CODIGO",M->BI3_CODINT+M->BI3_CODIGO})
                oBrwB61:nOpc := nOpc
                oBrwB61:Grava(aChave)
            Endif

            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Co-Part Evento por Produto                  					          Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If PLSALIASEX("B86") .and.;
                    B86->(FieldPos('B86_VERSAO')) > 0 .and. B86->(FieldPos('B86_CODPLA')) > 0 .and.;
                    B86->(FieldPos('B86_CODINT')) > 0
                aChave := {}
                aadd(aChave,{"B86_CODINT",M->BI3_CODINT})
                aadd(aChave,{"B86_CODPLA",M->BI3_CODIGO})
                aadd(aChave,{"B86_VERSAO",M->BI3_VERSAO})
                oBrwB86:nOpc := nOpc
                oBrwB86:Grava(aChave)
            Endif


            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Se existir registro para este produto nos Beneficios do Produto (bb2) atualiza BI3_INFCOB |
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BB2->(DbSetOrder(1))
            If BB2->(MsSeek(xFilial("BB2")+M->BI3_CODINT+M->BI3_CODIGO+M->BI3_VERSAO))
                BI3->(RecLock("BI3",.F.))
                BI3->BI3_INFCOB := '1'
                BI3->(MsUnLock())
            EndIf
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Se existir registro no grupo de cobertura (BRV) atualiza campo BI3_INFGCB                 |
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            BRV->(DbSetOrder(1))
            If BRV->(MsSeek(xFilial("BRV")+M->BI3_CODINT+M->BI3_CODIGO+M->BI3_VERSAO))
                BI3->(RecLock("BI3",.F.))
                BI3->BI3_INFGCB := '1'
                BI3->(MsUnLock())
            EndIf
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Fim do controle de semafaro iniciado em PLSA800OK                   Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If nOpcx == K_Incluir .and. lVer <> 6
                PLSFechaSem(_nH,"PLSA800.SMF")
            Endif
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Fim da Transacao...                                                 Ё
            //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        End Transaction

        If ExistBlock("PLSPROMN")
            ExecBlock("PLSPROMN",.F.,.F.,{nOpcx})
        Endif
    Endif
    If lAtuFam .and. lHaAltFor
        PLSA800CHK(aCodProA)
    EndIf
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Fim da Rotina Principal...                                          Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    PlsSetForce(.f.)
Return

/*/{Protheus.doc} CarregaBenef

Retorna familias/beneficiАrios que usam o plano alterado

@paramc cTrb		Nome da Аrea de trabalho que deve ser criada

@return lRet Retorna .T. se encontrou algum beneficiАrio, senao retorna .F. Falso

@author TOTVS PLS Team
@since 08/01/2016
/*/
Static Function CarregaBenef(cTrb)

    Local cSql := ""
    Local lRet := .F.

    cSql := " SELECT BA1_CODINT,BA1_CODEMP,BA1_CONEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_CODPLA,BA1_VERSAO,BA1_ESTADO "
    cSql += " ,BA1_DATCAR,BA1_VERCON,BA1_SUBCON,BA1_VERSUB,BA1_SEXO,BA1_CODCCO,BA1_DATNAS,BA1_DATINC,BA1_DATBLO,BA3_CODPLA,BA3_VERSAO,BA3_ESTADO,BA1_MATVID,BA1_NOMUSR,BA1_MAE "
    cSql += " ,BA1_CPFUSR,BA1_CPFMAE,BA1_CPFPRE,BA1_MATANT,BA3_CODINT,BA3_CODEMP,BA3_MATRIC,BA1_TIPUSU,BA1_VERSAO,BA1_TRAORI,BA1_TRADES,BA1_PLPOR,BA3_GRPFAM "
    cSql += " ,BA3_CONEMP,BA3_VERCON,BA3_SUBCON,BA3_VERSUB,BA3_PLPOR,BA3_TIPOUS,BA1_GRAUPA,BA1_TIPEND,BA1_RESEXT,BA1_ENDERE,BA1_NR_END,BA1_COMEND,BA1_BAIRRO,BA1_CODMUN,BA1_CEPUSR"
    cSql += " ,BA1_MUNRES,BA1_PISPAS,BA1_MOTBLO,BA1_OPEORI,BA3_CODCLI,BA3_LOJA,BA3_DATBLO,BA1_MUNICI,BA1_LOCSIB,BA1_EXCANS,BA1_INFANS "
    cSql += " FROM " + RetSqlName("BA3") + "	, " + RetSqlName("BA1") + " "
    cSql += " WHERE BA3_FILIAL = '" + xFilial("BA3") + "' "
    cSql += "   AND BA1_FILIAL = '" + xFilial("BA1") + "'"
    cSql += "   AND BA3_CODINT = '" + M->BI3_CODINT + "' "
    cSql += "   AND BA1_CODINT = '" + M->BI3_CODINT + "' "
    cSql += "   AND BA3_CODEMP = BA1_CODEMP "
    cSql += "   AND BA3_MATRIC = BA1_MATRIC "
    cSql += "   AND BA3_CONEMP = BA1_CONEMP "
    cSql += "   AND BA3_VERCON = BA1_VERCON "
    cSql += "   AND BA3_SUBCON = BA1_SUBCON "
    cSql += "   AND BA3_VERSUB = BA1_VERSUB "
    cSql += "   AND BA1_DATBLO = '' "
    cSql += "   AND BA3_DATBLO = '' "
    cSql += "   AND ( "
    cSql += "        (BA1_CODPLA = '" + M->BI3_CODIGO + "'	AND BA1_VERSAO = '" + M->BI3_VERSAO + "'	) "
    cSql += " 			OR (BA1_CODPLA = '' AND BA3_CODPLA = '" + M->BI3_CODIGO + "' AND BA3_VERSAO = '" + M->BI3_VERSAO + "' )"
    cSql += "      )"
    cSql := ChangeQuery(cSql)

    If Select(cTrb) > 0
        (cTrb)->(DbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cTrb,.F.,.T.)

    lRet := !(cTrbPla)->(Eof())

Return lRet

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA660PRD╨ Autor Ё PLS   ╨ Data Ё 23/10/2012  ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Verifica alteracoes de Faixas Etarias e Descontos do Sub   ╨╠╠
╠╠╨          Ё Contrato.                                                  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SigaPLS                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function PLSA800APR( cCodPagX , cCodProX , cVersaoX )

    Local cChaveX		:= ""
    Local aRet          := {}

    Default cCodPagX	:= ""
    Default cCodProX	:= ""
    Default cVersaoX	:= ""

    If Empty(cCodPagX) .Or. Empty(cCodProX) .Or. Empty(cVersaoX)
        Return()
    EndIf

    cChaveX := cCodPagX + cCodProX + cVersaoX

    If Empty(aRet) .Or. AScan( aRet , cChaveX ) == 0
        aAdd( aRet , { cChaveX , cCodProX , cVersaoX , cCodPagX } )
    EndIf

Return aRet

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA660CHK╨ Autor Ё PLS   ╨ Data Ё 31/10/2018  ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Verifica alteracoes de Faixas Etarias e Descontos do       ╨╠╠
╠╠╨          Ё Produto                                                    ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SigaPLS                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSA800CHK(aCodProA )

    Local nI := 0
    Local nX := 0
    Local nY := 0
    Local nJ := 0
    Local aDadFai		:= {}
    Local aDadDes		:= {}
    Local cChvBA1		:= ""
    Local aChvBA1		:= {}
    Local cChvBA3		:= ""
    Local aChvBA3		:= {}
    Local cChvBB3       := ""
    Local cChvBBU       := ""
    Local lDeleta       := .F.
    Local lNovo		:= .T.
    Local cChvBFS   := ""
    Local cChvBFY    	:= ""
    Local cCodProX	:= ""
    Local cVersaoX	:= ""
    Local cCodPagX	:= ""
    Local cCodIntX  := ""
    Local cCodEmpX	:= ""
    Local cMsgX		:= ""

    Private lCheck01	:= .T.
    Private lCheck02	:= .T.
    Private lAllChk 	:= .T.
    Private oCheck01
    Private oCheck02
    Private oChkAll

    cAlert := STR0001//Foram identificadas alteraГУes nas propriedades da forma de cobranГa"
    cAlert += " " + STR0002//' dos produtos do contrato. Selecione os nМveis especМficos para'
    cAlert += " " +  STR0003//' realizar a atualizaГЦo ou clique em "Cancelar" para manter os dados atuais:'

    DEFINE DIALOG oDlgChk TITLE STR0004 FROM 0,0 TO 220,410 PIXEL

    @ 01,05 TO 35,205 PIXEL OF oDlgChk LABEL STR0005//"RИplica das propriedades de cobranГa"

    @ 08,07 SAY oSayCon PROMPT cAlert SIZE 200,35 OF oDlgFolder PIXEL

    @ 50,06 CHECKBOX oCheck01 VAR lCheck01 PROMPT STR0006 PIXEL SIZE 300, 09 OF oDlgChk //"BBU - Faixas EtАrias da familia"
    @ 60,06 CHECKBOX oCheck02 VAR lCheck02 PROMPT STR0007 PIXEL SIZE 300, 09 OF oDlgChk //"BFY - Descontos por Familias"

    @ 85,06 BUTTON oBotOk 	PROMPT "&Ok" 		ACTION	{|| lProc := .T. , oDlgChk:End()} SIZE 45, 11 OF oDlgChk PIXEL
    @ 85,53 BUTTON oBotCan 	PROMPT STR0008	ACTION	{|| lProc := .F. , oDlgChk:End()} SIZE 45, 11 OF oDlgChk PIXEL //"&Cancelar"

    @ 100,06 CHECKBOX oChkAll VAR lAllChk PROMPT STR0009 PIXEL SIZE 300, 09 OF oDlgChk //"Marcar/Desmarcar todos"
    oChkAll:bChange := {||CheckAll()}

    ACTIVATE DIALOG oDlgChk CENTERED

    If Len(aCodProA) > 0 .And. !Empty(aCodProA)

        cMsgX := STR0010 + CRLF //"Log de atualizaГЦo das propriedades das formas de cobranГa dos produtos:"
        cMsgX += Replicate("-",50) + CRLF

        cMsgX += STR0011 + CRLF //"Tabelas selecionados para atualizaГЦo:"
        cMsgX += Iif(lCheck01,STR0006 + CRLF,"") //"BBU - Faixas EtАrias da familia"
        cMsgX += Iif(lCheck02,STR0007 + CRLF,"") //"BFY - Descontos por Familias"

        cMsgX += Replicate("-",50) + CRLF

        For nI := 1 TO Len(aCodProA)
            cCodProX := SubStr(aCodProA[nI][2],5,4)
            cVersaoX := aCodProA[nI][3]
            cCodPagX := aCodProA[nI][4]
            cCodIntX := SubStr(aCodProA[nI][2],1,4)

            cMsgX	+= STR0012 + AllTrim( Posicione("BI3",1,xFilial("BI3")+cCodIntX+cCodProX+cVersaoX,"BI3_DESCRI") ) +"/"+ cVersaoX + CRLF //" - Produto/VersЦo: "
            cMsgX	+= STR0013 + AllTrim( Posicione("BJ1",1,xFilial("BJ1")+cCodPagX,"BJ1_DESCRI") )+ CRLF //" - Forma de Pagamento: "

            DBSelectArea("BA3") //LEVANTAMENTO DO NUMERO DE FAMILIAS
            cChvBA3 := xFilial("BA3") + cCodIntX + cCodProX + cVersaoX + cCodPagX
            BA3->(DbSetOrder(12))// BA3_FILIAL + BA3_CODINT + BA3_CODPLA + BA3_VERSAO + BA3_FORPAG
            If BA3->(DBSeek(cChvBA3))
                While BA3->(!Eof()) .And. BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG) == cChvBA3
                    If Empty(BA3->BA3_DATBLO) .And. Empty(BA3->BA3_MOTBLO) .And. Empty(BA3->BA3_CONEMP)
                        aAdd(aChvBA3 , {( BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_MATRIC + BA3->BA3_FORPAG ) , BA3->BA3_MATRIC , BA3->BA3_FORPAG , BA3->(Recno()) } )
                    EndIf
                    BA3->(DBSkip())
                EndDo
            EndIf

            aDadFai := {}
            DBSelectArea("BB3") //LEVANTAMENTO DO NUMERO DE REGISTROS DA FAIXA ETARIA DO GRUPO
            cChvBB3 := xFilial("BB3") + cCodIntX + cCodProX + cVersaoX + cCodPagX
            BB3->(DBSetOrder(1))//BB3_FILIAL+BB3_CODIGO+BB3_VERSAO+BB3_CODFOR

            If BB3->(DBSeek(cChvBB3))
                While BB3->(!Eof()) .And. BB3->(BB3_FILIAL+BB3_CODIGO+BB3_VERSAO+BB3_CODFOR) == cChvBB3
                    aAdd(aDadFai, {;
                        BB3->BB3_CODFAI,;
                        BB3->BB3_IDAINI,;
                        BB3->BB3_IDAFIN,;
                        BB3->BB3_VALFAI,;
                        BB3->BB3_QTDMIN,;
                        BB3->BB3_QTDMAX,;
                        BB3->BB3_TIPUSR,;
                        BB3->BB3_GRAUPA,;
                        BB3->BB3_SEXO,;
                        BB3->BB3_TABVLD})
                    BB3->(DbSkip())
                EndDo
            EndIf

            //BBU - Faixa EtАrias da famМlia
            If lCheck01
                Begin Transaction
                    cMsgX	+= " " + STR0014 + CRLF //"Atualizando Faixas EtАrias da familia - BBU..."

                    If Empty(aChvBA3)
                        cMsgX += Replicate("-",25) + CRLF
                        cMsgX += STR0015 + CRLF //"NЦo foram encontrados registros para Atualizar as Faixas EtАrias do Grupo (BBU)."
                    Else
                        cMsgX += Replicate("-",25) + CRLF
                        cMsgX += STR0006 + CRLF //"BBU - Faixas EtАrias da familia"
                        cMsgX += STR0016+ cValToChar(Len(aChvBA3)) +STR0017 + CRLF // " Foram selecionadas [" ## "] faixas etАrias da familia para Atualizar."

                        //DELECAO DOS REGISTROS DA FAIXA ETARIA DA FAMILIA
                        For nX := 1 To Len(aChvBA3)
                            DBSelectArea("BBU")
                            cChvBBU := xFilial("BBU") + aChvBA3[nX][01]// BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_MATRIC + BA3->BA3_FORPAG
                            BBU->(DBSetOrder(1))//BBU_FILIAL + BBU_CODOPE + BBU_CODEMP + BBU_MATRIC + BBU_CODFOR + BBU_CODFAI
                            If BBU->( DBSeek( cChvBBU ) )
                                While BBU->(!Eof()) .And. BBU->( BBU_FILIAL + BBU_CODOPE + BBU_CODEMP + BBU_MATRIC + BBU_CODFOR ) == cChvBBU
                                    lDeleta := .T.

                                    For nY := 1 To Len( aDadFai )

                                        If aDadFai[nY][01] == BBU->BBU_CODFAI  //Codigos iguais o sistema nЦo deleta para poder atualizar/alterar os dados.
                                            lDeleta := .F.
                                        EndIf

                                    Next nY

                                    If lDeleta //caso sistema nЦo encontrar o codigo da faixa da BB3(faixa etaria do produto) nos cСdigos da BBU(faixa etaria do grupo) ira deletar

                                        RecLock( "BBU" , .F. )
                                        BBU->( DBDelete() )
                                        BBU->( MSUnlock() )

                                    EndIf
                                    BBU->(DBSkip())
                                EndDo
                            EndIf
                        Next nX

                        If !Empty(aDadFai)

                            For nX := 1 To Len( aChvBA3 )
                                cCodEmpX := SubStr(aChvBA3[nX][1],5,4)
                                For nY := 1 To Len( aDadFai )

                                    lNovo := .T.

                                    DBSelectArea("BBU")
                                    cChvBBU := xFilial("BBU") + aChvBA3[nX][01]
                                    BBU->(DBSetOrder(2))//BBU_FILIAL+BBU_CODOPE+BBU_CODEMP+BBU_MATRIC+BBU_CODFOR+BBU_SEXO+BBU_TIPUSR+BBU_GRAUPA
                                    If BBU->( DBSeek( cChvBBU ) )
                                        While BBU->(!Eof()) .And. BBU->( BBU_FILIAL + BBU_CODOPE + BBU_CODEMP + BBU_MATRIC + BBU_CODFOR ) == cChvBBU
                                            If BBU->BBU_CODFAI == aDadFai[nY][01]
                                                If BBU->BBU_IDAINI <> aDadFai[nY][02] .Or. BBU->BBU_IDAFIN <> aDadFai[nY][03] .Or. BBU->BBU_VALFAI <> aDadFai[nY][04]
                                                    RecLock( "BBU" , .F. )
                                                    BBU->BBU_ANOMES	:= cValToChar( Year( Date() ) ) + StrZero( Month( Date() ) , 2 )
                                                    BBU->BBU_IDAINI	   := aDadFai[nY][02]
                                                    BBU->BBU_IDAFIN	   := aDadFai[nY][03]
                                                    If BBU->BBU_VALFAI <> aDadFai[nY][04]
                                                        BBU->BBU_VLRANT	:= BBU->BBU_VALFAI
                                                        BBU->BBU_VALFAI  	:= aDadFai[nY][04]
                                                    EndIf
                                                    BBU->BBU_TIPUSR		:= aDadFai[nY][07]
                                                    BBU->BBU_GRAUPA	:= aDadFai[nY][08]
                                                    BBU->BBU_SEXO		:= aDadFai[nY][09]
                                                    BBU->BBU_TABVLD	:= aDadFai[nY][10]
                                                    BBU->( MSUnlock() )
                                                EndIf
                                                lNovo := .F.
                                            EndIf
                                            BBU->(DBSkip())
                                        EndDo
                                    EndIf

                                    If lNovo
                                        BBU->( RecLock( "BBU" , .T. ) )
                                        BBU->BBU_FILIAL	:= xFilial("BBU")
                                        BBU->BBU_CODOPE	:= cCodIntX
                                        BBU->BBU_CODEMP	:= cCodEmpX
                                        BBU->BBU_MATRIC	:= aChvBA3[nX][02]
                                        BBU->BBU_CODFOR	:= aChvBA3[nX][03]
                                        BBU->BBU_CODFAI	:= aDadFai[nY][01]
                                        BBU->BBU_IDAINI	:= aDadFai[nY][02]
                                        BBU->BBU_IDAFIN	:= aDadFai[nY][03]
                                        BBU->BBU_VALFAI	:= aDadFai[nY][04]
                                        BBU->BBU_TIPUSR	:= aDadFai[nY][07]
                                        BBU->BBU_GRAUPA	:= aDadFai[nY][08]
                                        BBU->BBU_SEXO		:= aDadFai[nY][09]
                                        BBU->BBU_TABVLD	:= aDadFai[nY][10]
                                        BBU->( MSUnlock() )
                                    EndIf

                                Next nY

                            Next nX

                        EndIf

                    EndIf

                End Transaction
            EndIf

            //Recuperando informaГУes relativas aos descontos do produto
            DBSelectArea("BFS")
            cChvBFS := xFilial("BFS") + cCodIntX + cCodProX + cVersaoX + cCodPagX
            BFS->(DBSetOrder(1)) //BFS_FILIAL+BFS_CODIGO+BFS_VERSAO+BFS_CODFOR
            If BFS->(DBSeek(cChvBFS))

                While BFS->(! Eof()) .And. BFS->(BFS_FILIAL + BFS_CODIGO + BFS_VERSAO + BFS_CODFOR ) == cChvBFS
                    aAdd(aDadDes, {BFS->BFS_CODFAI,;
                        BFS->BFS_TIPUSR,;
                        BFS->BFS_GRAUPA,;
                        BFS->BFS_TIPO,;
                        BFS->BFS_PERCEN,;
                        BFS->BFS_VALOR,;
                        BFS->BFS_QTDDE,;
                        BFS->BFS_QTDATE,;
                        BFS->BFS_DATDE,;
                        BFS->BFS_DATATE,;
                        BFS->BFS_CODFOR })

                    BFS->(DBSkip())
                EndDo

            EndIf

            //Descontos por famМlia
            If lCheck02

                If Empty(aChvBA3) .Or. Empty(aDadDes)

                    cMsgX += Replicate("-",25) + CRLF
                    cMsgX += STR0018 + CRLF //"NЦo foram encontrados registros para Atualizar as Faixas EtАrias de desconto no NМvel da famМlia (BFY)."

                Else

                    cMsgX += Replicate("-",25) + CRLF
                    cMsgX += STR0007 + CRLF //"BFY - Descontos por Familias"
                    cMsgX += STR0016+ cValToChar(Len(aChvBA3)) +STR0019 + CRLF // " Foram selecionadas [" ## "] faixas de descontos da FamМlia para Atualizar."

                    Begin Transaction

                        cMsgX += STR0020 + CRLF //"Atualizando os Descontos por familia(BFY)....."

                        //apagando faixas que nЦo existem mais no produto
                        For nX := 1 TO Len(aChvBA3)

                            DBSelectArea("BFY")
                            cChvBFY := xFilial("BFY") + aChvBA3[nX][01]
                            BFY->( DBSetOrder(1) )
                            If BFY->(DBSeek( cChvBFY))

                                While BFY->(!Eof()) .And. (BFY->BFY_FILIAL+BFY->BFY_CODOPE+BFY->BFY_CODEMP+BFY->BFY_MATRIC+BFY->BFY_CODFOR ) == cChvBFY
                                    RecLock( "BFY" , .F. )
                                    BFY->( DBDelete() )
                                    BFY->( MSUnlock() )
                                    BFY->(DBSkip())
                                EndDo

                            EndIf

                        Next nX

                        //Atualiza/Cria faixas no cadastro de descontos em nМvel famМlia
                        If !Empty(aDadFai)

                            For nX := 1 To Len( aChvBA3 )
                                cCodEmpX := SubStr(aChvBA3[nX][1],5,4)
                                For nY := 1 To Len( aDadFai )
                                    For nJ:= 1 to Len(ADaddES)

                                        If ADadFai[nY,01] <> aDadDes[nJ][01]
                                            Loop
                                        Endif

                                        BFY->( RecLock( "BFY" , .T. ) )
                                        BFY->BFY_FILIAL := xFilial("BFY")
                                        BFY->BFY_CODOPE := cCodIntX
                                        BFY->BFY_CODEMP := cCodEmpX
                                        BFY->BFY_MATRIC := aChvBA3[nX][02]
                                        BFY->BFY_CODFAI := aDadDes[nJ][01]
                                        BFY->BFY_TIPUSR := aDadDes[nJ][02]
                                        BFY->BFY_GRAUPA := aDadDes[nJ][03]
                                        BFY->BFY_TIPO	  := aDadDes[nJ][04]
                                        BFY->BFY_PERCEN := aDadDes[nJ][05]
                                        BFY->BFY_VALOR  := aDadDes[nJ][06]
                                        BFY->BFY_QTDDE  := aDadDes[nJ][07]
                                        BFY->BFY_QTDATE := aDadDes[nJ][08]
                                        BFY->BFY_DATDE  := aDadDes[nJ][09]
                                        BFY->BFY_DATATE := aDadDes[nJ][10]
                                        BFY->BFY_CODFOR := aDadDes[nJ][11]
                                        BFY->BFY_AUTOMA := "1"
                                        BFY->( MSUnlock() )

                                    Next nJ
                                Next nY
                            Next nX
                        EndIf

                    End Transaction

                EndIf

            EndIf

        Next nI

    EndIf

    If lProc
        //Exibe o Log

        DEFINE MSDIALOG oDlgLog TITLE "AtualizaГЦo concluМda." From 3,0 to 340,417 PIXEL

        @ 5,5 GET oMemo  VAR cMsgX MEMO SIZE 200,145 OF oDlgLog PIXEL
        oMemo:bRClicked := {||AllwaysTrue() }
        DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgLog:End() ENABLE OF oDlgLog PIXEL //Apaga
        ACTIVATE MSDIALOG oDlgLog CENTER

    EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckAll
FunГЦo para Marcar/Desmarcar todos
@author  Vinicius.Queiros
@version P12
@since   28/09/2020
/*/
//-------------------------------------------------------------------

Static Function CheckAll()

    Local nFor
    Local cNomChk	:= "lCheck"
    Local cNomObj	:= "oCheck"
    Local nQtdChk 	:= 2

    lAllChk := !lAllChk

    For nFor := 1 to nQtdChk
        &(cNomChk + StrZero(nFor,2)) := !lAllChk
        &(cNomObj + StrZero(nFor,2) + ":Refresh()")
    Next

Return
