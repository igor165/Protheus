#include "protheus.ch"
#include "PLSUA1300.ch"
#define _QTD_REG_ 50000

/* ------------------------ STR com a Solução de Cada Tag ------------------------

STR0001 : dt_excl_uni               STR0026 : dt_inicio_vigencia        STR0051 : cd_caepf
STR0002 : motivo_exclusao_benef     STR0027 : dt_fim_vigencia           STR0052 : nm_empr_comp
STR0003 : reg_plano_ans             STR0028 : tp_abrangencia            STR0053 : nm_fantasia_empr
STR0004 : dt_fim_vigencia           STR0029 : tp_contratacao            STR0054 : tp_logradouro
STR0005 : nm_compl_benef            STR0030 : tp_acomodacao             STR0055 : ds_lograd
STR0006 : dt_nasc                   STR0031 : id_reg_plano_ans          STR0056 : nr_lograd
STR0007 : tp_sexo                   STR0032 : reg_plano_ans             STR0057 : cd_munic
STR0008 : cd_cpf                    STR0033 : seg_plano                 STR0058 : nr_cep
STR0009 : id_estrangeiro            STR0034 : cd_rede                   STR0059 : nr_ddd
STR0010 : cd_cns                    STR0035 : via_cartao                STR0060 : nr_fone
STR0011 : cd_est_civil              STR0036 : dt_val_carteira           STR0061 : end_email
STR0012 : nm_mae                    STR0037 : cd_lcat                   STR0062 : nm_benef
STR0013 : cd_munic                  STR0038 : id_cpt                    STR0063 : dt_nasc
STR0014 : nm_benef                  STR0039 : dt_fim_cpt                STR0064 : tp_sexo
STR0015 : cd_depe                   STR0040 : tp_contrato               STR0065 : cd_cnpj
STR0016 : dt_incl_uni               STR0041 : raz_soc_adm_benef         STR0066 : cd_aut_gest_ans
STR0017 : id_sib                    STR0042 : nm_adm_benef              STR0067 : dt_incl
STR0018 : id_benef_coop             STR0043 : nm_produto
STR0019 : cd_crm                    STR0044 : dt_contr_plano
STR0020 : cd_uf_conselho            STR0045 : tipo_rede_min
STR0021 : cd_cnpj                   STR0046 : cd_munic
STR0022 : tp_com_risco              STR0047 : cd_uf
STR0023 : dt_comp_risco             STR0048 : tp_cobertura
STR0024 : cd_uni_des_com            STR0049 : dt_fim_carencia
STR0025 : id_Benef_des              STR0050 : cd_cnpj
-----------------------------------------------------------------------------------*/

/*/{Protheus.doc} XMLA1300
Classe geradora do arquivo XML do PTUA1300.

@owner TOTVS
@author Gabriel Hegler Klok
/*/
class XMLA1300
    data oPTUA1300
    data cTpEnv
    data cLayout
    data cFilename
    data nSeqFile
    data nQtdFile
    data aQtdReg

    method new( cTpEnv, cLayPTU ) constructor
    method setDataFile(cDirNov, cArqNom)
    method fileXML()
endclass

/*/{Protheus.doc} new
Metodo construtor da classe XMLA1300.

@author Gabriel Hegler Klok

@type method
@since 2019/11
@version 1.0

@param cTpEnv, caracter, Tipo de envio que esta sendo realizado.
@param cLayout, caracter, Layout utilizado no PTUA1300.

@return self, object, Instancia do objeto da classe XMLA1300
/*/
method new( cTpEnv, cLayout, cFolder, cFileName ) class XMLA1300
    self:cTpEnv := cTpEnv
    self:cLayout := cLayout

    self:oPTUA1300 := plsxmlptu():new()
    self:oPTUA1300:cLayPTU := cLayout
    self:oPTUA1300:cSchema := "ptu_A1300.xsd"
    self:oPTUA1300:cFolder := alltrim(cFolder)
    self:oPTUA1300:cFilename := alltrim(cFileName)

    self:cFilename := alltrim(cFileName)
return self

/*/{Protheus.doc} setDataFile
Metodo para definir atributos do arquivo que sera gerado.

@author Gabriel Hegler Klok

@type method
@since 2019/11
@version 1.0

@param cFolder, caracter, Diretorio de destino do arquivo XML.
@param cFileName, caracter, Nome do arquivo que será gerado.
@param nSeq, numeric, Numero sequencial do arquivo.
@param nQtd, numeric, Numero total de arquivos a serem gerados.
/*/
method setDataFile(nSeq, nQtd, aQtdReg) class XMLA1300
    self:nSeqFile := nSeq
    self:nQtdFile := nQtd
    self:aQtdReg  := aQtdReg
return

