#!/bin/bash

################################################################################
# Base64 Encoder/Decoder Bash Script
#
# Usage:
#   ./base64-tool.sh encode "your text here"
#   ./base64-tool.sh decode "eW91ciB0ZXh0IGhlcmU="
#   ./base64-tool.sh encode-file path/to/file.txt
#   ./base64-tool.sh decode-file path/to/file.b64
################################################################################

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo ""
    echo -e "${CYAN}==================================${NC}"
    echo -e "${CYAN}  Base64 Encoder/Decoder Tool${NC}"
    echo -e "${CYAN}==================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_info() {
    echo -e "${YELLOW}${1}${NC}"
}

# Encode text to Base64
encode_text() {
    local text="$1"
    
    print_info "Encoding text to Base64..."
    echo ""
    echo -e "${GREEN}Original Text:${NC}"
    echo "$text"
    echo ""
    echo -e "${GREEN}Base64 Encoded:${NC}"
    
    local encoded=$(echo -n "$text" | base64)
    echo -e "${WHITE}${encoded}${NC}"
    echo ""
    
    # Try to copy to clipboard (works on different systems)
    if command -v xclip &> /dev/null; then
        echo -n "$encoded" | xclip -selection clipboard
        print_success "Result copied to clipboard!"
    elif command -v pbcopy &> /dev/null; then
        echo -n "$encoded" | pbcopy
        print_success "Result copied to clipboard!"
    elif command -v clip.exe &> /dev/null; then
        echo -n "$encoded" | clip.exe
        print_success "Result copied to clipboard!"
    fi
}

# Decode Base64 to text
decode_text() {
    local base64_text="$1"
    
    print_info "Decoding Base64 to text..."
    echo ""
    echo -e "${GREEN}Base64 Input:${NC}"
    echo "$base64_text"
    echo ""
    echo -e "${GREEN}Decoded Text:${NC}"
    
    local decoded=$(echo -n "$base64_text" | base64 --decode 2>&1)
    
    if [ $? -eq 0 ]; then
        echo -e "${WHITE}${decoded}${NC}"
        echo ""
        
        # Try to copy to clipboard
        if command -v xclip &> /dev/null; then
            echo -n "$decoded" | xclip -selection clipboard
            print_success "Result copied to clipboard!"
        elif command -v pbcopy &> /dev/null; then
            echo -n "$decoded" | pbcopy
            print_success "Result copied to clipboard!"
        elif command -v clip.exe &> /dev/null; then
            echo -n "$decoded" | clip.exe
            print_success "Result copied to clipboard!"
        fi
    else
        print_error "Invalid Base64 string"
        return 1
    fi
}

# Encode file to Base64
encode_file() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        print_error "File not found: $file_path"
        return 1
    fi
    
    print_info "Encoding file to Base64..."
    
    local output_path="${file_path}.b64"
    base64 "$file_path" > "$output_path"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}Input File:${NC} $file_path"
        echo -e "${GREEN}Output File:${NC} $output_path"
        echo ""
        echo -e "${YELLOW}File size:${NC}"
        echo "  Original: $(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null) bytes"
        echo "  Encoded:  $(stat -f%z "$output_path" 2>/dev/null || stat -c%s "$output_path" 2>/dev/null) bytes"
        echo ""
        print_success "File encoded successfully!"
    else
        print_error "Failed to encode file"
        return 1
    fi
}

# Decode Base64 file
decode_file() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        print_error "File not found: $file_path"
        return 1
    fi
    
    print_info "Decoding Base64 file..."
    
    # Remove .b64 extension or add .decoded
    local output_path="${file_path%.b64}"
    if [ "$output_path" = "$file_path" ]; then
        output_path="${file_path}.decoded"
    fi
    
    base64 --decode "$file_path" > "$output_path" 2>&1
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}Input File:${NC} $file_path"
        echo -e "${GREEN}Output File:${NC} $output_path"
        echo ""
        print_success "File decoded successfully!"
    else
        print_error "Failed to decode file - invalid Base64 content"
        rm -f "$output_path"
        return 1
    fi
}

# Show usage
show_usage() {
    cat << EOF
Base64 Encoder/Decoder Tool

Usage:
    $0 <action> <input>

Actions:
    encode          Encode text to Base64
    decode          Decode Base64 to text
    encode-file     Encode a file to Base64
    decode-file     Decode a Base64 file

Examples:
    $0 encode "Hello World"
    $0 decode "SGVsbG8gV29ybGQ="
    $0 encode-file document.pdf
    $0 decode-file document.pdf.b64

EOF
}

################################################################################
# Main Script
################################################################################

ACTION="$1"
INPUT="$2"

print_header

# Check arguments
if [ -z "$ACTION" ] || [ -z "$INPUT" ]; then
    print_error "Missing arguments"
    echo ""
    show_usage
    exit 1
fi

# Execute action
case "$ACTION" in
    encode)
        encode_text "$INPUT"
        ;;
    decode)
        decode_text "$INPUT"
        ;;
    encode-file)
        encode_file "$INPUT"
        ;;
    decode-file)
        decode_file "$INPUT"
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error "Invalid action: $ACTION"
        echo ""
        show_usage
        exit 1
        ;;
esac

echo ""
exit 0
