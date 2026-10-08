#Include "Protheus.ch"

/*/{Protheus.doc} User Function TM050COP
    (long_description)
    @Ponto de entrada utilizado para limpar campo customizado na rotina TMSA050 ao copiar o registro. DTC_ZNCCOD
    @Daniel Victor da Rosa
    @since 08/05/2024
/*/

User Function TM050COP()

	M->DTC_ZNCCOD := SPACE(GetSx3Cache("DTC_ZNCCOD" , "X3_TAMANHO" ))
	M->DTC_ZCCUST := SPACE(GetSx3Cache("DTC_ZCCUST" , "X3_TAMANHO" ))

Return