/*/{Protheus.doc} fileXML
Metodo que realiza a construcao das tag XML e gera o arquivo fisico.

@author Gabriel Hegler Klok

@type method
@since 2019/11
@version 1.0
/*/
method fileXML() class XMLA1300
    self:oPTUA1300:cFileName := self:cFilename + "." + Substr(T301->CD_UNI_ORI,2,3)//strzero(self:nSeqFile, 3)
    self:oPTUA1300:iniFile('ptuA1300' , 'ISO-8859-1')
    cabecalho(self:oPTUA1300)
    self:oPTUA1300:montatag(1, 'arquivoA1300',,, .t.,,,, .f.)

    if self:cTpEnv = 1 .or. self:cTpEnv = 2
        tipoDeEnvioMassa(self:oPTUA1300, strzero(self:nSeqFile, 4), iif(self:nSeqFile = self:nQtdFile, 'S', 'N') )
    else
        tipoEnvio(self:oPTUA1300, self:cTpEnv, self:aQtdReg)
    endif

    self:oPTUA1300:montatag(1, 'arquivoA1300',,, .f., .t.,,, .f.)

    self:oPTUA1300:cstrhash := fwcutoff(EncodeUtf8( self:oPTUA1300:cstrhash, 'ISO-8859-1'),.t.)
    self:oPTUA1300:calchash()
    self:oPTUA1300:montatag(1, 'hash', self:oPTUA1300:cHashMD5,,,,,, .f.)
    self:oPTUA1300:montatag(0, 'ptuA1300',,, .f., .t.,,, .f.)
    self:oPTUA1300:cxml := fwcutoff(EncodeUtf8( self:oPTUA1300:cxml, 'ISO-8859-1'),.t.)

    self:oPTUA1300:geraXML(.t.)

return self:oPTUA1300:aCriticas


/*/{Protheus.doc} cabecalho
Função que realiza a construção das tag do cabeçalho do arquivo,
obedecendo o layout 301.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300
/*/
static function cabecalho(oObj)
    oObj:montatag(1, 'cabecalho',,, .t.,,,, .f.)
    oObj:montatag(2, 'nrVerTra_PTU', T301->NRVTRA_PTU, .t.,,,,, .t.)
    oObj:montatag(2, 'unimed',,, .t.,,,, .f.)
    oObj:montatag(3, 'cd_Uni_Destino', T301->CD_UNI_DES, .t.,,,,, .t.)
    oObj:montatag(3, 'cd_Uni_Origem', T301->CD_UNI_ORI, .t.,,,,, .t.)
    oObj:montatag(2, 'unimed',,, .f., .t.,,, .f.)
    oObj:montatag(2, 'dt_geracao', T301->DT_GERACAO, .t.,,,,, .t.)
    oObj:montatag(1, 'cabecalho',,, .f., .t.,,, .f.)
return


/*/{Protheus.doc} tipoEnvio
Função realiza a construção das tag XML refentes ao tipo de envio.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300.
@param nTpEnv, numeric, Tipo de envio que está sendo realizado.
/*/
static function tipoEnvio(oObj, nTpEnv, aQtdReg)
    local nNumInc
    local nNumAut
    local aTmp

    aTmp := aQtdReg[1]
    asort(aTmp)
    nNumInc := atail(aTmp)

    aTmp := aQtdReg[2]
    asort(aTmp)
    nNumAut := atail(aTmp)

    oObj:montatag(2, 'tiposdeenvio',,, .t.,,,, .f.)

    if nTpEnv = 3 .and. nNumInc > 0
        tipoInclusao(oObj, 3)
    endif

    if nTpEnv = 3 .and. nNumAut > 0
        tipoAlteracao(oObj, 3)
    endif

    if (! T316->(eof()) .or. nTpEnv = 4) .and. aQtdReg[3] > 0
        tipoExclusao(oObj, 3)
    endif

    oObj:montatag(2, 'tiposdeenvio',,, .f., .t.,,, .f.)
return

/*/{Protheus.doc} tipoInclusao
Função realiza a construção das tags XML para o tipo de envio 'Inclusao'.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300
@param nNv, numeric, Nível atual da tag XML.
/*/
static function tipoInclusao(oObj, nNv)
    oObj:montatag(nNv, 'tipoinclusao',,, .t.,,,, .f.)
    empresasContratantes(oObj, nNv+1)
    dadosDasPessoas(oObj, nNv+1, 'I')
    dadosAutoGestao(oObj, nNv+1, 'I')
    oObj:montatag(nNv, 'tipoinclusao',,, .f., .t.,,, .f.)
return

/*/{Protheus.doc} tipoAlteracao
Função realiza a construção tags XML para o tipo de envio 'Alteracao'.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param, oObj, object, Objeto da classe XMLA1300.
@param, nNv, numeric, Nivel atual da tag XML.
/*/
static function tipoAlteracao(oObj, nNv)
    oObj:montatag(nNv, 'tipoalteracao',,, .t.,,,, .f.)
    empresasContratantes(oObj, nNv+1)
    dadosDasPessoas(oObj, nNv+1, 'A')
    dadosAutoGestao(oObj, nNv+1, 'A')
    oObj:montatag(nNv, 'tipoalteracao',,, .f., .t.,,, .f.)
return

