import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/rag_service.dart';

/// Floating chat widget for RAG-based financial advisory
class RagChatWidget extends StatefulWidget {
  const RagChatWidget({super.key});

  @override
  State<RagChatWidget> createState() => _RagChatWidgetState();
}

class _RagChatWidgetState extends State<RagChatWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RagService _ragService = RagService();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Add welcome message
    _addMessage(
      ChatMessage(
        text:
            "👋 Hi! I'm your financial advisor AI. Ask me anything about personal finance, investments, budgeting, or money management!",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    _addMessage(
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    _messageController.clear();
    setState(() => _isLoading = true);

    try {
      // Get AI response
      final response = await _ragService.chat(text);

      if (response.success) {
        _addMessage(
          ChatMessage(
            text: response.answer,
            isUser: false,
            timestamp: DateTime.now(),
            sources: response.sources,
          ),
        );
      } else {
        _addMessage(
          ChatMessage(
            text:
                "Sorry, I encountered an error. Please try again. Error: ${response.message}",
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
      }
    } catch (e) {
      _addMessage(
        ChatMessage(
          text: "Sorry, I couldn't connect to the advisory service. Please try again later.",
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.surface;
    final backgroundColor = isDark ? AppColorsDark.background : Colors.white;

    return Stack(
      children: [
        // Expanded chat window
        if (_isExpanded)
          Positioned(
            right: 16,
            bottom: 90,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.bottomRight,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: surfaceColor,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, primaryColor.withOpacity(0.8)],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.smart_toy, color: Colors.white),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Financial Advisor AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: _toggleChat,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                      // Messages
                      Expanded(
                        child: Container(
                          color: backgroundColor,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
                        ),
                      ),

                      // Loading indicator
                      if (_isLoading)
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(primaryColor),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Thinking...',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Input field
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          border: Border(
                            top: BorderSide(
                              color: primaryColor.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Ask me about finance...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(color: primaryColor),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: backgroundColor,
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _sendMessage(),
                                enabled: !_isLoading,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.send, color: Colors.white),
                                onPressed: _isLoading ? null : _sendMessage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Floating action button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _toggleChat,
            backgroundColor: primaryColor,
            child: Icon(
              _isExpanded ? Icons.close : Icons.chat,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final textColor = isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? primaryColor
                    : (message.isError ? Colors.red.withOpacity(0.1) : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isUser ? const Radius.circular(4) : null,
                  bottomLeft: !message.isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : textColor,
                  fontSize: 14,
                ),
              ),
            ),
            if (message.sources != null && message.sources!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  'Sources: ${message.sources!.join(", ")}',
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 8, right: 8),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? sources;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
    this.isError = false,
  });
}