/*/{Protheus.doc} tipoExlusao
Função geradora das tags XML para o tipo de envio 'Exclusao'.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300.
@param nNv, numeric, Nível atual da tag XML.
/*/
static function tipoExclusao(oObj, nNv)
    local nCount316 := 0

    T316->(dbgotop()) // Posiciona no primeiro registro

    oObj:montatag(nNv, 'tipoexclusao',,, .t.,,,, .f.)

    while ! T316->(eof()) .and. nCount316 < _QTD_REG_
        nCount316++

        oObj:montatag(nNv+1, 'beneficiariosexcluidos',,, .t.,,,, .f.)
        oObj:montatag(nNv+2, 'identificacaoBenef',,, .t.,,,, .f.)
        oObj:montatag(nNv+3, 'cd_Unimed', T316->CD_UNIMED, .t.,,,,, .t.)
        oObj:montatag(nNv+3, 'id_Benef', T316->ID_BENEF, .t.,,,,, .t.)
        oObj:montatag(nNv+2, 'identificacaoBenef',,, .f., .t.,,, .f.)
        oObj:montatag(nNv+2, 'dt_excl_uni',T316->DT_EXC_UNI, .t.,,,,, .t.,STR0001)
        oObj:montatag(nNv+2, 'motivo_exclusao_benef', T316->MOT_EXCBEN, .t.,,,,, .t.,STR0002)

        //TODO criar campos novos, pois 'plano_exclusao' pode ter ate 5 repeticoes
        oObj:montatag(nNv+2, 'plano_exclusao',,, .t.,,,, .f.)
        oObj:montatag(nNv+3, 'reg_plano_ans', alltrim(T316->REG_PLAANS), .t.,,,,, .t.,STR0003)
        oObj:montatag(nNv+3, 'dt_fim_vigencia', T316->DT_FIM_VIG, .t.,,,,, .t.,STR0004)
        oObj:montatag(nNv+2, 'plano_exclusao',,, .f., .t.,,, .f.)

        oObj:montatag(nNv+1, 'beneficiariosexcluidos',,, .f., .t.,,, .f.)

        T316->(dbskip())
    enddo

    oObj:montatag(nNv, 'tipoexclusao',,, .f., .t.,,, .f.)
return

/*/{Protheus.doc} tipoDeEnvioMassa
Funçao geradora das tag para o tipo de envio 'Envio de Massa'.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300.
@param cSeqArq, caracter, Sequencial referente ao numero do arquivo atual.
@param cQtdArq, caracter, Indica se é ou não o ultimo arquivo do envio.
/*/
static function tipoDeEnvioMassa(oObj, cSeqArq, cQtdArq)
    oObj:montatag(2, 'tipodeenviomassa',,, .t.,,,, .f.)
    oObj:montatag(3, 'seq_arquivo', cSeqArq, .t.,,,,, .t.)
    oObj:montatag(3, 'ultimo_arquivo', cQtdArq, .t.,,,,, .t.)

    if ! T302->(eof())
        empresasContratantes(oObj, 3)
    endif

    if ! T303->(eof())
        dadosDasPessoas(oObj, 3)
    endif

    if ! T317->(eof())
        dadosAutoGestao(oObj, 3)
    endif

    oObj:montatag(2, 'tipodeenviomassa',,, .f., .t.,,, .f.)
return


/*/{Protheus.doc} dadosDasPessoas
Função geradora das tags dos dados das pessoas, obedecendo os layout's 303 e 306.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300.
@param nNv, numeric, Indicador de nível atual das tags XML.
/*/
static function dadosDasPessoas(oObj, nNv, cTpReg)
    local cChave306
    local nCount303 := 0
    local lCartao   := .T. // via_cartao, dt_val_carteira = Opcional se informado os Dados de Compartilhamento de Risco // Default Obrigatorio

    Default cTpReg := ""

    T303->(dbsetorder(1))
    T306->(dbsetorder(1))

    If !Empty(cTpReg)
        T303->(dbgotop()) // tipo de Envio de Massa não reposiciona no top da tabela para não repetir se houver um segundo arquivo
    Endif

    if ! T303->(eof())
        oObj:montatag(nNv, 'dadosdaspessoas',,, .t.,,,, .f.)

        while ! T303->(eof()) .and. nCount303 < _QTD_REG_

            If (T303->TIPO == cTpReg) .OR. Empty(cTpReg) // Se a variavel cTpReg tiver em branco é porque foi chamado da função EnvioEmMassa, então não precisa filtrar o tipo

                nCount303++
                oObj:montatag(nNv+1, 'pessoa',,, .t.,,,, .f.)
                oObj:montatag(nNv+2, 'nm_compl_benef', alltrim(T303->NM_COM_BEN), .t.,,,,, .t.,STR0005)
                oObj:montatag(nNv+2, 'nm_social', alltrim(T303->NM_SOCIAL),,,,,, .t.)
                oObj:montatag(nNv+2, 'dt_nasc', T303->DT_NASC, .t.,,,,, .t.,STR0006)
                oObj:montatag(nNv+2, 'tp_sexo', T303->TP_SEXO, .t.,,,,, .t.,STR0007)
                oObj:montatag(nNv+2, 'genero_social', T303->GEN_SOCIAL,,,,,, .t.)
                oObj:montatag(nNv+2, 'cd_cpf', T303->CD_CPF, iif(T303->ID_ESTRANG == 'N' .or. calc_idade(ddatabase, stod(T303->DT_NASC)) >= 18 , .t., .f.),,,,, .t.,STR0008)
                oObj:montatag(nNv+2, 'id_estrangeiro', T303->ID_ESTRANG, .t.,,,,, .t.,STR0009)

                if ! empty(T303->CD_IDENT) .and. ! empty(T303->ORGAO_EMIS) .and. ! empty(T303->CD_UF)
                    oObj:montatag(nNv+2, 'cd_rg',,, .t.,,,, .f.)
                    oObj:montatag(nNv+3, 'cd_ident', T303->CD_IDENT,,,,,, .t.)
                    oObj:montatag(nNv+3, 'orgao_emissor', T303->ORGAO_EMIS,,,,,, .t.)
                    oObj:montatag(nNv+3, 'cd_uf', T303->CD_UF,,,,,, .t.)
                    oObj:montatag(nNv+2, 'cd_rg',,, .f., .t.,,, .f.)
                endif

                oObj:montatag(nNv+2, 'cd_pais', T303->CD_PAIS,,,,,, .t.)
                oObj:montatag(nNv+2, 'cd_cns', T303->CD_CNS, .t.,,,,, .t.,STR0010)
                oObj:montatag(nNv+2, 'cd_est_civil', T303->CD_EST_CIV, .t.,,,,, .t.,STR0011)
                oObj:montatag(nNv+2, 'nm_mae', alltrim(T303->NM_MAE), .t.,,,,, .t.,STR0012)
                oObj:montatag(nNv+2, 'pis_pasep', T303->PIS_PASEP,,,,,, .t.)
                oObj:montatag(nNv+2, 'cd_munic_natural', IIF(T303->CD_MUNINAT == replicate("0", 7),"",T303->CD_MUNINAT),,,,,, .t.)
                oObj:montatag(nNv+2, 'cd_munic', T303->CD_MUNIC, .t.,,,,, .t.,STR0013)
                oObj:montatag(nNv+2, 'dadosdosbeneficiarios',,, .t.,,,, .f.)

                if T306->(msseek(T303->CHAVE))
                    cChave306 := T306->CHAVE

                    while ! T306->(eof()) .and. T306->CHAVE == cChave306
                        oObj:montatag(nNv+3, 'beneficiario',,, .t.,,,, .f.)
                        oObj:montatag(nNv+4, 'identificacaoBenef',,, .t.,,,, .f.)
                        oObj:montatag(nNv+5, 'cd_Unimed', T306->CD_UNIMED, .t.,,,,, .t.)
                        oObj:montatag(nNv+5, 'id_Benef', T306->ID_BENEF, .t.,,,,, .t.)
                        oObj:montatag(nNv+4, 'identificacaoBenef',,, .f., .t.,,, .f.)
                        oObj:montatag(nNv+4, 'nm_benef', alltrim(T306->NM_BENEF), .t.,,,,, .t.,STR0014)
                        oObj:montatag(nNv+4, 'nm_social_cartao', alltrim(T306->NM_SOCCART),,,,,, .t.)
                        oObj:montatag(nNv+4, 'cd_depe', T306->CD_DEPE, .t.,,,,, .t.,STR0015)
                        oObj:montatag(nNv+4, 'id_Benef_tit', T306->ID_BENEFTI, .t.,,,,, .t.)
                        oObj:montatag(nNv+4, 'dt_incl_uni', T306->DT_INC_UNI, .t.,,,,, .t.,STR0016)
                        oObj:montatag(nNv+4, 'dt_excl_uni', T306->DT_EXC_UNI,,,,,, .t.)
                        oObj:montatag(nNv+4, 'id_sib', T306->ID_SIB, .t.,,,,, .t.,STR0017)
                        oObj:montatag(nNv+4, 'nr_pla_port', T306->NR_PLA_POR,,,,,, .t.)
                        oObj:montatag(nNv+4, 'id_remido', T306->ID_REMIDO, .t.,,,,, .t.)
                        oObj:montatag(nNv+4, 'id_benef_coop', T306->ID_BENECOP, .t.,,,,, .t.,STR0018)

                        if T306->ID_BENECOP == 'S'
                            oObj:montatag(nNv+4, 'dados_cooperado',,, .t.,,,, .f.)
                            oObj:montatag(nNv+5, 'cd_crm', T306->CD_CRM, .t.,,,,, .t.,STR0019)
                            oObj:montatag(nNv+5, 'cd_uf_conselho', T306->CD_UFCONSE, .t.,,,,, .t., STR0020)
                            oObj:montatag(nNv+4, 'dados_cooperado',,, .f., .t.,,, .f.)
                        endif

                        if ! empty(T306->CD_CAEPF) .or. ! empty(T306->CD_CNPJ)
                            oObj:montatag(nNv+4, 'tipoempresa',,, .t.,,,, .f.)
                            if ! empty(T306->CD_CNPJ) .and. T306->CD_CNPJ != replicate("0", 14)
                                oObj:montatag(nNv+5, 'cd_cnpj', T306->CD_CNPJ, .t.,,,,, .t., STR0021)
                            else
                                oObj:montatag(nNv+5, 'cd_caepf', T306->CD_CAEPF, .t.,,,,, .t., "")
                            endif
                            oObj:montatag(nNv+4, 'tipoempresa',,, .f., .t.,,, .f.)
                        endif
                        // Se lCartao for .F., Informado os dados de compartilhamente de risco, a via_cartao passa a ser Opcional
                        // Se lCartao for .T., Não informado os dados de compartilhamente de risco, a via_cartao passa a ser Obrigatorio
                        if ! T307->(eof())
                            lCartao := compartilhamentoDeRisco(oObj, nNv+4)
                        else
                            lCartao := .T.
                        endif

                        dadosPlanos(oObj, nNv+4, lCartao)
                        oObj:montatag(nNv+3, 'beneficiario',,, .f., .t.,,, .f.)

                        T306->(dbskip())
                    enddo
                endif

                oObj:montatag(nNv+2, 'dadosdosbeneficiarios',,, .f., .t.,,, .f.)
                oObj:montatag(nNv+2, 'complementoscadastrais',,, .t.,,,, .f.)
                endereco(oObj, nNv+3)

                if ! T311->(eof())
                    oObj:montatag(nNv+3, 'contato',,, .t.,,,, .f.)
                    telefone(oObj, nNv+4)
                    email(oObj, nNv+4)
                    oObj:montatag(nNv+3, 'contato',,, .f., .t.,,, .f.)
                endif
                oObj:montatag(nNv+2, 'complementoscadastrais',,, .f., .t.,,, .f.)
                oObj:montatag(nNv+1, 'pessoa',,, .f., .t.,,, .f.)

            Endif
            T303->(dbskip())
        enddo

        oObj:montatag(nNv, 'dadosdaspessoas',,, .f., .t.,,, .f.)
    endif
return


/*/{Protheus.doc} compartilhamentoDeRisco
Função responsável por gerar as tags do layout 307.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300.
@param nNv, numeric, Nivel atual das tags XML.
/*/
static function compartilhamentoDeRisco(oObj, nNv)
    local cChave307
    local lRet := .T. // Obrigatorio

    T307->(dbsetorder(1))
    if T307->(msseek(T306->CHAVE))
        cChave307 := T307->CHAVE

        oObj:montatag(nNv, 'dadosdecompartilhamentoderisco',,, .t.,,,, .f.)

        while ! T307->(eof()) .and. T307->CHAVE == cChave307
            oObj:montatag(nNv+1, 'compartilhamentoderisco',,, .t.,,,, .f.)
            oObj:montatag(nNv+2, 'unimed',,, .t.,,,, .f.)
            oObj:montatag(nNv+3, 'cd_Uni_Destino', T307->CD_UNI_DES, .t.,,,,, .t.)
            oObj:montatag(nNv+3, 'cd_Uni_Origem', T307->CD_UNI_ORI, .t.,,,,, .t.)
            oObj:montatag(nNv+2, 'unimed',,, .f., .t.,,, .f.)
            oObj:montatag(nNv+2, 'tp_com_risco', T307->TP_COM_RIS, .t.,,,,, .t., STR0022)
            oObj:montatag(nNv+2, 'dt_comp_risco', T307->DT_COM_RIS, .t.,,,,, .t., STR0023)
            oObj:montatag(nNv+2, 'dt_fim_comp_risco', T307->DTFIMCOMRI,,,,,, .t.)
            if ! empty(T307->CDUNIDESCO) .or. ! empty(T307->ID_BENEDES)
                oObj:montatag(nNv+2, 'cd_uni_des_com', T307->CDUNIDESCO, .t.,,,,, .t.,STR0024)
                oObj:montatag(nNv+2, 'id_Benef_des', T307->ID_BENEDES, .t.,,,,, .t., STR0025)
            endif
            oObj:montatag(nNv+2, 'via_cartao', T307->VIA_CARTAO,,,,,, .t.)
            oObj:montatag(nNv+2, 'dt_val_carteira', T307->DT_VALCART,,,,,, .t.)
            oObj:montatag(nNv+1, 'compartilhamentoderisco',,, .f., .t.,,, .f.)

            T307->(dbskip())
        enddo

        oObj:montatag(nNv, 'dadosdecompartilhamentoderisco',,, .f., .t.,,, .f.)
        lRet := .F. // Opcional
    endif
return lRet


/*/{Protheus.doc} dadosPlanos
Função responsável por gerar as tags do layout 308, 309 e 310.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300
@param nNv, numeric, Indicador do nivel atual das tags XML.
@param lCartao, logico, Opcional se informado os Dados de Compartilhamento de Risco
/*/
static function dadosPlanos(oObj, nNv, lCartao)
    local nCount308 := 0
    local nCount310 := 0
    local cChave308
    local cChave309
    local cChave310

    T308->(dbsetorder(1))
    T309->(dbsetorder(1))
    T310->(dbsetorder(1))

    if T308->(msseek(T306->CHAVE))
        cChave308 := T308->CHAVE

        oObj:montatag(nNv, 'dadosdosplanos',,, .t.,,,, .f.)

        while ! T308->(eof()) .and. T308->CHAVE == cChave308 .and. nCount308 < 5
            nCount308++

            oObj:montatag(nNv+1, 'plano',,, .t.,,,, .f.)
            oObj:montatag(nNv+2, 'nm_contr', alltrim(T308->NM_CONTR),,,,,, .t.)
            oObj:montatag(nNv+2, 'dt_inicio_vigencia', T308->DT_INI_VIG, .t.,,,,, .t.,STR0026)
            oObj:montatag(nNv+2, 'dt_fim_vigencia', T308->DT_FIM_VIG, iif(empty(T306->DT_EXC_UNI), .f., .t.),,,,, .t.,STR0027)
            oObj:montatag(nNv+2, 'tp_abrangencia', T308->TP_ABRANGE, .t.,,,,, .t.,STR0028)
            oObj:montatag(nNv+2, 'tp_contratacao', T308->TPCONTRATA, .t.,,,,, .t., STR0029)
            oObj:montatag(nNv+2, 'tp_acomodacao', T308->TP_ACOMODA, .t.,,,,, .t., STR0030)
            oObj:montatag(nNv+2, 'id_reg_plano_ans', T308->IDREGPLANS, .t.,,,,, .t., STR0031)
            oObj:montatag(nNv+2, 'reg_plano_ans', alltrim(T308->REGPLA_ANS), .t.,,,,, .t., STR0032)
            oObj:montatag(nNv+2, 'seg_plano', T308->SEG_PLANO, .t.,,,,, .t., STR0033)
            oObj:montatag(nNv+2, 'cd_rede', T308->CD_REDE, .t.,,,,, .t., STR0034)
            oObj:montatag(nNv+2, 'nm_rede', alltrim(T308->NM_REDE),,,,,, .t.)
            oObj:montatag(nNv+2, 'via_cartao', T308->VIA_CARTAO, lCartao ,,,,, .t.,STR0035)
            oObj:montatag(nNv+2, 'dt_val_carteira', T308->DT_VALCART, lCartao ,,,,, .t., STR0036)
            oObj:montatag(nNv+2, 'cd_lcat', T308->CD_LCAT, .t.,,,,, .t., STR0037)
            oObj:montatag(nNv+2, 'id_cpt', T308->ID_CPT, .t.,,,,, .t., STR0038)
            oObj:montatag(nNv+2, 'dt_fim_cpt', T308->DT_FIM_CPT, iif(T308->ID_CPT == 'S', .t., .f.),,,,, .t., STR0039)
            oObj:montatag(nNv+2, 'tp_contrato', T308->TP_CONTRAT, .t.,,,,, .t., STR0040)
            if ! empty(T308->CNPJADMBEN) .and. T308->CNPJADMBEN <> replicate("0", 15)
                oObj:montatag(nNv+2, 'cd_cnpj_adm_benef', right(T308->CNPJADMBEN, 14),,,,,, .t.)
                oObj:montatag(nNv+2, 'raz_soc_adm_benef', alltrim(T308->RZSOCADMBE), .t.,,,,, .t., STR0041)
                oObj:montatag(nNv+2, 'nm_adm_benef', T308->NMADMBENEF, .t.,,,,, .t., STR0042)
            endif
            oObj:montatag(nNv+2, 'nm_produto', alltrim(T308->NM_PRODUTO), .t.,,,,, .t., STR0043)
            oObj:montatag(nNv+2, 'nr_contrato', T308->NR_CONTRAT, .t.,,,,, .t., "")
            oObj:montatag(nNv+2, 'dt_contr_plano', T308->DTCONTRPLA, .t.,,,,, .t., STR0044)
            oObj:montatag(nNv+2, 'tipo_rede_min', T308->TP_REDEMIN, .t.,,,,, .t., STR0045)

            if T309->(msseek(rtrim(T308->CHAVE_FULL)+T306->ID_BENEF))
                cChave309 := T309->CHAVE

                oObj:montatag(nNv+2, 'abrangencias',,, .t.,,,, .f.)
                while ! T309->(eof()) .and. T309->CHAVE == cChave309

                    oObj:montatag(nNv+3, 'abrangencia',,, .t.,,,, .f.)
                    oObj:montatag(nNv+4, 'cd_munic', T309->CD_MUNIC, iif(T308->TP_ABRANGE != '2', .t., .f.),,,,, .t., STR0046)
                    oObj:montatag(nNv+4, 'cd_uf', T309->CD_UF, iif(T308->TP_ABRANGE != '4', .t., .f.),,,,, .t., STR0047)
                    oObj:montatag(nNv+3, 'abrangencia',,, .f., .t.,,, .f.)

                    T309->(dbskip())
                enddo
                oObj:montatag(nNv+2, 'abrangencias',,, .f., .t.,,, .f.)
            endif

            if T310->(msseek(rtrim(T308->CHAVE) + T306->ID_BENEF))
                cChave310 := T310->CHAVE

                oObj:montatag(nNv+2, 'carenciasdosbeneficiarios',,, .t.,,,, .f.)
                while ! T310->(eof()) .and. T310->CHAVE == cChave310 .and. nCount310 < 100
                    nCount310++

                    oObj:montatag(nNv+2, 'carenciadobeneficiario',,, .t.,,,, .f.)
                    oObj:montatag(nNv+4, 'tp_cobertura', T310->TP_COBERTU, .t.,,,,, .t., STR0048)
                    oObj:montatag(nNv+4, 'dt_fim_carencia', T310->DT_FIMCARE, .t.,,,,, .t., STR0049)
                    oObj:montatag(nNv+2, 'carenciadobeneficiario',,, .f., .t.,,, .f.)

                    T310->(dbskip())
                enddo
                oObj:montatag(nNv+2, 'carenciasdosbeneficiarios',,, .f., .t.,,, .f.)
            endif
            oObj:montatag(nNv+1, 'plano',,, .f., .t.,,, .f.)

            T308->(dbskip())
        enddo

        oObj:montatag(nNv, 'dadosdosplanos',,, .f., .t.,,, .f.)
    endif
return

/*/{Protheus.doc} empresasContratantes
Função geradora das tag referentes ao layout 302.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300
@param nNv, numeric, Indicador do nivel atual das tags XML.
/*/
static function empresasContratantes(oObj, nNv)
    local nCount302 := 0

    T302->(dbgotop())

    if ! T302->(eof())
        oObj:montatag(nNv, 'empresascontratantes',,, .t.,,,, .f.)

        while ! T302->(eof()) .and. nCount302 < _QTD_REG_
            nCount302++
            oObj:montatag(nNv+1, 'empresacontratante',,, .t.,,,, .f.)
            oObj:montatag(nNv+2, 'tipoempresa',,, .t.,,,, .f.)
            if ! empty(T302->CD_CPNJ) .and. T302->CD_CPNJ != replicate("0", 14)
                oObj:montatag(nNv+3, 'cd_cnpj', T302->CD_CPNJ, .t.,,,,, .t., STR0050)
            else
                oObj:montatag(nNv+3, 'cd_caepf', T302->CD_CAEPF, .t.,,,,, .t., STR0051)
            endif
            oObj:montatag(nNv+2, 'tipoempresa',,, .f., .t.,,, .f.)
            oObj:montatag(nNv+2, 'cd_insc_est', T302->CD_INS_EST,,,,,, .t.)
            oObj:montatag(nNv+2, 'nm_empr_comp', alltrim(T302->NM_EMP_COM), .t.,,,,, .t., STR0052)
            oObj:montatag(nNv+2, 'nm_fantasia_empr', alltrim(T302->NM_FAN_EMP), .t.,,,,, .t., STR0053)
            oObj:montatag(nNv+2, 'nm_empr_abre', alltrim(T302->NM_EMP_ABR),,,,,, .t.)
            oObj:montatag(nNv+1, 'empresacontratante',,, .f., .t.,,, .f.)

            T302->(dbskip())
        enddo
        oObj:montatag(nNv, 'empresascontratantes',,, .f., .t.,,, .f.)
        T302->(dbgotop())
    endif

return

/*/{Protheus.doc} endereco
Função geradora das tag referentes ao layout 305.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300
@param nNv, numeric, Indicador do nivel atual das tags XML.
/*/
static function endereco(oObj, nNv)
    local nCount305 := 0
    local cChave305

    T305->(dbsetorder(1))
    if T305->(msseek(T303->CHAVE))
        cChave305 := T305->CHAVE

        while ! T305->(eof()) .and. T305->CHAVE == cChave305 .and. nCount305 < 5
            nCount305++

            oObj:montatag(nNv, 'endereco',,, .t.,,,, .f.)
            oObj:montatag(nNv+1, 'ind_resid', T305->IND_RESID, .t.,,,,, .t.)
            oObj:montatag(nNv+1, 'tp_end', T305->TP_END, .t.,,,,, .t.)
            oObj:montatag(nNv+1, 'info_endereco',,, .t.,,,, .f.)
            oObj:montatag(nNv+2, 'tp_logradouro', T305->TP_LOGRAD, .t.,,,,, .t., STR0054)
            oObj:montatag(nNv+2, 'ds_lograd', rtrim(T305->DS_LOGRAD), .t.,,,,, .t., STR0055)
            oObj:montatag(nNv+2, 'nr_lograd', rtrim(T305->NR_LOGRAD), .t.,,,,, .t., STR0056)
            oObj:montatag(nNv+2, 'compl_lograd', rtrim(T305->COMP_LOGRD),,,,,, .t.)
            oObj:montatag(nNv+2, 'ds_bairro', rtrim(T305->DS_BAIRRO),,,,,, .t.)
            oObj:montatag(nNv+2, 'cd_munic', T305->CD_MUNIC, .t.,,,,, .t., STR0057)
            oObj:montatag(nNv+2, 'nr_cep', T305->NR_CEP, .t.,,,,, .t., STR0058)
            oObj:montatag(nNv+1, 'info_endereco',,, .f., .t.,,, .f.)
            oObj:montatag(nNv, 'endereco',,, .f., .t.,,, .f.)

            T305->(dbskip())
        enddo

    endif
return


/*/{Protheus.doc} telefone
Função geradora das tag referentes ao layout 311 (telefone).

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300
@param nNv, numeric, Indicador do nivel atual das tags XML.
/*/
static function telefone(oObj, nNv)
    local nCount311 := 0
    local cChave311

    T311->(dbsetorder(1))
    T311->(dbgotop())
    if T311->(msseek(T303->CHAVE))
        cChave311 := T311->CHAVE

        while ! T311->(eof()) .and. T311->CHAVE == cChave311 .and. nCount311 < 5
            nCount311++

            oObj:montatag(nNv, 'telefone',,, .t.,,,, .f.)
            oObj:montatag(nNv+1, 'tp_fone', T311->TP_FONE,,,,,, .t.)
            oObj:montatag(nNv+1, 'nr_ddd', T311->NR_DDD, iif(T311->TP_FONE $ '1|2|3', .t., .f.),,,,, .t., STR0059)
            oObj:montatag(nNv+1, 'nr_fone', T311->NR_FONE, iif(T311->TP_FONE $ '1|2|3', .t., .f.),,,,, .t., STR0060)
            oObj:montatag(nNv, 'telefone',,, .f., .t.,,, .f.)

            T311->(dbskip())
        enddo
    endif
return


/*/{Protheus.doc} email
Função geradora das tag referentes ao layout 311 (email).

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300
@param nNv, numeric, Indicador do nivel atual das tags XML.
/*/
static function email(oObj, nNv)
    local nCount311 := 0
    local cChave311

    T311->(dbsetorder(1))
    T311->(dbgotop())
    if T311->(msseek(T303->CHAVE))
        cChave311 := T303->CHAVE

        while ! T311->(eof()) .and. T311->CHAVE == cChave311 .and. nCount311 < 5
            nCount311++
            if ! empty(T311->END_EMAIL)
                oObj:montatag(nNv, 'email',,, .t.,,,, .f.)
                oObj:montatag(nNv+1, 'tp_email', T311->TP_EMAIL, .t.,,,,, .t.)
                oObj:montatag(nNv+1, 'end_email', alltrim(T311->END_EMAIL), iif(T311->TP_EMAIL $ '1|2', .t., .f.),,,,, .t., STR0061)
                oObj:montatag(nNv, 'email',,, .f., .t.,,, .f.)
            endif
            T311->(dbskip())
        enddo
    endif
return


/*/{Protheus.doc} dadosAutoGestao
Função geradora das tag referentes ao layout 317.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oObj, object, Objeto da classe XMLA1300
@param nNv, numeric, Indicador do nivel atual das tags XML.
/*/
static function dadosAutoGestao(oObj, nNv, cTpReg)
    local nCount317 := 0

    Default cTpReg := ""

    T317->(dbgotop())

    if ! T317->(eof())
        oObj:montatag(nNv, 'dadosautogestao',,, .t.,,,, .f.)

        while ! T317->(eof()) .and. nCount317 < _QTD_REG_

            If (T317->TIPO == cTpReg) .OR. Empty(cTpReg) // Se a variavel cTpReg tiver em branco é porque foi chamado da função EnvioEmMassa, então não precisa filtrar o tipo
                nCount317++

                oObj:montatag(nNv+1, 'autogestao',,, .t.,,,, .f.)
                oObj:montatag(nNv+2, 'identificacaoBenef',,, .t.,,,, .f.)
                oObj:montatag(nNv+3, 'cd_Unimed', T317->CD_UNIMED, .t.,,,,, .t.)
                oObj:montatag(nNv+3, 'id_Benef', T317->ID_BENEF, .t.,,,,, .t.)
                oObj:montatag(nNv+2, 'identificacaoBenef',,, .f., .t.,,, .f.)
                oObj:montatag(nNv+2, 'nm_benef', alltrim(T317->NM_BENEF), .t.,,,,, .t., STR0062)
                oObj:montatag(nNv+2, 'dt_nasc', T317->DT_NASC, .t.,,,,, .t., STR0063)
                oObj:montatag(nNv+2, 'tp_sexo', T317->TP_SEXO, .t.,,,,, .t., STR0064)
                oObj:montatag(nNv+2, 'cd_cns', T317->CD_CNS,,,,,, .t.)
                oObj:montatag(nNv+2, 'cd_cnpj', T317->CD_CNPJ, .t.,,,,, .t., STR0065)
                oObj:montatag(nNv+2, 'cd_aut_gest_ans', T317->CAUTGESANS, .t.,,,,, .t., STR0066)
                oObj:montatag(nNv+2, 'cd_cpf', T317->CD_CPF,,,,,, .t.)
                oObj:montatag(nNv+2, 'dt_incl', T317->DT_INCL, .t.,,,,, .t., STR0067)
                oObj:montatag(nNv+2, 'dt_excl', T317->DT_EXCL,,,,,, .t.)
                oObj:montatag(nNv+1, 'autogestao',,, .f., .t.,,, .f.)
            ENDIF

            T317->(dbskip())
        enddo
        oObj:montatag(nNv, 'dadosautogestao'     ,,, .f., .t.,,, .f.)
    endif
return